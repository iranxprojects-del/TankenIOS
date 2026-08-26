import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class PurchaseManager {
  // پیاده‌سازی الگوی سنگلتون برای دسترسی یکپارچه در کل اپلیکیشن
  static final PurchaseManager _instance = PurchaseManager._internal();
  factory PurchaseManager() => _instance;
  PurchaseManager._internal();

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
    
    _initPurchaseStream();
    checkPremiumStatus();
  }

  /// بستن استریم جهت جلوگیری از لک حافظه (Memory Leak)
  void dispose() {
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

  // شناسه‌های تست گوگل (برای ریلیز شناسه‌های خود را جایگزین کنید)
  static String _bannerUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static  String _interstitialUnitId = 'ca-app-pub-3940256099942544/1033173712';// test interstitial
  static  String _rewardedUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  //eutravel_rewarded ca-app-pub-1909436077319120/4524576660
  String get bannerUnitId => _bannerUnitId;

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;

  void initAdUnits() {
    if (!AppTimelineManager().isTestingMode) { // real mode 
      _interstitialUnitId = 'ca-app-pub-1909436077319120/5488626786'; // real interstitial 
      _rewardedUnitId = 'ca-app-pub-1909436077319120/3065075207';
      _bannerUnitId = 'ca-app-pub-1909436077319120/7037632312'; // واقعی: Tanken_Banner_buttom
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
  int daysUsed = 0;
  int currentTier = 0; 
  // تعداد روزهای کل دوره رایگان (مثلاً ۷ روز)
  final int totalFreeDays = 90;

  /*
   فازهای زمانی تانکن (Tiers):
   فاز 0: روز ۰ تا ۳ -> هیچ تبلیغی نیست.
   فاز 1: روز ۳ تا ۳۰ -> فقط بنر کوچک پایین صفحه‌ها.
   فاز 2: روز ۳۰ تا ۶۰ -> بنر + تبلیغ بین‌صفحه‌ای هنگام تعویض تب‌ها (Parking, Diesel, E5, E10, Service).
   فاز 3: روز ۶۰ تا ۹۰ -> بنر + بین‌صفحه‌ای + ویدیو کامل هنگام کلیک روی ناوبری مپ.
   فاز 4: روز ۹۰ به بعد -> قفل شدن کلیک پمپ بنزین‌ها و هدایت مستقیم به صفحه خرید پرمیوم.
  */

  Future<void> initializeAndSync() async {
  String deviceId = "unknown_tanken_device";
  final deviceInfo = DeviceInfoPlugin();

  // ۱. گرفتن ایمن شناسه دستگاه (بدون تغییر)
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

  // ۲. چتر امنیتی اصلی برای ارتباط با فایرستور (کلود)
  try {
    final docRef = FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId);
    final docSnap = await docRef.get();

    if (docSnap.exists) {
      final data = docSnap.data()!;
      firstInstallDate = (data['firstInstallDate'] as Timestamp).toDate();
      if (data['premiumPurchaseDate'] != null) {
        premiumPurchaseDate = (data['premiumPurchaseDate'] as Timestamp).toDate();
      }
    } else {
      // کاربر جدید است
      firstInstallDate = DateTime.now();
      premiumPurchaseDate = null;
      await docRef.set({
        'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
        'premiumPurchaseDate': null,
      });
    }
  } catch (e) {
    // ۳. مدیریت خطا در صورت آفلاین بودن یا عدم وجود دیتابیس
    print("⚠️ Firestore sync failed or unavailable: $e");
    
    // حالت جایگزین (Fallback): اگر فایرستور خطا داد، اجازه نمی‌دهیم متغیرها null بمانند
    // تا متد محاسبه وضعیت (calculateCurrentStatus) با خطا مواجه نشود.
    if (firstInstallDate == null) {
      firstInstallDate = DateTime.now(); 
      // نکته اختیاری: اگر تمایل داشتید، اینجا می‌توانید تاریخ را از حافظه محلی (مثل Hive) بخوانید.
    }
  }

  // ۴. این متد حیاتی تحت هر شرایطی (چه آنلاین با موفقیت، چه آفلاین با خطا) باید اجرا شود.
  calculateCurrentStatus();
}

  void calculateCurrentStatus() {
    if (firstInstallDate == null) return;
    DateTime now = DateTime.now();

    // بررسی انقضای پرمیوم ۶ ماهه (۱۸۰ روزه) و ریست شدن لایف‌سایکل
    if (premiumPurchaseDate != null) {
      int diffPremium = isTestingMode 
          ? now.difference(premiumPurchaseDate!).inMinutes 
          : now.difference(premiumPurchaseDate!).inDays;
          
      int premiumDuration = 180; // ۱۸۰ روز (یا ۱۸۰ دقیقه در حالت تست)

      if (diffPremium < premiumDuration) {
        // کاربر هنوز پرمیوم معتبر دارد
        PurchaseManager().isPremiumUser.value = true;
        daysUsed = 0;
        currentTier = 0;
        return;
      } else {
        // ۶ ماه تمام شد! پرمیوم لغو و بر اساس تاریخ انقضا، سیکل از نو ریست می‌شود
        PurchaseManager().isPremiumUser.value = false;
        DateTime expirationDate = premiumPurchaseDate!.add(
          Duration(minutes: isTestingMode ? premiumDuration : 0, days: isTestingMode ? 0 : premiumDuration)
        );
        daysUsed = isTestingMode ? now.difference(expirationDate).inMinutes : now.difference(expirationDate).inDays;
      }
    } else {
      // پرمیوم نخریده، محاسبه زمان بر اساس اولین نصب
      PurchaseManager().isPremiumUser.value = false;
      daysUsed = isTestingMode ? now.difference(firstInstallDate!).inMinutes : now.difference(firstInstallDate!).inDays;
    }

    // دسته‌بندی کاربر بر اساس روزهای سپری شده
    if (daysUsed < 3) {
      currentTier = 0;
    } else if (daysUsed >= 3 && daysUsed < 30) {
      currentTier = 1;
    } else if (daysUsed >= 30 && daysUsed < 60) {
      currentTier = 2;
    } else if (daysUsed >= 60 && daysUsed < 90) {
      currentTier = 3;
    } else {
      currentTier = 4; // روز ۹۰ به بعد: قفل کامل کلیک روی پمپ‌ها
    }
  }

  // فراخوانی بعد از خرید موفق ۶ ماهه جهت هماهنگی با کلود
  Future<void> savePremiumPurchaseToServer() async {
    String deviceId = "unknown_tanken_device";
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var info = await deviceInfo.androidInfo;
      deviceId = info.id;
    }
    await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).update({
      'premiumPurchaseDate': Timestamp.fromDate(DateTime.now()),
    });
    await initializeAndSync();
  }

  // گتر برای محاسبه روزهای باقی‌مانده
  int get remainingFreeDays {
    if (firstInstallDate == null) return 0;
    
    // محاسبه اختلاف روزها بین الان و زمان اولین نصب
    final passed = isTestingMode 
        ? DateTime.now().difference(firstInstallDate!).inMinutes
        : DateTime.now().difference(firstInstallDate!).inDays;
         
    final remaining = totalFreeDays - passed;
    
    return remaining < 0 ? 0 : remaining;
  }

  // گتر برای بررسی اینکه آیا دوره رایگان تمام شده است یا خیر
  bool get isFreeTierExpired {
    if (firstInstallDate == null) return false;
    final passed = isTestingMode 
        ? DateTime.now().difference(firstInstallDate!).inMinutes
        : DateTime.now().difference(firstInstallDate!).inDays;
        
    return passed >= totalFreeDays;
  }

  // ⏱️ متد تست برای ریست کردن کامل تایم‌لاین (مخصوص زمان توسعه)
  Future<void> resetTimelineForTesting() async {
    if (!isTestingMode) return; // چتر امنیتی: اگر مود تست غیرفعال باشد هیچ کاری نمی‌کند

    firstInstallDate = DateTime.now();
    premiumPurchaseDate = null;
    daysUsed = 0;
    currentTier = 0;

    // به‌روزرسانی آنی فایرستور تا سرور هم ریست شود
    try {
      String deviceId = "unknown_tanken_device";
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
      }

      await FirebaseFirestore.instance.collection('tanken_users_timeline').doc(deviceId).set({
        'firstInstallDate': Timestamp.fromDate(firstInstallDate!),
        'premiumPurchaseDate': null,
      });
      print("✅ [Test] Firestore timeline reset successfully.");
    } catch (e) {
      print("⚠️ [Test] Firestore reset failed: $e");
    }

    // محاسبه مجدد وضعیت تایرها و روزها تا UI فوراً تغییر کند
    calculateCurrentStatus();
  }

}