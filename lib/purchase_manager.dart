
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
//import 'app_timeline_manager.dart';



class PurchaseManager {
  // پیاده‌سازی الگوی سنگلتون برای دسترسی یکپارچه در کل اپلیکیشن
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();

  final int premiumDurationDays = 180; // اعتبار ۶ ماهه اشتراک

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  
  // شناسه محصول شما در گوگل پلی کنسول
  final String premiumProductId = 'premiumunlock_tanken';// 'premiumunlock1';

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
      _handleError("خطا در ارتباط با استریم: $error");
    });
  }

  Future<void> _validatePremiumStatus() async {
    var box = Hive.box('settingsBox');
    bool hasPremiumFlag = box.get('isPremium', defaultValue: false);
    String? purchaseDateStr = box.get('premiumPurchaseDate');

    if (hasPremiumFlag && purchaseDateStr != null) {
      DateTime purchaseDate = DateTime.parse(purchaseDateStr);
      int daysPassed = DateTime.now().difference(purchaseDate).inDays;

      if (daysPassed > premiumDurationDays) {
        // 🔴 انقضای ۶ ماهه: لغو اشتراک
        isPremiumUser.value = false;
        await box.put('isPremium', false);

        // تنظیم تاریخ دقیق پایان اشتراک به عنوان مبدأ جدید فاز ۲
        DateTime expirationDate = purchaseDate.add(Duration(days: premiumDurationDays));
        await AppTimelineManager().setPostPremiumFallbackDate(expirationDate);
      } else {
        // 🟢 اشتراک همچنان معتبر است
        isPremiumUser.value = true;
      }
    } else {
      isPremiumUser.value = false;
    }
  }

  // پردازش نتایج تراکنش‌ها منطبق بر منطق main_restaurants.dart
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        isProcessing.value = true;
      } else {
        if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          
          // ۱. اول ثبت وضعیت فعال‌سازی در فایربیس (بسیار حیاتی)
          await _grantPremiumAccess();
          
          // ۲. بعد اعلام اتمام تراکنش به گوگل پلی برای جلوگیری از ریفاند خودکار
          if (purchaseDetails.pendingCompletePurchase) {
            await _inAppPurchase.completePurchase(purchaseDetails);
          }
          isProcessing.value = false;
          
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          isProcessing.value = false;
          _handleError(purchaseDetails.error?.message ?? "تراکنش ناموفق بود.");
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          isProcessing.value = false;
          _handleError("پرداخت توسط شما لغو شد.");
        }
      }
    }
  }

  // ثبت وضعیت فعال‌سازی و شناسه دستگاه در فایربیس
  Future<void> _grantPremiumAccess() async {
    String? deviceId = await _getDeviceId();
    if (deviceId != null) {
      try {
        await FirebaseFirestore.instance.collection('premium_users').doc(deviceId).set({
          'is_premium': true,
          'purchase_date': DateTime.now().toIso8601String(),
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

  /// شروع فرآیند خرید محصول بر اساس منطق ایمن محصول جدید
  Future<void> buyPremium() async {
    isProcessing.value = true;
    final bool available = await _inAppPurchase.isAvailable();
    if (!available) {
      isProcessing.value = false;
      _handleError("فروشگاه در حال حاضر در دسترس نیست.");
      return;
    }

    final Set<String> kIds = <String>{premiumProductId};
    final ProductDetailsResponse response = await _inAppPurchase.queryProductDetails(kIds);

    if (response.productDetails.isEmpty) {
      isProcessing.value = false;
      _handleError("محصول در گوگل پلی یافت نشد. شناسه بررسی شده: $premiumProductId");
      return;
    }

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: response.productDetails.first);
    await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
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

  // Android production ad units
  static const String _androidProdBanner = 'ca-app-pub-1909436077319120/7037632312';
  static const String _androidProdInterstitial = 'ca-app-pub-1909436077319120/5488626786';
  static const String _androidProdRewarded = 'ca-app-pub-1909436077319120/3065075207';

  // iOS production ad units — create in AdMob (Apps > iOS app > Ad units), then set ready flag.
  static const bool _iosProductionAdUnitsReady = false;
  static const String _iosProdBanner = 'ca-app-pub-1909436077319120/0000000000';
  static const String _iosProdInterstitial = 'ca-app-pub-1909436077319120/0000000000';
  static const String _iosProdRewarded = 'ca-app-pub-1909436077319120/0000000000';

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
      if (useTestAds || !_iosProductionAdUnitsReady) {
        _bannerUnitId = _iosTestBanner;
        _interstitialUnitId = _iosTestInterstitial;
        _rewardedUnitId = _iosTestRewarded;
        if (!useTestAds && kReleaseMode) {
          debugPrint(
            'AdMob iOS: using test ad units until _iosProductionAdUnitsReady is true '
            'and real iOS ad unit IDs are set in purchase_manager.dart',
          );
        }
      } else {
        _bannerUnitId = _iosProdBanner;
        _interstitialUnitId = _iosProdInterstitial;
        _rewardedUnitId = _iosProdRewarded;
      }
    } else {
      _bannerUnitId = _androidProdBanner;
      _interstitialUnitId = _androidProdInterstitial;
      _rewardedUnitId = _androidProdRewarded;
    }
  }

  // ۱. بارگذاری تبلیغ بین‌صفحه‌ای (فاز ۲ به بعد)
  void loadInterstitialAd() {
    if (!enableInterstitialAd || PurchaseManager().isPremiumUser.value) return;
    
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
    if (!enableRewardedAd || PurchaseManager().isPremiumUser.value) return;

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

  // نمایش تبلیغ بین‌صفحه‌ای هنگام سوئیچ تب‌ها
  void showInterstitialAd(VoidCallback onAdClosed) {
    int tier = AppTimelineManager().currentTier;
    if (!_isInterstitialLoaded || _interstitialAd == null || tier < 2 || PurchaseManager().isPremiumUser.value) {
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
    if (!_isRewardedLoaded || _rewardedAd == null || tier < 3 || PurchaseManager().isPremiumUser.value) {
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
   فاز 2: روز ۳۰ تا ۶۰ -> بنر + تبلیغ بین‌صفحه‌ای هنگام تعویض تب‌ها (Parking, Diesel, E5, E10, Service).
   فاز 3: روز ۶۰ تا ۹۰ -> بنر + بین‌صفحه‌ای + ویدیو کامل هنگام کلیک روی ناوبری مپ.
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

  // فراخوانی بعد از خرید موفق ۶ ماهه جهت هماهنگی آنی با سرور و هیو
  Future<void> savePremiumPurchaseToServer() async {
    String deviceId = await _getDeviceId();
    DateTime now = DateTime.now();
    
    var box = Hive.box('settingsBox');
    await box.put('premiumPurchaseDate', now.toIso8601String());
    
    // خرید جدید فالبک انقضای قبلی را کاملاً پاک می‌کند
    postPremiumFallbackDate = null;
    await box.delete('postPremiumFallbackDate');

    await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).update({
      'premiumPurchaseDate': Timestamp.fromDate(now),
      'postPremiumFallbackDate': null,
    });
    
    await initializeAndSync();
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
// class AppTimelineManager {
//   static final AppTimelineManager _instance = AppTimelineManager._internal();
//   factory AppTimelineManager() => _instance;
//   AppTimelineManager._internal();

//   // 🎯 فلگ تست: اگر true باشد، هر ۱ دقیقه معادل ۱ روز فرض می‌شود تا سریع تست کنید
//   bool isTestingMode = false; 

//   DateTime? firstInstallDate;
//   DateTime? premiumPurchaseDate;
//   int daysUsed = 0;
//   int currentTier = 0; 
//   // تعداد روزهای کل دوره رایگان (مثلاً ۷ روز)
//   final int totalFreeDays = 90;

//   /*
//    فازهای زمانی تانکن (Tiers):
//    فاز 0: روز ۰ تا ۳ -> هیچ تبلیغی نیست.
//    فاز 1: روز ۳ تا ۳۰ -> فقط بنر کوچک پایین صفحه‌ها.
//    فاز 2: روز ۳۰ تا ۶۰ -> بنر + تبلیغ بین‌صفحه‌ای هنگام تعویض تب‌ها (Parking, Diesel, E5, E10, Service).
//    فاز 3: روز ۶۰ تا ۹۰ -> بنر + بین‌صفحه‌ای + ویدیو کامل هنگام کلیک روی ناوبری مپ.
//    فاز 4: روز ۹۰ به بعد -> قفل شدن کلیک پمپ بنزین‌ها و هدایت مستقیم به صفحه خرید پرمیوم.
//   */

//    // متدی که توسط PurchaseManager زمان انقضای لایسنس صدا زده می‌شود
//  Future<void> setPostPremiumFallbackDate(DateTime expirationDate) async {
//   var box = Hive.box('settingsBox');
//   _postPremiumFallbackDate = expirationDate; // خط اصلاح شده
//   await box.put('postPremiumFallbackDate', expirationDate.toIso8601String());
// }


//   Future<void> initializeAndSync() async {
//   String deviceId = "unknown_tanken_device";
//   final deviceInfo = DeviceInfoPlugin();

//   // ۱. گرفتن ایمن شناسه دستگاه (بدون تغییر)
//   try {
//     if (Platform.isAndroid) {
//       var androidInfo = await deviceInfo.androidInfo;
//       deviceId = androidInfo.id;
//     } else if (Platform.isIOS) {
//       var iosInfo = await deviceInfo.iosInfo;
//       deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
//     }
//   } catch (e) {
//     print("⚠️ Device Info retrieval failed: $e");
//     deviceId = "backup_tanken_id";
//   }

//   // ۲. چتر امنیتی اصلی برای ارتباط با فایرستور (کلود)
//   try {
//     final docRef = FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId);
//     final docSnap = await docRef.get();

//     if (docSnap.exists) {
//       final data = docSnap.data()!;
//       firstInstallDate = (data['firstInstallDate'] as Timestamp).toDate();
//       if (data['premiumPurchaseDate'] != null) {
//         premiumPurchaseDate = (data['premiumPurchaseDate'] as Timestamp).toDate();
//       }
//     } else {
//       // کاربر جدید است
//       firstInstallDate = DateTime.now();
//       premiumPurchaseDate = null;
//       await docRef.set({
//         'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
//         'premiumPurchaseDate': null,
//       });
//     }
//   } catch (e) {
//     // ۳. مدیریت خطا در صورت آفلاین بودن یا عدم وجود دیتابیس
//     print("⚠️ Firestore sync failed or unavailable: $e");
    
//     // حالت جایگزین (Fallback): اگر فایرستور خطا داد، اجازه نمی‌دهیم متغیرها null بمانند
//     // تا متد محاسبه وضعیت (calculateCurrentStatus) با خطا مواجه نشود.
//     if (firstInstallDate == null) {
//       firstInstallDate = DateTime.now(); 
//       // نکته اختیاری: اگر تمایل داشتید، اینجا می‌توانید تاریخ را از حافظه محلی (مثل Hive) بخوانید.
//     }
//   }

//   // ۴. این متد حیاتی تحت هر شرایطی (چه آنلاین با موفقیت، چه آفلاین با خطا) باید اجرا شود.
//   calculateCurrentStatus();
// }

//   void calculateCurrentStatus() {
//     if (firstInstallDate == null) return;
//     DateTime now = DateTime.now();

//     // بررسی انقضای پرمیوم ۶ ماهه (۱۸۰ روزه) و ریست شدن لایف‌سایکل
//     if (premiumPurchaseDate != null) {
//       int diffPremium = isTestingMode 
//           ? now.difference(premiumPurchaseDate!).inMinutes 
//           : now.difference(premiumPurchaseDate!).inDays;
          
//       int premiumDuration = 180; // ۱۸۰ روز (یا ۱۸۰ دقیقه در حالت تست)

//       if (diffPremium < premiumDuration) {
//         // کاربر هنوز پرمیوم معتبر دارد
//         PurchaseManager().isPremiumUser.value = true;
//         daysUsed = 0;
//         currentTier = 0;
//         return;
//       } else {
//         // ۶ ماه تمام شد! پرمیوم لغو و بر اساس تاریخ انقضا، سیکل از نو ریست می‌شود
//         PurchaseManager().isPremiumUser.value = false;
//         DateTime expirationDate = premiumPurchaseDate!.add(
//           Duration(minutes: isTestingMode ? premiumDuration : 0, days: isTestingMode ? 0 : premiumDuration)
//         );
//         daysUsed = isTestingMode ? now.difference(expirationDate).inMinutes : now.difference(expirationDate).inDays;
//       }
//     } else {
//       // پرمیوم نخریده، محاسبه زمان بر اساس اولین نصب
//       PurchaseManager().isPremiumUser.value = false;
//       daysUsed = isTestingMode ? now.difference(firstInstallDate!).inMinutes : now.difference(firstInstallDate!).inDays;
//     }

//     // دسته‌بندی کاربر بر اساس روزهای سپری شده
//     if (daysUsed < 3) {
//       currentTier = 0;
//     } else if (daysUsed >= 3 && daysUsed < 30) {
//       currentTier = 1;
//     } else if (daysUsed >= 30 && daysUsed < 60) {
//       currentTier = 2;
//     } else if (daysUsed >= 60 && daysUsed < 90) {
//       currentTier = 3;
//     } else {
//       currentTier = 4; // روز ۹۰ به بعد: قفل کامل کلیک روی پمپ‌ها
//     }
//   }

//   // فراخوانی بعد از خرید موفق ۶ ماهه جهت هماهنگی با کلود
//   Future<void> savePremiumPurchaseToServer() async {
//     String deviceId = "unknown_tanken_device";
//     final deviceInfo = DeviceInfoPlugin();
//     if (Platform.isAndroid) {
//       var info = await deviceInfo.androidInfo;
//       deviceId = info.id;
//     }
//     await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).update({
//       'premiumPurchaseDate': Timestamp.fromDate(DateTime.now()),
//     });
//     await initializeAndSync();
//   }

//   // گتر برای محاسبه روزهای باقی‌مانده
//   int get remainingFreeDays {
//     if (firstInstallDate == null) return 0;
    
//     // محاسبه اختلاف روزها بین الان و زمان اولین نصب
//     final passed = isTestingMode 
//         ? DateTime.now().difference(firstInstallDate!).inMinutes
//         : DateTime.now().difference(firstInstallDate!).inDays;
         
//     final remaining = totalFreeDays - passed;
    
//     return remaining < 0 ? 0 : remaining;
//   }

//   // گتر برای بررسی اینکه آیا دوره رایگان تمام شده است یا خیر
//   bool get isFreeTierExpired {
//     if (firstInstallDate == null) return false;
//     final passed = isTestingMode 
//         ? DateTime.now().difference(firstInstallDate!).inMinutes
//         : DateTime.now().difference(firstInstallDate!).inDays;
        
//     return passed >= totalFreeDays;
//   }

//   // ⏱️ متد تست برای ریست کردن کامل تایم‌لاین (مخصوص زمان توسعه)
//   Future<void> resetTimelineForTesting() async {
//     if (!isTestingMode) return; // چتر امنیتی: اگر مود تست غیرفعال باشد هیچ کاری نمی‌کند

//     firstInstallDate = DateTime.now();
//     premiumPurchaseDate = null;
//     daysUsed = 0;
//     currentTier = 0;

//     // به‌روزرسانی آنی فایرستور تا سرور هم ریست شود
//     try {
//       String deviceId = "unknown_tanken_device";
//       final deviceInfo = DeviceInfoPlugin();
//       if (Platform.isAndroid) {
//         var androidInfo = await deviceInfo.androidInfo;
//         deviceId = androidInfo.id;
//       } else if (Platform.isIOS) {
//         var iosInfo = await deviceInfo.iosInfo;
//         deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
//       }

//       await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).set({
//         'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
//         'premiumPurchaseDate': null,
//       });
//       print("✅ [Test] Firestore timeline reset successfully.");
//     } catch (e) {
//       print("⚠️ [Test] Firestore reset failed: $e");
//     }

//     // محاسبه مجدد وضعیت تایرها و روزها تا UI فوراً تغییر کند
//     calculateCurrentStatus();
//   }

// }