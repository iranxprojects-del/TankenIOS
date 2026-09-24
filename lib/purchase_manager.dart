
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'translations.dart';
//import 'app_timeline_manager.dart';

Future<void>? _firebaseInitFuture;

/// راه‌اندازی Firebase را حداکثر یک‌بار شروع می‌کند و همه‌ی نقاطی که به
/// Firestore/Cloud Functions نیاز دارند همین Future مشترک را await می‌کنند —
/// صرف‌نظر از ترتیب فراخوانی، هیچ‌کس زودتر از ساخته‌شدن اپ [DEFAULT] به
/// Firebase دست نمی‌زند (رفع خطای core/no-app).
Future<void> ensureFirebaseInitialized() {
  return _firebaseInitFuture ??= Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).catchError((e) {
    debugPrint('Firebase init error: $e');
  });
}

class PurchaseManager {
  // پیاده‌سازی الگوی سنگلتون برای دسترسی یکپارچه در کل اپلیکیشن
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();

  final int premiumDurationDays = 180; // اعتبار ۶ ماهه اشتراک

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  /// Consumable تمدید ۶ماهه — شناسه واقعی استور
  static const String premiumProductId = 'premiumunlock_tanken';
  /// شناسه‌های قدیمی احتمالی؛ فقط برای consume و آزاد کردن «already own»
  static const String legacyPremiumProductId = 'premium_tanken';
  static const Set<String> _allPremiumProductIds = {
    premiumProductId,
    legacyPremiumProductId,
    'premium_tanken_6m',
  };

  // نوتیفایرهایی برای به‌روزرسانی خودکار ظاهر برنامه بدون درگیر کردن کدهای UI
  final ValueNotifier<bool> isPremiumUser = ValueNotifier<bool>(false);
  final ValueNotifier<bool> isProcessing = ValueNotifier<bool>(false);

  // کالبک‌هایی برای فرستادن پیغام به UI (مثلاً نمایش اسنک‌بار)
  Function(String error)? onErrorOccurred;
  Function()? onPurchaseSuccess;

  /// مقداردهی اولیه سرویس پرداخت
  void initialize({
    Function(String)? onError,
    Function()? onSuccess,
  }) {
    onErrorOccurred = onError;
    onPurchaseSuccess = onSuccess;
    _validatePremiumStatus();
    
    _initPurchaseStream();
    checkPremiumStatus();
    // آزاد کردن خریدهای consume‌نشده (علت اصلی already own روی اندروید)
    Future.microtask(() => _consumeAllOwnedAndroidPremiums());
  }

  /// بستن استریم جهت جلوگیری از لک حافظه (Memory Leak)
  void dispose() {
    isPremiumUser.dispose();
    _purchaseSubscription?.cancel();
  }

  // گوش دادن به تغییرات درگاه پرداخت گوگل پلی
  void _initPurchaseStream() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _purchaseSubscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _purchaseSubscription?.cancel();
    }, onError: (error) {
      _handleError(translate('iap_stream_error', currentAppLanguage(), {'error': '$error'}));
    });
  }

  Future<void> _validatePremiumStatus() async {
    AppTimelineManager().hydrateFromLocalCache();
    AppTimelineManager().calculateCurrentStatus();
    var box = Hive.box('settingsBox');
    await box.put('isPremium', isPremiumUser.value);
  }

  // خرید Consumable قابل تکرار است؛ قبل/بعد باید روی اندروید consume شود
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isProcessing.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.purchased) {
          if (_allPremiumProductIds.contains(purchaseDetails.productID)) {
            await _grantPremiumAccess();
          }
          await _consumeAndroidPurchaseIfNeeded(purchaseDetails);
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          isProcessing.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.restored) {
          // restore فقط برای آزاد کردن مالکیت؛ اعتبار دوباره نمی‌دهیم
          await _consumeAndroidPurchaseIfNeeded(purchaseDetails);
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          isProcessing.value = false;
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          isProcessing.value = false;
          final msg = purchaseDetails.error?.message ?? translate('iap_failed', currentAppLanguage());
          if (_isAlreadyOwnedError(msg)) {
            await _consumeAllOwnedAndroidPremiums();
            _handleError(
              currentAppLanguage() == 'fa'
                  ? 'خرید قبلی در حساب استور باقی مانده بود و مصرف شد. دوباره «تمدید ۶ ماهه» را بزنید. اگر باز هم خطا داد، در کنسول محصول $premiumProductId را Consumable کنید.'
                  : 'Previous store ownership was consumed. Tap Extend again. If it fails, mark $premiumProductId as Consumable in the store console.',
            );
          } else {
            _handleError(msg);
          }
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          isProcessing.value = false;
          _handleError(translate('iap_cancelled', currentAppLanguage()));
        }
      }
    }
  }

  bool _isAlreadyOwnedError(String message) {
    final m = message.toLowerCase();
    return m.contains('already own') ||
        m.contains('item already owned') ||
        m.contains('already_owned') ||
        m.contains('item_already_owned');
  }

  Future<void> _consumeAndroidPurchaseIfNeeded(PurchaseDetails purchase) async {
    if (!Platform.isAndroid) return;
    if (!_allPremiumProductIds.contains(purchase.productID)) return;
    try {
      final androidAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final result = await androidAddition.consumePurchase(purchase);
      debugPrint(
        'Android consume ${purchase.productID}: ${result.responseCode} ${result.debugMessage}',
      );
    } catch (e) {
      debugPrint('Android consume failed: $e');
    }
  }

  Future<void> _consumeAllOwnedAndroidPremiums() async {
    if (!Platform.isAndroid) return;
    try {
      final androidAddition =
          _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final past = await androidAddition.queryPastPurchases();
      for (final purchase in past.pastPurchases) {
        if (!_allPremiumProductIds.contains(purchase.productID)) continue;
        try {
          await androidAddition.consumePurchase(purchase);
          if (purchase.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchase);
          }
          debugPrint('Consumed owned premium: ${purchase.productID}');
        } catch (e) {
          debugPrint('Consume owned premium failed: $e');
        }
      }
    } catch (e) {
      debugPrint('queryPastPurchases failed: $e');
    }
  }

  Future<void> _grantPremiumAccess() async {
    await ensureFirebaseInitialized();
    try {
      await AppTimelineManager().savePremiumPurchaseToServer();
    } catch (e) {
      print("Timeline premium save error: $e");
    }

    var box = Hive.box('settingsBox');
    await box.put('isPremium', true);
    if (AppTimelineManager().premiumPurchaseDate != null) {
      await box.put(
        'premiumPurchaseDate',
        AppTimelineManager().premiumPurchaseDate!.toIso8601String(),
      );
    }

    String? deviceId = await _getDeviceId();
    if (deviceId != null) {
      try {
        await FirebaseFirestore.instance.collection('premium_users').doc(deviceId).set({
          'is_premium': true,
          'purchase_date': DateTime.now().toIso8601String(),
          'product_id': premiumProductId,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        }, SetOptions(merge: true));
      } catch (e) {
        print("Firebase Store Error: $e");
      }
    }
    isPremiumUser.value = true;
    if (onPurchaseSuccess != null) onPurchaseSuccess!();
  }

  /// بررسی بک‌گراند در فایربیس هنگام باز شدن برنامه
  Future<void> checkPremiumStatus() async {
    await ensureFirebaseInitialized();
    String? deviceId = await _getDeviceId();
    if (deviceId != null) {
      try {
        var doc = await FirebaseFirestore.instance.collection('premium_users').doc(deviceId).get();
        if (doc.exists && doc.data() != null) {
          if (doc.data()!['is_premium'] == true) {
            isPremiumUser.value = true;
          }
        }
      } catch (e) {
        print("Firebase Check Error: $e");
      }
    }
  }

  /// خرید ۶ماهه تکراری (۲، ۳، …) — روی اندروید قبل از خرید، مالکیت قبلی consume می‌شود
  Future<void> buyPremium() async {
    isProcessing.value = true;
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      isProcessing.value = false;
      _handleError(translate('iap_store_unavailable', currentAppLanguage()));
      return;
    }

    // بدون این، خرید قبلیِ consume‌نشده → You already own this item
    await _consumeAllOwnedAndroidPremiums();

    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails({premiumProductId});

    if (response.productDetails.isEmpty) {
      isProcessing.value = false;
      _handleError(translate('iap_product_not_found', currentAppLanguage(), {'id': premiumProductId}));
      return;
    }

    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: response.productDetails.first);

    try {
      final bool started = await _inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
      if (!started) {
        isProcessing.value = false;
        _handleError(
          currentAppLanguage() == 'fa'
              ? 'شروع خرید ناموفق بود. دوباره تلاش کنید.'
              : 'Could not start purchase. Try again.',
        );
      }
    } catch (e) {
      final msg = e.toString();
      if (_isAlreadyOwnedError(msg)) {
        await _consumeAllOwnedAndroidPremiums();
        try {
          await _inAppPurchase.buyConsumable(
            purchaseParam: purchaseParam,
            autoConsume: true,
          );
          return;
        } catch (e2) {
          isProcessing.value = false;
          _handleError(
            currentAppLanguage() == 'fa'
                ? 'استور هنوز آیتم را متعلق به شما می‌داند. در Play Console محصول $premiumProductId را Consumable کنید (نه Non-consumable). جزئیات: $e2'
                : 'Store still reports ownership. Mark $premiumProductId as Consumable in Play Console. ($e2)',
          );
          return;
        }
      }
      isProcessing.value = false;
      _handleError(msg);
    }
  }

  /// بازیابی خریدهای قبلی کاربر
  Future<void> restorePurchases() async {
    isProcessing.value = true;
    await _inAppPurchase.restorePurchases();
  }

  // گرفتن شناسه سخت‌افزاری منحصر به فرد دستگاه
  Future<String?> _getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      var iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  void _handleError(String message) {
    if (onErrorOccurred != null) onErrorOccurred!(message);
  }
}


// ==========================================
// بخش مدیریت تبلیغات هوشمند (Ad Manager) برای پروژه تانکن
// ==========================================
class AppAdManager {
  static final AppAdManager _instance = AppAdManager._internal();
  factory AppAdManager() => _instance;
  AppAdManager._internal(){
    initAdUnits(); // <--- اینجا صداش می‌زنیم تا خودکار اجرا بشه
  }

  // کنترل فعال بودن انواع تبلیغات بر اساس سناریو
  static const bool enableBannerAd = true;
  static const bool enableInterstitialAd = true;
  static const bool enableRewardedAd = true;

  // Google official test ad units (platform-specific)
  static const String _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const String _androidTestInterstitial = 'ca-app-pub-3940256099942544/1033173712';
  static const String _androidTestRewarded = 'ca-app-pub-3940256099942544/5224354917';
  static const String _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';
  static const String _iosTestRewarded = 'ca-app-pub-3940256099942544/1712485313';

  // Android production ad units (Tanken Android)
  static const String _androidProdBanner = 'ca-app-pub-1909436077319120/7037632312';
  static const String _androidProdInterstitial = 'ca-app-pub-1909436077319120/5488626786';
  static const String _androidProdRewarded = 'ca-app-pub-1909436077319120/3065075207';

  // iOS production ad units (same as IOS-RES-Cursor)
  static const String _iosProdBanner = 'ca-app-pub-1909436077319120/8843537535';
  static const String _iosProdInterstitial = 'ca-app-pub-1909436077319120/3862673598';
  static const String _iosProdRewarded = 'ca-app-pub-1909436077319120/8731856899';

  static String _bannerUnitId = _androidTestBanner;
  static String _interstitialUnitId = _androidTestInterstitial;
  static String _rewardedUnitId = _androidTestRewarded;

  String get bannerUnitId => _bannerUnitId;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;
  Future<InitializationStatus>? _sdkInit;

  Future<void> _requestTrackingAuthorizationIfNeeded() async {
    if (!Platform.isIOS) return;
    try {
      final status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await AppTrackingTransparency.requestTrackingAuthorization();
      }
    } catch (e) {
      debugPrint('ATT request failed: $e');
    }
  }

  Future<void> ensureSdkReady() async {
    if (_sdkInit != null) {
      await _sdkInit;
      return;
    }
    _sdkInit = _initializeMobileAds();
    await _sdkInit;
  }

  Future<InitializationStatus> _initializeMobileAds() async {
    await _requestTrackingAuthorizationIfNeeded();
    return MobileAds.instance.initialize();
  }

  void initAdUnits() {
    final useTestAds = kDebugMode || AppTimelineManager().isTestingMode;
    final isIos = Platform.isIOS;

    if (useTestAds) {
      _bannerUnitId = isIos ? _iosTestBanner : _androidTestBanner;
      _interstitialUnitId = isIos ? _iosTestInterstitial : _androidTestInterstitial;
      _rewardedUnitId = isIos ? _iosTestRewarded : _androidTestRewarded;
      return;
    }

    if (isIos) {
      _bannerUnitId = _iosProdBanner;
      _interstitialUnitId = _iosProdInterstitial;
      _rewardedUnitId = _iosProdRewarded;
    } else {
      _bannerUnitId = _androidProdBanner;
      _interstitialUnitId = _androidProdInterstitial;
      _rewardedUnitId = _androidProdRewarded;
    }
  }

  bool get shouldShowBannerAd => enableBannerAd;

  bool get shouldShowInterstitialAd =>
      enableInterstitialAd && !PurchaseManager().isPremiumUser.value;

  bool get shouldShowRewardedAd =>
      enableRewardedAd && !PurchaseManager().isPremiumUser.value;

  // ۱. بارگذاری تبلیغ بین‌صفحه‌ای (فاز ۲ به بعد)
  void loadInterstitialAd() {
    if (!shouldShowInterstitialAd) return;
    
    InterstitialAd.load(
      adUnitId: _interstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _interstitialAd = null;
          _isInterstitialLoaded = false;
        },
      ),
    );
  }

  // ۲. بارگذاری ویدیو جایزه‌ای ناوبری (فاز ۳)
  void loadRewardedAd() {
    if (!shouldShowRewardedAd) return;

    RewardedAd.load(
      adUnitId: _rewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  // نمایش تبلیغ بین‌صفحه‌ای هنگام سوئیچ تب‌ها (بعد از قطع سرویس هم ادامه دارد)
  void showInterstitialAd(VoidCallback onAdClosed) {
    int tier = AppTimelineManager().currentTier;
    if (!_isInterstitialLoaded ||
        _interstitialAd == null ||
        tier < 2 ||
        !shouldShowInterstitialAd) {
      onAdClosed();
      loadInterstitialAd();
      return;
    }

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isInterstitialLoaded = false;
        onAdClosed();
        loadInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isInterstitialLoaded = false;
        onAdClosed();
        loadInterstitialAd();
      },
    );

    _interstitialAd!.show();
    _interstitialAd = null;
  }

  // نمایش ویدیوی طولانی هنگام کلیک روی گوگل مپ
  void showNavigationRewardedAd(VoidCallback onAdClosed) {
    int tier = AppTimelineManager().currentTier;
    if (!_isRewardedLoaded || _rewardedAd == null || tier < 2 || tier >= 4 || PurchaseManager().isPremiumUser.value) {
      onAdClosed();
      loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedLoaded = false;
        onAdClosed();
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedLoaded = false;
        onAdClosed();
        loadRewardedAd();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (ad, item) {});
    _rewardedAd = null;
  }
}

// ==========================================
// بخش مدیریت لایف‌سایکل و خط زمانی ۶ ماهه کاربر
// ==========================================


class AppTimelineManager {
  static final AppTimelineManager _instance = AppTimelineManager._internal();
  factory AppTimelineManager() => _instance;
  AppTimelineManager._internal();

  // 🎯 فلگ تست: اگر true باشد، هر ۱ دقیقه معادل ۱ روز فرض می‌شود تا سریع تست کنید
  bool isTestingMode = false; 

  DateTime? firstInstallDate;
  DateTime? premiumPurchaseDate;
  DateTime? postPremiumFallbackDate; // حل مشکل خطای متد گمشده و همگام‌سازی با نسخه اول

  int daysUsed = 0;
  int currentTier = 0; 
  
  // تعداد روزهای کل دوره رایگان (۹۰ روز طبق فازبندی جدید شما)
  final int totalFreeDays = 90;

  /*
   فازهای زمانی تانکن (Tiers):
   فاز 0: روز ۰ تا ۳ -> هیچ تبلیغی نیست.
   فاز 1: روز ۳ تا ۳۰ -> فقط بنر کوچک پایین صفحه‌ها.
   فاز 2: روز ۳۰ تا ۶۰ -> بنر + تبلیغ بین‌صفحه‌ای هنگام تعویض تب + ویدیو rewarded هنگام ناوبری و تب سرویس.
   فاز 3: روز ۶۰ تا ۹۰ -> همان تبلیغات فاز ۲.
   فاز 4: روز ۹۰ به بعد -> قفل شدن کلیک پمپ بنزین‌ها و هدایت مستقیم به صفحه خرید پرمیوم.
  */

  // گرفتن ایمن شناسه دستگاه جهت جلوگیری از تکرار کد
  Future<String> _getDeviceId() async {
    String deviceId = "unknown_tanken_device";
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
      }
    } catch (e) {
      print("⚠️ Device Info retrieval failed: $e");
      deviceId = "backup_tanken_id";
    }
    return deviceId;
  }

  // متدی که توسط PurchaseManager زمان انقضای لایسنس صدا زده می‌شود
  Future<void> setPostPremiumFallbackDate(DateTime expirationDate) async {
    var box = Hive.box('settingsBox');
    postPremiumFallbackDate = expirationDate;
    
    // ذخیره در کش محلی
    await box.put('postPremiumFallbackDate', expirationDate.toIso8601String());
    
    // سینک آنی با سرور فایرستور جهت حفظ پایداری لایسنس کاربر
    try {
      String deviceId = await _getDeviceId();
      await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).update({
        'postPremiumFallbackDate': Timestamp.fromDate(expirationDate),
      });
    } catch (e) {
      print("⚠️ Cloud sync for fallback date failed: $e");
    }

    calculateCurrentStatus();
  }

  /// Local Hive only — no network. Call before first frame so banner/tier UI is correct.
  void hydrateFromLocalCache() {
    if (!Hive.isBoxOpen('settingsBox')) return;
    var box = Hive.box('settingsBox');
    String? localInstallStr = box.get('installDate');
    String? localPremiumStr = box.get('premiumPurchaseDate');
    String? localFallbackStr = box.get('postPremiumFallbackDate');

    if (localInstallStr != null) firstInstallDate = DateTime.parse(localInstallStr);
    if (localPremiumStr != null) premiumPurchaseDate = DateTime.parse(localPremiumStr);
    if (localFallbackStr != null) postPremiumFallbackDate = DateTime.parse(localFallbackStr);

    firstInstallDate ??= DateTime.now();
    calculateCurrentStatus();
  }

  Future<void> initializeAndSync() async {
    hydrateFromLocalCache();
    var box = Hive.box('settingsBox');
    
    // ۱. چتر امنیتی اول: خواندن سریع داده‌ها از کش محلی (Hive) تا برنامه معطل اینترنت نماند
    String? localInstallStr = box.get('installDate');
    String? localPremiumStr = box.get('premiumPurchaseDate');
    String? localFallbackStr = box.get('postPremiumFallbackDate');

    if (localInstallStr != null) firstInstallDate = DateTime.parse(localInstallStr);
    if (localPremiumStr != null) premiumPurchaseDate = DateTime.parse(localPremiumStr);
    if (localFallbackStr != null) postPremiumFallbackDate = DateTime.parse(localFallbackStr);

    String deviceId = await _getDeviceId();

    // ۲. چتر امنیتی دوم: سینک دوطرفه داده‌ها با فایرستور
    await ensureFirebaseInitialized();
    try {
      final docRef = FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data()!;
        firstInstallDate = (data['firstInstallDate'] as Timestamp).toDate();
        
        if (data['premiumPurchaseDate'] != null) {
          premiumPurchaseDate = (data['premiumPurchaseDate'] as Timestamp).toDate();
        }
        if (data['postPremiumFallbackDate'] != null) {
          postPremiumFallbackDate = (data['postPremiumFallbackDate'] as Timestamp).toDate();
        }

        // بروزرسانی کش محلی با آخرین اطلاعات دریافتی از سرور
        await box.put('installDate', firstInstallDate!.toIso8601String());
        if (premiumPurchaseDate != null) await box.put('premiumPurchaseDate', premiumPurchaseDate!.toIso8601String());
        if (postPremiumFallbackDate != null) await box.put('postPremiumFallbackDate', postPremiumFallbackDate!.toIso8601String());
      } else {
        // کاربر کاملا جدید است؛ ثبت زمان فعلی در لوکال و سرور
        firstInstallDate ??= DateTime.now();
        await box.put('installDate', firstInstallDate!.toIso8601String());
        
        await docRef.set({
          'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
          'premiumPurchaseDate': premiumPurchaseDate != null ? Timestamp.fromDate(premiumPurchaseDate!) : null,
          'postPremiumFallbackDate': postPremiumFallbackDate != null ? Timestamp.fromDate(postPremiumFallbackDate!) : null,
        });
      }
    } catch (e) {
      print("⚠️ Firestore sync failed or unavailable: $e");
      // در حالت کاملاً آفلاین، اگر هیو هم خالی بود مقدار پیش‌فرض دیفالت داده می‌شود
      firstInstallDate ??= DateTime.now();
    }

    // ۳. محاسبه وضعیت نهایی بر اساس داده‌های یکپارچه شده
    calculateCurrentStatus();
  }

  void calculateCurrentStatus() {
    if (firstInstallDate == null) return;
    DateTime now = DateTime.now();

    // بررسی اولویت اول: کاربر لایسنس پرمیوم فعال دارد یا خیر
    if (premiumPurchaseDate != null) {
      int diffPremium = isTestingMode 
          ? now.difference(premiumPurchaseDate!).inMinutes 
          : now.difference(premiumPurchaseDate!).inDays;
          
      int premiumDuration = 180; // دوره لایسنس ۱۸۰ روزه

      if (diffPremium < premiumDuration) {
        // لایسنس هنوز معتبر است
        PurchaseManager().isPremiumUser.value = true;
        daysUsed = 0;
        currentTier = 0;
        return;
      } else {
        // لایسنس منقضی شده است؛ محاسبه سیکل جدید زمانی بر اساس تاریخ انقضا
        PurchaseManager().isPremiumUser.value = false;
        
        DateTime expirationDate = premiumPurchaseDate!.add(
          Duration(minutes: isTestingMode ? premiumDuration : 0, days: isTestingMode ? 0 : premiumDuration)
        );
        
        // اگر فالبک دستی ست شده باشد ملاک قرار می‌گیرد، در غیر این صورت خود زمان انقضا
        DateTime baseDate = postPremiumFallbackDate ?? expirationDate;
        
        daysUsed = isTestingMode 
            ? now.difference(baseDate).inMinutes 
            : now.difference(baseDate).inDays;
      }
    } else if (postPremiumFallbackDate != null) {
      // حالتی که کاربر سابقه انقضا دارد اما اطلاعات خرید اصلی در دسترس نیست
      PurchaseManager().isPremiumUser.value = false;
      daysUsed = isTestingMode 
          ? now.difference(postPremiumFallbackDate!).inMinutes 
          : now.difference(postPremiumFallbackDate!).inDays;
    } else {
      // کاربر عادی بدون سابقه خرید پرمیوم؛ محاسبه بر اساس اولین نصب
      PurchaseManager().isPremiumUser.value = false;
      daysUsed = isTestingMode 
          ? now.difference(firstInstallDate!).inMinutes 
          : now.difference(firstInstallDate!).inDays;
    }

    // دسته‌بندی دقیق فازهای کاربری (Tiers)
    if (daysUsed < 3) {
      currentTier = 0;
    } else if (daysUsed >= 3 && daysUsed < 30) {
      currentTier = 1;
    } else if (daysUsed >= 30 && daysUsed < 60) {
      currentTier = 2;
    } else if (daysUsed >= 60 && daysUsed < 90) {
      currentTier = 3;
    } else {
      currentTier = 4; // روز ۹۰ به بعد: قفل کامل پمپ‌ها
    }
  }

  // خرید موفق: ۶ ماه جدید، یا اگر هنوز اعتبار دارد روی همان انباشت می‌شود
  Future<void> savePremiumPurchaseToServer() async {
    String deviceId = await _getDeviceId();
    DateTime now = DateTime.now();
    const int premiumDuration = 180;

    DateTime newExpiry;
    if (premiumPurchaseDate != null) {
      final currentExpiry = isTestingMode
          ? premiumPurchaseDate!.add(Duration(minutes: premiumDuration))
          : premiumPurchaseDate!.add(Duration(days: premiumDuration));
      if (now.isBefore(currentExpiry)) {
        newExpiry = isTestingMode
            ? currentExpiry.add(Duration(minutes: premiumDuration))
            : currentExpiry.add(Duration(days: premiumDuration));
      } else {
        newExpiry = isTestingMode
            ? now.add(Duration(minutes: premiumDuration))
            : now.add(Duration(days: premiumDuration));
      }
    } else {
      newExpiry = isTestingMode
          ? now.add(Duration(minutes: premiumDuration))
          : now.add(Duration(days: premiumDuration));
    }

    premiumPurchaseDate = isTestingMode
        ? newExpiry.subtract(Duration(minutes: premiumDuration))
        : newExpiry.subtract(Duration(days: premiumDuration));

    var box = Hive.box('settingsBox');
    await box.put('premiumPurchaseDate', premiumPurchaseDate!.toIso8601String());
    await box.put('isPremium', true);

    postPremiumFallbackDate = null;
    await box.delete('postPremiumFallbackDate');

    try {
      await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).set({
        'premiumPurchaseDate': Timestamp.fromDate(premiumPurchaseDate!),
        'postPremiumFallbackDate': null,
      }, SetOptions(merge: true));
    } catch (e) {
      print("⚠️ Cloud sync for premium purchase failed: $e");
    }

    calculateCurrentStatus();
  }

  // گتر همگام برای محاسبه دقیق روزهای باقی‌مانده از کل بازه ۹۰ روزه
  int get remainingFreeDays {
    final remaining = totalFreeDays - daysUsed;
    return remaining < 0 ? 0 : remaining;
  }

  // گتر همگام برای بررسی منقضی شدن کامل بازه رایگان ۹۰ روزه
  bool get isFreeTierExpired {
    return currentTier == 4 || daysUsed >= totalFreeDays;
  }

  // ⏱️ متد تست برای ریست کردن کامل تایم‌لاین در هر دو دیتابیس (مخصوص زمان توسعه)
  Future<void> resetTimelineForTesting() async {
    if (!isTestingMode) return; 

    firstInstallDate = DateTime.now();
    premiumPurchaseDate = null;
    postPremiumFallbackDate = null;
    daysUsed = 0;
    currentTier = 0;

    var box = Hive.box('settingsBox');
    await box.put('installDate', firstInstallDate!.toIso8601String());
    await box.delete('premiumPurchaseDate');
    await box.delete('postPremiumFallbackDate');

    try {
      String deviceId = await _getDeviceId();
      await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).set({
        'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
        'premiumPurchaseDate': null,
        'postPremiumFallbackDate': null,
      });
      print("✅ [Test] Firestore & Hive timeline reset successfully.");
    } catch (e) {
      print("⚠️ [Test] Firestore reset failed: $e");
    }

    calculateCurrentStatus();
  }
}
