import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import 'package:flutter/foundation.dart'; // برای تشخیص وب یا موبایل

import 'notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart'; // برای رفع ارور initFlutter
import 'package:workmanager/workmanager.dart'; // برای رفع ارور Workmanager
//import 'package:latlong/latlong.dart' as latLng;
import 'translations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'oil_analysis_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'app_license_manager.dart';
import 'purchase_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:in_app_update/in_app_update.dart';

import 'dart:io'; 
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:permission_handler/permission_handler.dart';

/// Parses the 2MB offline station file off the UI isolate.
Map<String, dynamic> parseOfflineStationsJson(String jsonString) {
  final List<dynamic> list = json.decode(jsonString) as List<dynamic>;
  final Map<String, dynamic> result = <String, dynamic>{};
  for (final s in list) {
    if (s is! Map) continue;
    final lat = s['lat'];
    final lng = s['lng'];
    if (lat is! num || lng is! num) continue;
    result['${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}'] = s;
  }
  return result;
}

class MaintenanceItem {
  final String key;
  final String title;
  final String websiteUrl;
  String mileage;
  String serviceDate;
  String note;
  String contact;
  String serviceCenter;
  int reminderDays;
  bool isConfigured;
  bool alarmEnabled;

  int? intervalKm;
  int? intervalDays;
  String tireType;

  MaintenanceItem({
    required this.key,
    required this.title,
    this.websiteUrl = '',
    this.mileage = '',
    this.serviceDate = '',
    this.note = '',
    this.contact = '',
    this.serviceCenter = '',
    this.reminderDays = 7,
    this.isConfigured = false,
    this.alarmEnabled = false,
    this.intervalKm = null,
    this.intervalDays = null,
    this.tireType = '4season',
  });

  Map<String, dynamic> toMap() => {
        'key': key,
        'title': title,
        'websiteUrl': websiteUrl,
        'mileage': mileage,
        'serviceDate': serviceDate,
        'note': note,
        'contact': contact,
        'serviceCenter': serviceCenter,
        'reminderDays': reminderDays,
        'isConfigured': isConfigured,
        'alarmEnabled': alarmEnabled,
        'intervalKm': intervalKm,
        'intervalDays': intervalDays,
        'tireType': tireType,
      };

  factory MaintenanceItem.fromMap(Map<String, dynamic> map) {
    return MaintenanceItem(
      key: map['key']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      websiteUrl: map['websiteUrl']?.toString() ?? '',
      mileage: map['mileage']?.toString() ?? '',
      serviceDate: map['serviceDate']?.toString() ?? '',
      note: map['note']?.toString() ?? '',
      contact: map['contact']?.toString() ?? '',
      serviceCenter: map['serviceCenter']?.toString() ?? '',
      reminderDays: int.tryParse(map['reminderDays']?.toString() ?? '') ?? 7,
      isConfigured: map['isConfigured'] ?? false,
      alarmEnabled: map['alarmEnabled'] ?? false,
      intervalKm: map['intervalKm'] != null ? int.tryParse(map['intervalKm'].toString()) : null,
      intervalDays: map['intervalDays'] != null ? int.tryParse(map['intervalDays'].toString()) : null,
      tireType: map['tireType']?.toString() ?? '4season',
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hive is required for language/settings on the first frame.
  try {
    await Hive.initFlutter();
    await Future.wait([
      Hive.openBox('settingsBox'),
      Hive.openBox('carServiceBox'),
      Hive.openBox('searchBox'),
      Hive.openBox('oilBox'),
    ]);
  } catch (e) {
    debugPrint('Hive init error: $e');
  }

  runApp(const AdakTenkenPro());

  // Heavy services after the first frame is scheduled so the UI is not blocked.
  _warmUpBackgroundServices();
}

void _warmUpBackgroundServices() {
  AppTimelineManager().hydrateFromLocalCache();

  AppTimelineManager().initializeAndSync().catchError((e) {
    debugPrint('Timeline sync error: $e');
  });

  Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  ).catchError((e) {
    debugPrint('Firebase init error: $e');
  });

  NotificationService.init().catchError((e) {
    debugPrint('Notification init error: $e');
  });

  AppAdManager().ensureSdkReady().then((_) {
    AppAdManager().loadInterstitialAd();
    AppAdManager().loadRewardedAd();
  }).catchError((e) {
    debugPrint('MobileAds init error: $e');
  });
}


class AdakTenkenPro extends StatelessWidget {
  const AdakTenkenPro({super.key});
  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
      valueListenable: Hive.box('settingsBox').listenable(keys: ['languageCode']),
      builder: (context, Box box, child) {
        final String currentLang = box.get('languageCode', defaultValue: 'fa');//defaultValue: 'en'

    return MaterialApp(
      debugShowCheckedModeBanner: false,
        title: translate('app_title', currentLang),
          // 💡 نکته طلایی برای راست‌چین شدن خودکار زبان فارسی:
        locale: Locale(currentLang),

        localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

        supportedLocales: supportedLanguages.map((l) => Locale(l['code']!)).toList(),
        home: FuelDashboard(currentLang: currentLang),
      
    );
    },
    );
  }
}

class FuelDashboard extends StatefulWidget {

  final String currentLang;
  //const FuelDashboard({super.key});
  const FuelDashboard({super.key, required this.currentLang});
  @override
  State<FuelDashboard> createState() => _FuelDashboardState();
}

class _FuelDashboardState extends State<FuelDashboard> {
  String selectedFuel = 'diesel'; // پیش‌فرض
  List stations = [];
  String? selectedStationId;
  bool isLoading = false;
  double _fontScale = 1.0;
  String carModel = "";
  String licensePlate = '';
  String workshopName = '';
  String workshopPhone = '';
  String insurancePhone = '';
  bool _isEditingWorkshopPhone = true;
  //String selectedServiceType = 'Oil Change';
  String selectedServiceType = 'cat_oil'; // یا 'oil' (دقیقاً همان کلیدی که در translations.dart داری)
  String currentKm = '';
  String highlightedMaintenanceKey = '';
  bool _isMaintenanceLoading = true;
  bool _bypassPremiumForNotification = false;
  int _selectedIndex = 0; // 0 برای بنزین، 1 برای سرویس‌ها
  String serviceView = 'history'; // مقدار پیش‌فرض: تاریخچه سرویس
  double userLat = 52.5200; // مقدار پیش‌فرض (برلین)
  double userLng = 13.4050;
  double searchRadius = 5.0; // شعاع جستجوی لیست؛ نقشه همیشه ۵ کیلومتر نشان می‌دهد
  static const double _mapVisibleRadiusKm = 5.0;
  List _mapStations = [];
  double _mapCenterLat = 52.5200;
  double _mapCenterLng = 13.4050;
  Timer? _mapMoveDebounce;
  bool _isLoadingMapStations = false;
  double? _pendingMapLoadLat;
  double? _pendingMapLoadLng;
  String? _pendingMapLoadKind;
  BannerAd? _bannerAd;
  bool enableEmailReminders = false;
  TextEditingController _emailController = TextEditingController();
  bool _isServiceUnlockedForSession = false;

  bool _isAdLoaded = false;
  final MapController _mapController = MapController();
  Map<String, dynamic>? oilAnalysis; // متغیری برای ذخیره تحلیل نفت
  List<MaintenanceItem> maintenanceItems = [];
  List<String> serviceCategories = [
    'Oil Change',
    'Timing Belt',
    'Brake Pads',
    'Spark Plugs',
    'Tires',
    'TÜV / Inspection',
  ];

  double dieselThreshold = 1.50; // قیمت هدف برای گازوئیل
  double e10Threshold = 1.70; // قیمت هدف برای E10
  double e5Threshold = 1.80; // قیمت هدف برای E5

  TextEditingController _priceController = TextEditingController(text: "1.50");
  double? myThreshold;
  // ذخیره اطلاعات امکانات: key آیدی پمپ بنزین است و value امکانات آن
  Map<String, Map<String, bool>> facilitiesCache = {};

  Map<String, dynamic> offlineStations = {};

  String fuelViewMode = 'map'; // 'map' or 'list'
  String parkingViewMode = 'map'; // 'map' or 'list'
  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<String> searchHistory = [];
  List<Map<String, String>> placeSuggestions = [];
  bool isSearchLoading = false;
  bool _useCompactMapSearch = false;

  bool _isBannerLoading = false;

  void _loadBannerAd() {
    if (PurchaseManager().isPremiumUser.value) return;
    if (_isAdLoaded) return;

    AppAdManager().ensureSdkReady().then((_) {
      if (!mounted || _isAdLoaded) return;
      _bannerAd?.dispose();
      _bannerAd = BannerAd(
        adUnitId: AppAdManager().bannerUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (_) {
            if (mounted) {
              setState(() {
                _isAdLoaded = true;
                _isBannerLoading = false;
              });
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('BannerAd failed to load: $error');
            ad.dispose();
            if (mounted) {
              setState(() {
                _isAdLoaded = false;
                _isBannerLoading = false;
                _bannerAd = null;
              });
            }
            Future<void>.delayed(const Duration(seconds: 6), () {
              if (mounted && !_isAdLoaded) _loadBannerAd();
            });
          },
        ),
      )..load();
      if (mounted) {
        setState(() => _isBannerLoading = true);
      }
    }).catchError((e) {
      debugPrint('Banner SDK error: $e');
      Future<void>.delayed(const Duration(seconds: 6), () {
        if (mounted && !_isAdLoaded) _loadBannerAd();
      });
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // پاک کردن تبلیغ از حافظه وقتی صفحه بسته می‌شود
    PurchaseManager().dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _priceController.dispose();
    _mapMoveDebounce?.cancel();
    super.dispose();
  }

  Future<void> _checkAndForceUpdate() async {
    try {
      var box = Hive.box('settingsBox');
      String? lastCheckStr = box.get('lastUpdateCheckDate');
      DateTime? lastCheckDate = lastCheckStr != null ? DateTime.tryParse(lastCheckStr) : null;
      DateTime now = DateTime.now();

      // بررسی اینکه آیا ۹۰ روز (حدود ۳ ماه) از آخرین بررسی گذشته است یا خیر
      if (lastCheckDate == null || now.difference(lastCheckDate).inDays >= 90) {
        
        // درخواست وضعیت آپدیت از گوگل پلی
        AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

        // اگر آپدیت جدیدی در گوگل پلی موجود بود
        if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
          // فورس کردن آپدیت (صفحه قفل می‌شود تا آپدیت نصب شود)
          await InAppUpdate.performImmediateUpdate();
        }
        
        // اگر آپدیت با موفقیت انجام شد یا آپدیتی وجود نداشت، تاریخ امروز را ثبت کن
        await box.put('lastUpdateCheckDate', now.toIso8601String());
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
      // در صورت قطعی اینترنت یا در دسترس نبودن گوگل پلی، اپلیکیشن کرش نمی‌کند و کاربر می‌تواند وارد شود
    }
  }


  void _loadEmailSettings() {
  var box = Hive.box('settingsBox');
  setState(() {
    enableEmailReminders = box.get('enableEmailReminders', defaultValue: false);
    _emailController.text = box.get('userEmail', defaultValue: '');
  });
}


void _showEmailSetupDialog(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    var box = Hive.box('settingsBox');
    
    // در صورت وجود، ایمیل قبلی را در تکست‌باکس نمایش بده
    emailController.text = box.get('userEmail', defaultValue: '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تنظیمات یادآور ایمیلی'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('برای دریافت هشدارهای سرویس دوره‌ای، ایمیل خود را وارد کنید:'),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'آدرس ایمیل',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('انصراف', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final email = emailController.text.trim();
              if (email.isNotEmpty && email.contains('@') && email.contains('.')) {
                // ذخیره ایمیل در لوکال استوریج
                box.put('userEmail', email);
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ایمیل با موفقیت ثبت و آلارم فعال شد.'),
                    backgroundColor: Colors.green,
                  ),
                );
                
                // در صورت نیاز به تست ارسال در همین لحظه، می‌توانید تابع زیر را از کامنت خارج کنید:
                _sendEmailReminder();
                
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('لطفا یک ایمیل معتبر وارد کنید.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('ذخیره و فعال‌سازی'),
          ),
        ],
      ),
    );
  }


// ذخیره آخرین مختصات در حافظه محلی
  Future<void> _saveLastLocation(double lat, double lng) async {
    var box = Hive.box('settingsBox');
    await box.put('lastLat', lat);
    await box.put('lastLng', lng);
  }

void _showTankenPremiumDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(translate('upgrade_to_premium', widget.currentLang), textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(translate('tanken_premium_desc', widget.currentLang),
          textAlign: TextAlign.justify,
          style: TextStyle(height: 1.5),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
            ),
            onPressed: () async {
              Navigator.pop(context);
              // صدا زدن متد خرید داخل درگاه پلی کنسول شما
              await PurchaseManager().buyPremium();
            },
            child: Text(translate('activate_premium_6months', widget.currentLang)),
          ),
        ],
      );
    },
  );
}



  Widget _buildBottomPremiumBanner(BuildContext context, String currentLang) {
  final timelineManager = AppTimelineManager();
  final purchaseManager = PurchaseManager();

  // اگر کاربر قبلاً پرمیوم را خریده باشد، این بنر کلاً مخفی می‌شود
  if (purchaseManager.isPremiumUser.value) {
    return const SizedBox.shrink();
  }

  final int tier = timelineManager.currentTier;
  final bool isExpired = timelineManager.isFreeTierExpired;
  final int days = timelineManager.remainingFreeDays;
  final bool isRtl = currentLang == 'fa';

  // اگر در فاز ۲ باشیم (Tier 3)
  if (tier == 3) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border(top: BorderSide(color: Colors.red.shade400, width: 2)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
          children: [
            Expanded(
              child: Text(
                isRtl 
                    ? 'اخطار: تنها $days روز تا قطعی کامل سرویس‌ها باقیست.'
                    : 'Warning: Only $days days left until full access is blocked.',
                style: TextStyle(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              ),
              onPressed: () => PurchaseManager().buyPremium(),
              child: Text(isRtl ? 'تمدید ۶ ماهه' : 'Extend 6 Months', style: const TextStyle(fontSize: 11)),
            ),
          ],
        ),
      ),
    );
  }

  // ۱. تنظیم متن وضعیت دوره رایگان
  String statusText = "";
  if (isExpired) {
    statusText = localizedStrings['free_tier_expired']![currentLang] ?? 'Free tier expired';
  } else {
    statusText = isRtl
        ? "$days ${localizedStrings['free_tier_remaining']![currentLang]}"
        : "${localizedStrings['free_tier_remaining']![currentLang]} $days";
  }

  // ۲. تنظیم متن دکمه خرید بر اساس زبان
  String buttonText = "";
  switch (currentLang) {
    case 'fa':
      buttonText = 'حذف آگهی + نسخه پرمیوم';
      break;
    case 'de':
      buttonText = 'Keine Werbung + Premium';
      break;
    case 'tr':
      buttonText = 'Reklamları Kaldır + Premium';
      break;
    default:
      buttonText = 'Remove Ads + Premium';
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      // اگر منقضی شده بود تم قرمز/هشدار و اگر باقی مانده بود تم آبی/حرفه‌ای
      color: isExpired ? Colors.red.shade50 : Colors.blue.shade50,
      border: Border(
        top: BorderSide(
          color: isExpired ? Colors.red.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
      ),
    ),
    child: SafeArea(
      top: false, // برای رعایت حاشیه پایین گوشی‌های آیفون و جدید
      child: Row(
        textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
        children: [
          // سمت متن: نمایش وضعیت روزها
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    color: isExpired ? Colors.red.shade900 : Colors.blue.shade900,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  currentLang == 'fa'
                      ? 'استفاده نامحدود از تمام امکانات اپلیکیشن'
                      : (currentLang == 'de' ? 'Unbegrenzter Zugriff auf alle Funktionen' : 'Unlimited access to all features'),
                  style: TextStyle(
                    color: isExpired ? Colors.red.shade700 : Colors.blue.shade700,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // سمت دکمه: دکمه اکشن برای خرید فوری
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isExpired ? Colors.red.shade700 : Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            onPressed: () {
              // صدا زدن مستقیم متد خرید از مدیریت خرید شما
              PurchaseManager().buyPremium();
            },
            child: Text(
              buttonText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

  // ۱. درخواست نوتیفیکیشن برای اولین اجرای برنامه
Future<void> _checkNotificationPermissionOnFirstLaunch() async {
  var settingsBox = await Hive.openBox('settingsBox');
  bool isFirstLaunch = settingsBox.get('isFirstLaunch', defaultValue: true);

  if (isFirstLaunch) {
    // درخواست اجازه نوتیفیکیشن از سیستم‌عامل
    final bool granted = await NotificationService.requestPermission(); // یا متد پیش‌فرض خودت
    
    // پرچم را کاذب می‌کنیم تا در اجراهای بعدی این پاپ‌آپ باز نشود
    await settingsBox.put('isFirstLaunch', false);
  }
}

// ۲. نمایش دیسکلیمور قانونی لوکیشن و گرفتن تاییدیه از کاربر
Future<bool> _showLegalLocationDisclaimer(BuildContext context) async {
  bool userConsent = false;

  await showDialog(
    context: context,
    barrierDismissible: false, // کاربر حتماً باید یکی از دکمه‌ها را انتخاب کند
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel, color: Colors.blueAccent),
            SizedBox(width: 10),
            Expanded( // 👈 اضافه شدن برای جلوگیری از Overflow
      child:Text('Legal Privacy Consent', softWrap: true,),
            ),
          ],
        ),
        content: const Text(
          'In compliance with data protection regulations (GDPR), '
          'this application requires your explicit consent to access your device\'s location. '
          'This data is used solely to fetch nearby gas station prices in real-time. '
          '\n\nImportant: Your location data is processed locally, transmitted securely via encrypted protocols, '
          'and is NEVER stored, saved, or tracked on any server or database.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () {
              userConsent = false;
              Navigator.of(context).pop();
            },
            child: const Text('Decline', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () {
              userConsent = true;
              Navigator.of(context).pop();
            },
            child: const Text('Accept & Proceed'),
          ),
        ],
      );
    },
  );

  return userConsent;
}


  Future<Position> _getFastPosition({bool preferFresh = false}) async {
    if (!preferFresh) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null) return last;
      } catch (_) {}
    }
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
      );
    } catch (_) {
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return last;
      rethrow;
    }
  }

  Future<void> fetchPrices({double? lat, double? lng}) async {

    if (!AppLicenseManager.isFeatureActive('oil_price')) {
      AppLicenseManager.showPremiumDialog(context);
      return;
    }

    setState(() => isLoading = true);

    try {
      double searchLat = lat ?? 0.0;
      double searchLng = lng ?? 0.0;

      if (lat == null || lng == null) {
        // 1. Check kardan va darkhast-e Permission be tore dasti
        LocationPermission permission = await Geolocator.checkPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          permission = await Geolocator.requestPermission();
        }

        // Agar karbar ejaze nadad, loading ra bando va kharej sho
        if (permission != LocationPermission.always &&
            permission != LocationPermission.whileInUse) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Location permission is required to find local stations.",
              ),
            ),
          );
          return;
        }

        // 2. Gereftan-e location-e daghigh
        Position position = await _getFastPosition();

        searchLat = position.latitude;
        searchLng = position.longitude;
      }

      setState(() {
        userLat = searchLat;
        userLng = searchLng;
      });
      _saveLastLocation(searchLat, searchLng);

      const apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
      final listRadius = _fuelSearchRadiusKm > 25.0 ? 25.0 : _fuelSearchRadiusKm;
      final url =
          "https://creativecommons.tankerkoenig.de/json/list.php?lat=$searchLat&lng=$searchLng&rad=$listRadius&sort=price&type=$selectedFuel&apikey=$apiKey";

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          setState(() {
            stations = (data['stations'] as List).where((s) {
              return s['price'] != null && s['price'] > 0;
            }).toList();

            stations.sort((a, b) => a['price'].compareTo(b['price']));
            _restoreSelectedStationAtTop();
            _syncMapStationsFromList(lat: searchLat, lng: searchLng);
            isLoading = false;
          });
          _fitMapToSearchResults();
        } else {
          debugPrint('Tankerkoenig error: ${data['message']}');
          setState(() => isLoading = false);
        }
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }


  Future<void> _loadSearchHistory() async {
    var box = await Hive.openBox('searchBox');
    final saved = box.get('history', defaultValue: <String>[]) as List<dynamic>;
    setState(() {
      searchHistory = saved.cast<String>().toList();
    });
  }


  Future<void> _clearSearchHistory() async {
  var box = await Hive.openBox('searchBox');
  await box.clear(); // پاک کردن کل اطلاعات باکس
  setState(() {
    searchHistory = []; // خالی کردن لیست در لحظه
  });
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Search history cleared.')),
  );
}

Future<void> _saveSearchHistory(String query) async {
  String cleanQuery = query.trim();
  if (cleanQuery.isEmpty) return;

  var box = await Hive.openBox('searchBox');
  // گرفتن لیست قدیمی یا ساخت یک لیست خالی جدید
  List<String> history = (box.get('history', defaultValue: []) as List).cast<String>().toList();

  // حذف موارد تکراری (حتی با حروف کوچک و بزرگ متفاوت)
  history.removeWhere((item) => item.toLowerCase() == cleanQuery.toLowerCase());

  // اضافه کردن مورد جدید به اول لیست
  history.insert(0, cleanQuery);

  // نگه داشتن فقط ۱۰ مورد آخر
  if (history.length > 10) history.removeLast();

  await box.put('history', history);
  
  setState(() {
    searchHistory = history; // آپدیت کردن UI
  });
}

  Future<List<Map<String, String>>> _searchPlace(String query) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
      'q': query,
      'format': 'json',
      'limit': '6',
      'countrycodes': 'de',
    });

    final response = await http
        .get(
          uri,
          headers: {
            'User-Agent': 'GermanyFuelApp/1.0',
            'Accept': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<Map<String, String>>((dynamic item) {
        return <String, String>{
          'display_name': item['display_name'] ?? query,
          'lat': item['lat']?.toString() ?? '',
          'lon': item['lon']?.toString() ?? '',
        };
      }).toList();
    }
    return [];
  }

  Future<void> _updatePlaceSuggestions(String query) async {
    if (query.trim().length < 3) {
      setState(() {
        placeSuggestions = [];
      });
      return;
    }

    try {
      final suggestions = await _searchPlace(query);
      setState(() {
        placeSuggestions = suggestions;
      });
    } catch (e) {
      print('Suggestion Error: $e');
    }
  }

  Future<void> _searchStations(double lat, double lng, [String? query]) async {
    if (selectedFuel == 'ev') {
      await fetchEVStations(lat: lat, lng: lng);
    } else if (selectedFuel == 'parking') {
      bool isNumeric = double.tryParse(query ?? '') != null;
      await fetchParkingData(lat: lat, lng: lng, postalCode: isNumeric ? query : null,
        cityName: !isNumeric ? query : null,);
    } else {
      await fetchPrices(lat: lat, lng: lng);
    }
  }

Future<void> _performSearch() async {
  final query = _searchController.text.trim();
  if (query.isEmpty) {
    await _searchNearby();
    return;
  }

  setState(() {
    isSearchLoading = true;
  });

  try {
    final results = await _searchPlace(query);
    if (results.isEmpty) {
      
      if (selectedFuel == 'parking') {
             bool isNumeric = double.tryParse(query) != null;
             await fetchParkingData(
                postalCode: isNumeric ? query : null,
                cityName: !isNumeric ? query : null,
             );
             _activateFullMapSearchView();
             return; 
          }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          // const SnackBar(
          //   content: Text('No location found. Try a postal code or city name.'),
          // ),
          SnackBar(
            content: Text(translate('error_no_location', widget.currentLang)),
          ),
        );
      }
      return;
    }

    final place = results.first;
    final lat = double.tryParse(place['lat'] ?? '');
    final lng = double.tryParse(place['lon'] ?? '');
    
    if (lat == null || lng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to determine coordinates.')),
        );
      }
      return;
    }

    // ۱. آپدیت مختصات در State برای استفاده در تب‌های مختلف
    setState(() {
      userLat = lat;
      userLng = lng;
    });
    _saveLastLocation(lat, lng);

    // ۳. به‌روزرسانی فیلد متن و ذخیره در تاریخچه (بدون تکراری)
    final displayName = place['display_name'] ?? query;
    _searchController.text = displayName;
    await _saveSearchHistory(displayName);

    // ۴. دریافت لیست ایستگاه‌های جدید
    await _searchStations(lat, lng, query);
    _activateFullMapSearchView();
    
  } catch (e) {
    print('Search Error: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Search failed. Please try again.')),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        isSearchLoading = false;
        placeSuggestions = [];
      });
      _searchFocusNode.unfocus();
    }
  }
}


Future<void> _searchNearby() async {
  // ۱. اول از همه پاپ‌آپ قانونی را نشان بده
  bool hasConsent = await _showLegalLocationDisclaimer(context);
  
  // اگر تایید نکرد، کلاً عملیات را متوقف کن
  if (!hasConsent) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Search cancelled. Location permission is required.')),
    );
    return;
  }

  // ۲. اگر کاربر تایید کرد، حالا پردازش را شروع کن
  setState(() {
    isSearchLoading = true;
    _searchController.clear();
  });

  try {
    // بررسی اجازه دسترسی سیستمی اندروید/آی‌او‌اس
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        throw 'Location permissions are denied.';
      }
    }

    // گرفتن موقعیت
    Position position = await _getFastPosition(preferFresh: true);

    userLat = position.latitude;
    userLng = position.longitude;

    // گرفتن ایستگاه‌ها
    await _searchStations(userLat, userLng);
    _fitMapToSearchResults();
    _activateFullMapSearchView();

  } catch (e) {
    debugPrint('Location Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => isSearchLoading = false);
      _searchFocusNode.unfocus();
    }
  }
}


  void _selectFuelStation(Map<String, dynamic> station) {
    final stationId = station['id']?.toString() ?? '';
    if (stationId.isEmpty) return;

    if (selectedStationId == stationId) {
      setState(() {
        selectedStationId = null;
      });
      Hive.box('settingsBox').delete('selectedStationId');
      return;
    }

    setState(() {
      selectedStationId = stationId;
      final currentIndex = stations.indexWhere((s) => s['id']?.toString() == stationId);
      if (currentIndex > 0) {
        final selectedStation = stations.removeAt(currentIndex);
        stations.insert(0, selectedStation);
      }
    });
    Hive.box('settingsBox').put('selectedStationId', stationId);
  }

  void _restoreSelectedStationAtTop() {
    if (selectedStationId == null) return;
    final currentIndex = stations.indexWhere((s) => s['id']?.toString() == selectedStationId);
    if (currentIndex > 0) {
      final selectedStation = stations.removeAt(currentIndex);
      stations.insert(0, selectedStation);
    }
  }

  double get _fuelSearchRadiusKm => searchRadius > 50.0 ? 50.0 : searchRadius;

  ll.LatLng? _pointOfStation(dynamic s) {
    final lat = (s['lat'] as num?)?.toDouble();
    final lng = (s['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return ll.LatLng(lat, lng);
  }

  String _stationKey(dynamic s) {
    final id = s['id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '${s['lat']}_${s['lng']}';
  }

  List get _visibleMapStations {
    if (_mapStations.isNotEmpty) return _mapStations;
    return _filterWithinMapRadius(stations, _mapCenterLat, _mapCenterLng);
  }

  List _filterWithinMapRadius(List source, double lat, double lng) {
    return source.where((s) {
      final point = _pointOfStation(s);
      if (point == null) return false;
      final meters = Geolocator.distanceBetween(
        lat,
        lng,
        point.latitude,
        point.longitude,
      );
      return meters <= _mapVisibleRadiusKm * 1000;
    }).toList();
  }

  List _mergeMapStations(List primary, List extra, double lat, double lng) {
    final merged = <String, dynamic>{};
    for (final s in _filterWithinMapRadius([...primary, ...extra], lat, lng)) {
      merged[_stationKey(s)] = s;
    }
    return merged.values.toList();
  }

  void _syncMapStationsFromList({double? lat, double? lng}) {
    _mapCenterLat = lat ?? userLat;
    _mapCenterLng = lng ?? userLng;
    _mapStations = _filterWithinMapRadius(stations, _mapCenterLat, _mapCenterLng);
  }

  void _onUserMovedMap(ll.LatLng center, {String? mapKind}) {
    final movedMeters = Geolocator.distanceBetween(
      _mapCenterLat,
      _mapCenterLng,
      center.latitude,
      center.longitude,
    );
    if (movedMeters < 200) return;
    _mapMoveDebounce?.cancel();
    _mapMoveDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      _mapCenterLat = center.latitude;
      _mapCenterLng = center.longitude;
      setState(() {
        _mapStations = _filterWithinMapRadius(
          [..._mapStations, ...stations],
          _mapCenterLat,
          _mapCenterLng,
        );
      });
      _loadStationsForMapCenter(
        _mapCenterLat,
        _mapCenterLng,
        mapKind: mapKind,
      );
    });
  }

  Future<void> _loadStationsForMapCenter(
    double lat,
    double lng, {
    String? mapKind,
  }) async {
    final kind = mapKind ?? selectedFuel;
    if (_isLoadingMapStations) {
      _pendingMapLoadLat = lat;
      _pendingMapLoadLng = lng;
      _pendingMapLoadKind = kind;
      return;
    }
    _isLoadingMapStations = true;
    _pendingMapLoadLat = null;
    _pendingMapLoadLng = null;
    _pendingMapLoadKind = null;
    if (mounted) setState(() {});
    try {
      List loaded = [];
      if (kind == 'parking') {
        loaded = await _fetchParkingAround(lat, lng, _mapVisibleRadiusKm);
      } else if (kind == 'ev') {
        loaded = await _fetchEvAround(lat, lng, _mapVisibleRadiusKm);
      } else {
        loaded = await _fetchFuelAround(lat, lng, _mapVisibleRadiusKm);
      }
      if (!mounted) return;
      setState(() {
        _mapStations = _mergeMapStations(loaded, stations, lat, lng);
      });
    } catch (e) {
      debugPrint('Map-move station load failed: $e');
    } finally {
      _isLoadingMapStations = false;
      final nextLat = _pendingMapLoadLat;
      final nextLng = _pendingMapLoadLng;
      final nextKind = _pendingMapLoadKind;
      if (nextLat != null && nextLng != null) {
        _pendingMapLoadLat = null;
        _pendingMapLoadLng = null;
        _pendingMapLoadKind = null;
        await _loadStationsForMapCenter(nextLat, nextLng, mapKind: nextKind);
      } else if (mounted) {
        setState(() {});
      }
    }
  }

  Future<List> _fetchFuelAround(double lat, double lng, double radiusKm) async {
    const apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
    final rad = radiusKm > 25.0 ? 25.0 : radiusKm;
    final url =
        "https://creativecommons.tankerkoenig.de/json/list.php?lat=$lat&lng=$lng&rad=$rad&sort=price&type=$selectedFuel&apikey=$apiKey";
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) return [];
    final data = json.decode(response.body);
    if (data['ok'] != true) return [];
    final list = (data['stations'] as List).where((s) {
      return s['price'] != null && s['price'] > 0;
    }).toList();
    list.sort((a, b) => a['price'].compareTo(b['price']));
    return list;
  }

  Future<List> _fetchEvAround(double lat, double lng, double radiusKm) async {
    const apiKey = "1496f02a-4cf6-45fd-90e9-83bb67a3cdab";
    final url =
        "https://api.openchargemap.io/v3/poi/?output=json&countrycode=DE&latitude=$lat&longitude=$lng&distance=$radiusKm&distanceunit=KM&maxresults=50&compact=true&verbose=false&key=$apiKey";
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "User-Agent":
            "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36",
        "Accept": "application/json",
      },
    ).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return [];
    final List<dynamic> data = json.decode(response.body);
    return data.map((item) {
      var connections = item['Connections'] as List?;
      String power = "N/A";
      if (connections != null && connections.isNotEmpty) {
        power = "${connections[0]['PowerKW'] ?? '?'}kW";
      }
      var addr = item['AddressInfo'] ?? {};
      return {
        'id': item['ID']?.toString() ?? '',
        'name': addr['Title'] ?? 'Unnamed Station',
        'brand': 'EV Charging',
        'street': addr['AddressLine1'] ?? 'No Address',
        'houseNumber': '',
        'lat': addr['Latitude'] ?? 0.0,
        'lng': addr['Longitude'] ?? 0.0,
        'price': '⚡ $power',
        'isOpen': true,
        'dist': (addr['Distance'] ?? 0).toStringAsFixed(1),
      };
    }).toList();
  }

  Future<List> _fetchParkingAround(double lat, double lng, double radiusKm) async {
    final elements = await _queryOverpassParking(
      lat: lat,
      lng: lng,
      radiusMeters: (radiusKm * 1000).round(),
    );
    return _parkingStationsFromOverpass(elements, lat, lng);
  }

  String _mapMarkerLabel(dynamic s) {
    final price = s['price']?.toString() ?? '';
    if (selectedFuel == 'parking' || price == 'P') return 'P';
    if (selectedFuel == 'ev' || price.contains('⚡') || price.contains('kW')) {
      return price;
    }
    return '€$price';
  }

  double? _overpassLat(dynamic element) {
    final direct = (element['lat'] as num?)?.toDouble();
    if (direct != null) return direct;
    final center = element['center'];
    if (center is Map) return (center['lat'] as num?)?.toDouble();
    return null;
  }

  double? _overpassLng(dynamic element) {
    final direct = (element['lon'] as num?)?.toDouble();
    if (direct != null) return direct;
    final center = element['center'];
    if (center is Map) return (center['lon'] as num?)?.toDouble();
    return null;
  }

  bool _isUsableParkingElement(dynamic element) {
    final tags = element['tags'];
    if (tags is! Map) return false;
    final access = (tags['access'] ?? '').toString().toLowerCase();
    if (access == 'private' || access == 'no') return false;
    final kind = (tags['parking'] ?? '').toString().toLowerCase();
    if (kind == 'garage_boxes' || kind == 'sheds') return false;
    // Stray parking *nodes* are often dropped on a station/road centroid.
    // Real lots on OSM are almost always ways/relations (the blue P on the map).
    if (element['type'] == 'node' && kind.isEmpty) return false;
    return _overpassLat(element) != null && _overpassLng(element) != null;
  }

  List<Map<String, dynamic>> _parkingStationsFromOverpass(
    List<dynamic> elements,
    double originLat,
    double originLng,
  ) {
    final seen = <String>{};
    final parsed = <Map<String, dynamic>>[];
    for (final element in elements) {
      if (!_isUsableParkingElement(element)) continue;
      final lat = _overpassLat(element)!;
      final lng = _overpassLng(element)!;
      final key = '${lat.toStringAsFixed(4)}_${lng.toStringAsFixed(4)}';
      if (!seen.add(key)) continue;
      final tags = Map<String, dynamic>.from(element['tags'] as Map);
      final name = (tags['name'] ?? '').toString().trim();
      final street = (tags['street'] ?? tags['addr:street'] ?? '').toString();
      final distKm = Geolocator.distanceBetween(originLat, originLng, lat, lng) / 1000.0;
      parsed.add({
        'id': 'osm_${element['type']}_${element['id']}',
        'name': name.isEmpty ? 'Parkplatz' : name,
        'brand': 'Parking',
        'street': street.isEmpty ? 'Parkplatz' : street,
        'houseNumber': (tags['addr:housenumber'] ?? '').toString(),
        'lat': lat,
        'lng': lng,
        'price': 'P',
        'isOpen': true,
        'free_slots': 10,
        'dist': distKm.toStringAsFixed(1),
        'distKm': distKm,
      });
    }
    parsed.sort((a, b) => (a['distKm'] as double).compareTo(b['distKm'] as double));
    if (parsed.length > 80) return parsed.take(80).toList();
    return parsed;
  }

  Future<List<dynamic>> _queryOverpassParking({
    required double lat,
    required double lng,
    required int radiusMeters,
  }) async {
    final query = '''
[out:json][timeout:25];
(
  way(around:$radiusMeters,$lat,$lng)["amenity"="parking"];
  relation(around:$radiusMeters,$lat,$lng)["amenity"="parking"];
  node(around:$radiusMeters,$lat,$lng)["amenity"="parking"]["parking"];
);
out center;
''';
    const endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];
    for (final endpoint in endpoints) {
      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                'User-Agent': 'GermanyFuelApp/1.0',
                'Accept': 'application/json',
              },
              body: query,
            )
            .timeout(const Duration(seconds: 25));
        if (response.statusCode != 200) continue;
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['elements'] is List) {
          return List<dynamic>.from(decoded['elements'] as List);
        }
      } catch (e) {
        debugPrint('Overpass $endpoint failed: $e');
      }
    }
    return [];
  }

  void _fitMapToSearchResults() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // ~5 km from center (map always shows this window, even if the list is wider)
      const dLat = 0.045;
      const dLng = 0.07;
      try {
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: LatLngBounds(
              ll.LatLng(_mapCenterLat - dLat, _mapCenterLng - dLng),
              ll.LatLng(_mapCenterLat + dLat, _mapCenterLng + dLng),
            ),
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 20),
            maxZoom: 15,
          ),
        );
      } catch (e) {
        debugPrint('Map fit skipped: $e');
      }
    });
  }

  Future<void> _openMap(double lat, double lng) async {
    if (!AppLicenseManager.isFeatureActive('open_link_navigator')) {
      AppLicenseManager.showPremiumDialog(context);
      return;
    }

    int tier = AppTimelineManager().currentTier;
    bool isPremium = PurchaseManager().isPremiumUser.value;

    // 🔒 فاز ۴ (روز ۹۰ به بعد): قفل کامل پمپ‌بنزین‌ها و هدایت به خرید
    if (!isPremium && tier >= 4) {
      _showTankenPremiumDialog(context); // دیالوگی که در بدنه اصلی دارید
      return;
    }

    // 📺 فاز ۳ (روز ۶۰ تا ۹۰): نمایش ویدیو طولانی قبل از باز شدن نقشه
    if (!isPremium && tier == 3) {
      AppAdManager().showNavigationRewardedAd(() async {
        await _openNavigation(destLat: lat, destLng: lng);
      });
      return; // توقف اجرای خطوط بعدی تا زمان اتمام تبلیغ
    }

    await _openNavigation(destLat: lat, destLng: lng);
  }

  bool get _hasValidUserLocation => userLat != 0.0 && userLng != 0.0;

  bool get _isIosDevice => !kIsWeb && Platform.isIOS;

  Future<void> _openNavigation({
    double? destLat,
    double? destLng,
    String? searchQuery,
  }) async {
    if (_isIosDevice) {
      await _showNavigateWithSheet(
        destLat: destLat,
        destLng: destLng,
        searchQuery: searchQuery,
      );
      return;
    }
    await _launchGoogleMaps(
      destLat: destLat,
      destLng: destLng,
      searchQuery: searchQuery,
    );
  }

  Future<bool> _tryLaunchUrl(Uri url) async {
    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('Launch failed for $url: $e');
    }
    // https را حتی اگر canLaunchUrl false بود دوباره امتحان کن
    if (url.scheme == 'http' || url.scheme == 'https') {
      try {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } catch (e) {
        debugPrint('HTTPS launch failed for $url: $e');
      }
    }
    return false;
  }

  Future<bool> _launchFirstAvailable(List<Uri> urls) async {
    for (final url in urls) {
      if (await _tryLaunchUrl(url)) return true;
    }
    return false;
  }

  Future<void> _launchAppleMaps({
    double? destLat,
    double? destLng,
    String? searchQuery,
  }) async {
    final List<Uri> urls;
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim();
      urls = [
        Uri.parse('maps://?q=${Uri.encodeComponent(q)}'),
        Uri.https('maps.apple.com', '/', {'q': q}),
      ];
    } else {
      final dest = '$destLat,$destLng';
      final origin = _hasValidUserLocation ? '$userLat,$userLng' : null;
      urls = [
        Uri.parse(
          origin != null
              ? 'maps://?saddr=$origin&daddr=$dest&dirflg=d'
              : 'maps://?daddr=$dest&dirflg=d',
        ),
        Uri.https('maps.apple.com', '/', {
          'daddr': dest,
          'dirflg': 'd',
          if (origin != null) 'saddr': origin,
        }),
      ];
    }

    final opened = await _launchFirstAvailable(urls);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('map_launch_failed', widget.currentLang))),
      );
    }
  }

  Future<void> _launchGoogleMaps({
    double? destLat,
    double? destLng,
    String? searchQuery,
  }) async {
    final List<Uri> urls;
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim();
      urls = [
        Uri.parse(
          'comgooglemaps://?q=${Uri.encodeComponent(q)}',
        ),
        Uri.https('www.google.com', '/maps/search/', {
          'api': '1',
          'query': q,
        }),
      ];
    } else {
      final dest = '$destLat,$destLng';
      final origin = _hasValidUserLocation ? '$userLat,$userLng' : null;
      if (!kIsWeb && Platform.isAndroid) {
        urls = [
          Uri.parse('google.navigation:q=$dest&mode=d'),
          Uri.parse('geo:$dest?q=$dest'),
          Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            if (origin != null) 'origin': origin,
            'destination': dest,
            'travelmode': 'driving',
          }),
        ];
      } else {
        urls = [
          Uri.parse(
            origin != null
                ? 'comgooglemaps://?saddr=$origin&daddr=$dest&directionsmode=driving'
                : 'comgooglemaps://?daddr=$dest&directionsmode=driving',
          ),
          Uri.parse('google.navigation:q=$dest&mode=d'),
          Uri.parse('geo:$dest?q=$dest'),
          Uri.https('www.google.com', '/maps/dir/', {
            'api': '1',
            if (origin != null) 'origin': origin,
            'destination': dest,
            'travelmode': 'driving',
          }),
        ];
      }
    }

    final opened = await _launchFirstAvailable(urls);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('map_launch_failed', widget.currentLang))),
      );
    }
  }

  Future<void> _showNavigateWithSheet({
    double? destLat,
    double? destLng,
    String? searchQuery,
  }) async {
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  translate('navigate_with', widget.currentLang),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade200,
                    child: const Icon(Icons.map, color: Colors.black87),
                  ),
                  title: Text(translate('apple_maps', widget.currentLang)),
                  subtitle: Text(
                    translate('apple_maps_subtitle', widget.currentLang),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _launchAppleMaps(
                      destLat: destLat,
                      destLng: destLng,
                      searchQuery: searchQuery,
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade50,
                    child: const Icon(Icons.public, color: Colors.blue),
                  ),
                  title: Text(translate('google_maps', widget.currentLang)),
                  subtitle: Text(
                    translate('google_maps_subtitle', widget.currentLang),
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _launchGoogleMaps(
                      destLat: destLat,
                      destLng: destLng,
                      searchQuery: searchQuery,
                    );
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: Text(translate('cancel', widget.currentLang)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showDetails(Map<String, dynamic> station) {
    // استخراج امکانات بر اساس مختصات ایستگاهی که روش کلیک شده
    final facilities = getFacilities(station['lat'], station['lng']);

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                station['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(),
              // نمایش ردیف امکانات با استفاده از دیتای آفلاین
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailIcon(Icons.wc, "Toilet", facilities['wc'] == 1),
                  _buildDetailIcon(
                    Icons.local_shipping,
                    "LKW",
                    facilities['lkw'] == 1,
                  ),
                  _buildDetailIcon(
                    Icons.shopping_basket,
                    "Shop",
                    facilities['shop'] == 1,
                  ),
                  _buildDetailIcon(
                    Icons.local_car_wash,
                    "Wash",
                    facilities['wash'] == 1,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailIcon(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(
          icon,
          color: isActive ? Colors.blue : Colors.grey.withOpacity(0.3),
          size: 30,
        ),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildOilBanner() {
  // اگر دیتا هنوز نرسیده بود
  if (oilAnalysis == null) return const SizedBox.shrink();

  // گرفتن باکس ذخیره‌سازی برای نمایش قیمت‌های تاریخچه
  final box = Hive.box('oilBox');
  final double today = box.get('todayPrice', defaultValue: 0.0);
  final double yesterday = box.get('yesterdayPrice', defaultValue: 0.0);
  final double dayBefore = box.get('dayBeforePrice', defaultValue: 0.0);

  // استخراج پیام اصلی از متغیر oilAnalysis
  String message = "Oil Market Analysis";
  if (oilAnalysis is Map) {
    message = (oilAnalysis as Map)['message']?.toString() ?? message;
  }

  return Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.blue.shade200),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            
            _buildPriceDetail(translate('two_days_ago', widget.currentLang), dayBefore),
            _buildPriceDetail(translate('yesterday', widget.currentLang), yesterday),
            _buildPriceDetail(translate('today', widget.currentLang), today, isBold: true),
          ],
        ),
      ],
    ),
  );
}

// ویجت کمکی برای نمایش هر قیمت
Widget _buildPriceDetail(String label, double price, {bool isBold = false}) {
  return Column(
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 9 * _fontScale, color: Colors.grey.shade600),
      ),
      Text(
        price > 0 ? "\$${price.toStringAsFixed(2)}" : "---",
        style: TextStyle(
          fontSize: (isBold ? 13 : 11) * _fontScale,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: isBold ? Colors.black : Colors.black87,
        ),
      ),
    ],
  );
}



  Future<void> loadOfflineData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/germany_stations.json',
      );
      final parsed = await compute(parseOfflineStationsJson, jsonString);
      if (!mounted) return;
      offlineStations = parsed;
    } catch (e) {
      print("Error loading offline data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    AppTimelineManager().hydrateFromLocalCache();
    _searchFocusNode.addListener(() {
      if (mounted) setState(() {});
    });

    // --- کدهای جدید: خواندن آخرین لوکیشن از حافظه ---
    var settingsBox = Hive.box('settingsBox');
    userLat = settingsBox.get('lastLat', defaultValue: 52.5200);
    userLng = settingsBox.get('lastLng', defaultValue: 13.4050);
    _mapCenterLat = userLat;
    _mapCenterLng = userLng;
    selectedStationId = settingsBox.get('selectedStationId');
    selectedFuel = settingsBox.get('lastSelectedFuel', defaultValue: 'diesel');
    // ---------------------------------------------

     if (!kIsWeb) {
     PurchaseManager().initialize(
    onError: (errorMessage) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    },
   onSuccess: () {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('premium_activated', widget.currentLang)),
        backgroundColor: Colors.green,
      ),
    );
  }
},
  );

    // 🔴 ۱. بررسی فوری مقدار فعلی نوتیفایر در زمان ساخته شدن استیت (مخصوص شروع سرد)
      if (NotificationService.tabNotifier.value == 1) {
        _selectedIndex = 1;
        highlightedMaintenanceKey = NotificationService.selectedServiceKey ?? '';
        _bypassPremiumForNotification = true;
      }


      // 🔴 ۲. گوش دادن به تغییرات بعدی نوتیفایر در زمان باز بودن برنامه
      NotificationService.tabNotifier.addListener(() {
        if (NotificationService.tabNotifier.value == 1) {
          if (mounted) {
            setState(() {
              _selectedIndex = 1;
              highlightedMaintenanceKey = NotificationService.selectedServiceKey ?? '';
              _bypassPremiumForNotification = true;
            });
            _refreshAllMaintenanceReminders();
          }
        }
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchStations(userLat, userLng);
      _loadBannerAd();
      _scheduleDeferredStartupWork();
    });
  }

  void _scheduleDeferredStartupWork() {
    Future<void>.delayed(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _loadSearchHistory();
      _loadHistory();
      _loadSavedCarModel();
      _loadEmailSettings();
      _loadMaintenanceData();
    });
    Future<void>.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      loadOfflineData();
      _loadAnalysisData();
      _checkThreeMonthMileageReminder();
      _checkNotificationPermissions();
      _checkAndForceUpdate();
    });
  }

  Future<void> _loadHistory() async {
  var box = await Hive.openBox('searchBox');
  setState(() {
    searchHistory = (box.get('history', defaultValue: []) as List).cast<String>().toList();
  });
}

  Future<void> _loadAnalysisData() async {
    await OilAnalysisService.updateOilAnalysis();
    setState(() {
      oilAnalysis = OilAnalysisService.getSimpleAnalysis();
    });
  }

  Future<void> _loadSavedCarModel() async {
    var box = await Hive.openBox('carServiceBox');
    setState(() {
      carModel = box.get('model', defaultValue: "");
    });
  }

  // در بالای فایل ایمپورت کنید: 
// import 'package:permission_handler/permission_handler.dart';

  Future<void> _checkNotificationPermissions() async {
    if (kIsWeb) return;

    final bool pluginGranted = await NotificationService.requestPermission();

    PermissionStatus status = await Permission.notification.status;

    if (!pluginGranted && (status.isDenied || status.isRestricted)) {
      await Permission.notification.request();
      status = await Permission.notification.status;
    }

    if (status.isPermanentlyDenied) {
      if (mounted) {
        _showNotificationSettingsDialog();
      }
    }
  }

  void _showNotificationSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            translate('notification_disabled_title', widget.currentLang) ?? 'هشدار نوتیفیکیشن',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
             translate('notification_disabled_msg', widget.currentLang) ?? 
             'نوتیفیکیشن‌های برنامه در تنظیمات گوشی غیرفعال شده‌اند. برای دریافت هشدارهای سرویس خودرو، لطفاً آن را فعال کنید.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // کاربر می‌تواند بی‌خیال شود
              child: Text(translate('cancel', widget.currentLang) ?? 'لغو'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings(); // این متد مستقیماً صفحه تنظیمات همین اپلیکیشن را در گوشی باز می‌کند
                Navigator.of(context).pop();
              },
              child: Text(translate('open_settings', widget.currentLang) ?? 'تنظیمات گوشی'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadMaintenanceData() async {
    var box = await Hive.openBox('carServiceBox');
    final savedData = box.get('maintenanceData', defaultValue: <String, dynamic>{});

    if (savedData is Map) {
      final items = (savedData['items'] as List? ?? [])
          .map((item) => MaintenanceItem.fromMap(Map<String, dynamic>.from(item)))
          .toList();

      setState(() {
        carModel = savedData['vehicleModel']?.toString() ?? carModel;
        licensePlate = savedData['licensePlate']?.toString() ?? '';
        workshopName = savedData['workshopName']?.toString() ?? '';
        workshopPhone = savedData['workshopPhone']?.toString() ?? '';
        insurancePhone = savedData['insurancePhone']?.toString() ?? '';
        currentKm = savedData['currentKm']?.toString() ?? currentKm;
        maintenanceItems = items.isNotEmpty ? items : _defaultMaintenanceItems();
        _isEditingWorkshopPhone = !_isValidPhoneNumber(workshopPhone);
        _isMaintenanceLoading = false;
      });
    } else {
      setState(() {
        maintenanceItems = _defaultMaintenanceItems();
        _isMaintenanceLoading = false;
      });
    }

    await _refreshAllMaintenanceReminders();
  }

  List<MaintenanceItem> _defaultMaintenanceItems() {
    return [
      MaintenanceItem(key: 'tuv', title: 'TÜV / Inspection', websiteUrl: 'https://www.tuev-nord.de/de/stationen/'),
      MaintenanceItem(key: 'insurance', title: 'Insurance', websiteUrl: 'https://www.check24.de/kfz-versicherung/'),
      MaintenanceItem(key: 'oil', title: 'Oil Change', websiteUrl: 'https://www.autodoc.de/search?keyword=motor%C3%B6l'),      
      MaintenanceItem(key: 'tires', title: 'Tires', websiteUrl: 'https://www.autodoc.de/reifen'),
      MaintenanceItem(key: 'brake', title: 'Brake Service', websiteUrl: 'https://www.autodoc.de/search?keyword=bremsbelege'),
      MaintenanceItem(key: 'wipers', title: 'Wipers', websiteUrl: 'https://www.autodoc.de/search?keyword=Wischer'),
      MaintenanceItem(key: 'lights', title: 'Lights / Lamps', websiteUrl: 'https://www.autodoc.de/search?keyword=lichts'),
     
      MaintenanceItem(key: 'adac', title: 'ADAC', websiteUrl: 'https://www.adac.de/'),
      //MaintenanceItem(key: 'km_stand', title: 'Kilometer Stand', websiteUrl: ''),
    ];
  }

  Future<void> _saveMaintenanceData() async {
    var box = await Hive.openBox('carServiceBox');
    await box.put('maintenanceData', {
      'vehicleModel': carModel,
      'licensePlate': licensePlate,
      'workshopName': workshopName,
      'workshopPhone': workshopPhone,
      'insurancePhone': insurancePhone,
      'currentKm': currentKm,
      'items': maintenanceItems.map((item) => item.toMap()).toList(),
    });
    await box.put('model', carModel);
  }

  Future<void> _recordPerformanceUpdate() async {
    final settingsBox = await Hive.openBox('settingsBox');
    final now = DateTime.now();
    final nextReminder = DateTime(now.year + ((now.month - 1 + 3) ~/ 12),
        ((now.month - 1 + 3) % 12) + 1, now.day, now.hour, now.minute, now.second);
    await settingsBox.put('nextPerformanceReminder', nextReminder.toIso8601String());
  }

  bool _isMaintenanceItemConfigured(MaintenanceItem item) {
    return [
      item.mileage,
      item.serviceDate,
      item.note,
      item.contact,
      item.serviceCenter,
    ].any((value) => value.trim().isNotEmpty);
  }

  DateTime _parseMaintenanceDate(String value) {
    if (value.isEmpty) return DateTime(2100);
    try {
      return DateTime.parse(value);
    } catch (_) {
      return DateTime(2100);
    }
  }

  String _formatMaintenanceDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _maintenanceTitle(MaintenanceItem item) {
    final translated = translate('cat_${item.key}', widget.currentLang);
    return translated.startsWith('cat_') ? item.title : translated;
  }

  int getDefaultIntervalKm(String key) {
  switch (key) {
    case 'oil':
      return 15000;
    case 'tires':
    case 'tire':
      return 60000;
    default:
      return 0; // بدون محدودیت کیلومتر پیش‌فرض
  }
}

int getDefaultIntervalDays(String key) {
  switch (key) {
    case 'oil':
    case 'insurance':
    case 'adac':
      return 365; // ۱ سال
    case 'tires':
    case 'tire':
      return 4 * 365; // ۴ سال (۱۴۶۰ روز)
    case 'battery':
      return 3 * 365; // ۳ سال (۱۰۹۵ روز)
    default:
      return 365;
  }
}


Future<void> _refreshAllMaintenanceReminders() async {
  int tier = AppTimelineManager().currentTier;
  bool isPremium = PurchaseManager().isPremiumUser.value;

  // 🔴 فاز ۳: قطع کامل دسترسی و غیرفعال‌سازی آلارم اصلی
  if (!isPremium && tier >= 4) {
    await NotificationService.cancelMaintenanceNotification('master');
    return;
  }

  final now = DateTime.now();
  final int currentKmValue = int.tryParse(currentKm) ?? -1;
  bool anyOverdue = false;

  for (var item in maintenanceItems) {
    
    // ۱. اگر تاریخ خالی باشد (بجز لاستیک ۲ فصل)، تیک آلارم خاموش می‌شود
    // if (item.serviceDate.trim().isEmpty && !(item.key == 'tires' && item.tireType == '2season')) {
    //   if (item.alarmEnabled) {
    //     item.alarmEnabled = false;
    //   }
    //   continue;
    // }

    // ۲. اگر تیک آلارم این قطعه خاموش است، کلاً نادیده گرفته می‌شود
    if (!item.alarmEnabled) continue;

    // الف) بررسی وضعیت لاستیک‌های ۲ فصل آلمان
    if (item.key == 'tires' && item.tireType == '2season') {
      DateTime winterDeadline = DateTime(now.year, 10, 15);
      DateTime summerDeadline = DateTime(now.year, 4, 15);
      DateTime nextDeadline;

      if (now.isAfter(summerDeadline) && now.isBefore(winterDeadline)) {
        nextDeadline = winterDeadline;
      } else if (now.isAfter(winterDeadline)) {
        nextDeadline = DateTime(now.year + 1, 4, 15);
      } else {
        nextDeadline = summerDeadline;
      }

      final int daysUntilDeadline = nextDeadline.difference(now).inDays;
      if (daysUntilDeadline <= 14) {
        anyOverdue = true; // وارد محدوده هشدار شده
      }
    } 
    // ب) بررسی سایر قطعات (بر اساس تاریخ یا کیلومتر)
    else {
      bool isDateDue = false;
      bool isKmDue = false;

      // 💡 آستانه روز مستقیم از تنظیمات کاربر (reminderDays)
      int alertDaysThreshold = item.reminderDays;
      // 💡 آستانه کیلومتر ثابت (۱۰۰۰ کیلومتر مانده به سرویس)
      const int alertKmThreshold = 1000;

      // بررسی سررسید تاریخ بر اساس intervalDays و reminderDays
      if (item.serviceDate.trim().isNotEmpty) {
        final int intDays = item.intervalDays ?? getDefaultIntervalDays(item.key);
        final prevDate = _parseMaintenanceDate(item.serviceDate);
        if (prevDate.year != 2100) {
          final DateTime preciseDueDate = prevDate.add(Duration(days: intDays));
          final int daysUntil = preciseDueDate.difference(now).inDays;

          if (daysUntil <= alertDaysThreshold) {
            isDateDue = true;
          }
        }
      }

      // بررسی سررسید کیلومتر بر اساس intervalKm
      final int prevKm = int.tryParse(item.mileage) ?? -1;
      final int intKm = item.intervalKm ?? getDefaultIntervalKm(item.key);
      if (prevKm > 0 && intKm > 0 && currentKmValue > 0) {
        final int targetKm = prevKm + intKm;
        final int remainingKm = targetKm - currentKmValue;

        if (remainingKm <= alertKmThreshold) {
          isKmDue = true;
        }
      }

      // اگر از نظر تاریخ یا کیلومتر موعدش رسیده باشد
      if (isDateDue || isKmDue) {
        anyOverdue = true;
      }
    }
  }

  // ۳. مدیریت آلارم تنها/اصلی (Master)
  if (anyOverdue) {
    DateTime scheduleTime = DateTime(now.year, now.month, now.day, 9, 0);
    if (!scheduleTime.isAfter(now)) {
      scheduleTime = scheduleTime.add(const Duration(days: 1));
    }

    await NotificationService.scheduleMaintenanceReminder(
      itemKey: 'master',
      title: widget.currentLang == 'fa' ? 'یادآور سرویس خودرو 🔧' : 'Car Service Reminder 🔧',
      body: widget.currentLang == 'fa'
          ? 'موعد سرویس برخی قطعات رسیده است. لطفاً صفحه سرویس ماشین را بررسی کنید.'
          : 'Service time has arrived for some items. Please check the car service page.',
      firstRun: scheduleTime,
      repeatDaily: true,
      payload: 'master',
      btnOpenText: translate('btn_open', widget.currentLang),
      btnDeleteText: translate('btn_delete', widget.currentLang),
      btnSnoozeText: translate('btn_snooze', widget.currentLang),
    );
  } else {
    // ✅ اگر هیچ قطعه‌ای هشدار نداشت، آلارم اصلی خاموش می‌شود
    await NotificationService.cancelMaintenanceNotification('master');
  }
}


  // متد آپدیت تکی حالا فقط رفرش کلی را صدا می‌زند تا همه‌چیز یکپارچه بررسی شود
  Future<void> _updateMaintenanceReminder(MaintenanceItem item) async {
    await _refreshAllMaintenanceReminders();
  }


  Future<void> _pickMaintenanceDate(MaintenanceItem item) async {
   final initialDate = _parseMaintenanceDate(item.serviceDate).year == 2100
      ? DateTime.now()
      : _parseMaintenanceDate(item.serviceDate);

  // اطمینان از اینکه اگر تاریخ ثبت شده قبلی به اشتباه در آینده است، تقویم روی امروز باز شود
  final safeInitialDate = initialDate.isAfter(DateTime.now()) ? DateTime.now() : initialDate;

  final picked = await showDatePicker(
    context: context,
    initialDate: safeInitialDate,
    firstDate: DateTime(2020),
    lastDate: DateTime.now(), // 👈 جلوگیری از انتخاب تاریخ در آینده
  );
  if (picked != null) {
    setState(() {
      item.serviceDate = _formatMaintenanceDate(picked);
      item.isConfigured = _isMaintenanceItemConfigured(item);
    });
    await _saveMaintenanceData();
  }
}

 Future<void> _showAlarmDialog(MaintenanceItem item) async {
  final reminderController = TextEditingController(text: item.reminderDays.toString());
  
  // لود کردن فواصل کنونی یا فواصل دیفالت داینامیک
  final int currentIntervalKm = item.intervalKm ?? getDefaultIntervalKm(item.key);
  final int currentIntervalDays = item.intervalDays ?? getDefaultIntervalDays(item.key);

  final kmIntervalController = TextEditingController(
      text: currentIntervalKm == 0 ? '' : currentIntervalKm.toString());
  final daysIntervalController = TextEditingController(text: currentIntervalDays.toString());

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('${translate('reminder_for', widget.currentLang)} ${_maintenanceTitle(item)}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // فیلد روزهای یادآور پیش از موعد اصلی
              TextField(
                controller: reminderController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: translate('reminder_before_due', widget.currentLang),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.notifications_active_outlined),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(),
              const SizedBox(height: 10),
              
              // فیلد ویرایش فاصله کیلومتر اختصاصی (مثلا ۱۵۰۰۰ برای روغن، ۶۰۰۰۰ تایر)
              TextField(
                controller: kmIntervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: widget.currentLang == 'fa' ? 'فاصله تعویض/سرویس (کیلومتر)' : 'Service Interval (KM)',
                  hintText: 'e.g. 15000',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.speed),
                ),
              ),
              const SizedBox(height: 14),
              
              // فیلد ویرایش فاصله روز اختصاصی (مثلا ۳۶۵ برای بیمه و یکسال، ۱۴۶۰ تایر، ۱۰۹۵ باتری)
              TextField(
                controller: daysIntervalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: widget.currentLang == 'fa' ? 'دوره تناوب سرویس (تعداد روز)' : 'Service Period (Days)',
                  hintText: 'e.g. 365',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 12),
              
              Text(
                item.serviceDate.isEmpty
                    ? translate('set_date_first', widget.currentLang)
                    : translate('reminder_info', widget.currentLang, {'days': item.reminderDays.toString()}),
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translate('cancel', widget.currentLang))),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(reminderController.text) ?? 7;
              final customKm = int.tryParse(kmIntervalController.text) ?? 0;
              final customDays = int.tryParse(daysIntervalController.text) ?? 365;

              setState(() {
                item.reminderDays = days;
                item.intervalKm = customKm;
                item.intervalDays = customDays;
                item.isConfigured = _isMaintenanceItemConfigured(item);
              });
              
              await _saveMaintenanceData();
              await _refreshAllMaintenanceReminders();
              Navigator.pop(context);
            },
            child: Text(translate('save_alert_btn', widget.currentLang)),
          ),
        ],
      );
    },
  );
}

  Future<void> _openMaintenanceLink(MaintenanceItem item) async {
    if (item.websiteUrl.isEmpty) return;
    final uri = Uri.parse(item.websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _isValidPhoneNumber(String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) return false;
    final phoneRegex = RegExp(r'^\+?[0-9\s\-/()]{6,15}$');
    return phoneRegex.hasMatch(normalized);
  }

  String _getPrimaryPhoneNumber(MaintenanceItem item) {
    // Special-case ADAC to use a fixed hotline
    if (item.key == 'adac') return '089 558 95 96 97';
    // For insurance, prefer the item's contact, then the dedicated insurancePhone (no workshop fallback)
    if (item.key == 'insurance') {
      if (item.contact.trim().isNotEmpty) return item.contact.trim();
      if (_isValidPhoneNumber(insurancePhone)) return insurancePhone.trim();
      return '';
    }

    if (item.contact.trim().isNotEmpty) return item.contact.trim();
    if (_isValidPhoneNumber(workshopPhone)) return workshopPhone.trim();
    return '';
  }
//به یاد آوردن
  Future<void> _callMaintenanceContact(MaintenanceItem item) async {
  final phoneToCall = _getPrimaryPhoneNumber(item);
  if (phoneToCall.isEmpty) return;
  
  // حذف تمامی فاصله‌ها، خط تیره‌ها و پرانتزها برای سازگاری با دیالر گوشی
  final cleanPhone = phoneToCall.replaceAll(RegExp(r'[\s\-()]'), '');
  
  // استفاده از Uri.parse استانداردترین روش برای tel scheme است
  final uri = Uri.parse('tel:$cleanPhone');
  
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  } else {
    debugPrint('Could not launch phone call for: $cleanPhone');
  }
}

  Map<String, int> getFacilities(double lat, double lng) {
    String key = "${lat.toStringAsFixed(3)}_${lng.toStringAsFixed(3)}";
    if (offlineStations.containsKey(key)) {
      var s = offlineStations[key];
      return {
        "wc": s['wc'] ?? 0,
        "lkw": s['lkw'] ?? 0,
        "rest": s['rest'] ?? 0,
        "play": s['play'] ?? 0,
        "shop": s['shop'] ?? 0,
        "wash": s['wash'] ?? 0,
      };
    }
    return {"wc": 0, "lkw": 0, "rest": 0, "play": 0, "shop": 0, "wash": 0};
  }

  Future<void> _sendEmailReminder() async {
    // 👈 تنظیمات ایمیل ذخیره شده در دیتابیس لوکال را می‌خواند
    var box = Hive.box('settingsBox');
    String targetEmail = box.get('userEmail', defaultValue: 'ahmdel@gmail.com');

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: targetEmail, // 👈 حالا به ایمیل کاربر می‌فرستد
      query: encodeQueryParameters(<String, String>{
        'subject': 'Car Service Log - Adak App',
        'body':
            'Car Model: $carModel\n'
            'Service Type: $selectedServiceType\n'
            'Mileage: $currentKm Km\n'
            'Next service reminder set for 6 months later.',
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }

  Future<void> saveServiceInfo(
    String model,
    String date,
    String type,
    String km,
  ) async {
    var box = await Hive.openBox('carServiceBox');

    // ایجاد یک Map برای هر رکورد
    final newRecord = {'model': model, 'date': date, 'type': type, 'km': km};

    // اضافه کردن به لیست تاریخچه (به جای جایگزین کردن)
    await box.add(newRecord);

    // برای آپدیت شدن لحظه‌ای لیست در اپلیکیشن
    setState(() {});
  }

  Future<void> fetchEVStations({double? lat, double? lng}) async {
    setState(() => isLoading = true);

    double searchLat = lat ?? 0.0;
    double searchLng = lng ?? 0.0;
    if (lat == null || lng == null) {
      Position position = await _getFastPosition();
      searchLat = position.latitude;
      searchLng = position.longitude;
    }

    setState(() {
      userLat = searchLat;
      userLng = searchLng;
    });
    _saveLastLocation(searchLat, searchLng);

    final String apiKey =
        "1496f02a-4cf6-45fd-90e9-83bb67a3cdab"; // کلیدی که گرفتید
    final String url =
        "https://api.openchargemap.io/v3/poi/?output=json&countrycode=DE&latitude=$searchLat&longitude=$searchLng&distance=$_fuelSearchRadiusKm&distanceunit=KM&maxresults=100&compact=true&verbose=false&key=$apiKey";
    //
    //"https://api.openchargemap.io/v3/poi/?output=json&countrycode=DE&maxresults=10&compact=true&verbose=false";
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              // این خط خیلی مهمه! به سرور می‌گه من گوشی اندرویدی هستم نه کد برنامه‌نویسی
              "User-Agent":
                  "Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/110.0.0.0 Mobile Safari/537.36",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        //List<dynamic> data = json.decode(response.json());
        List<dynamic> data = json.decode(response.body); // تغییر به body
        setState(() {
          // تبدیل فرمت دیتا به فرمت‌ای که در لیست نمایش می‌دهید
          stations = data.map((item) {
            var connections = item['Connections'] as List?;
            String power = "N/A";
            if (connections != null && connections.isNotEmpty) {
              power = "${connections[0]['PowerKW'] ?? '?'}kW";
            }

            // --- جلوگیری از کرش در بخش AddressInfo ---
            var addr = item['AddressInfo'] ?? {};

            return {
              'name': addr['Title'] ?? 'Unnamed Station',
              'brand': 'EV Charging',
              'street': addr['AddressLine1'] ?? 'No Address',
              'houseNumber': '',
              'lat': addr['Latitude'] ?? 0.0,
              'lng': addr['Longitude'] ?? 0.0,
              'price': '⚡ $power', // مقدار توان رو اینجا می‌ذاریم
              'isOpen': true,
              'dist': (addr['Distance'] ?? 0).toStringAsFixed(1),
            };
          }).toList();
          _restoreSelectedStationAtTop();
          _syncMapStationsFromList(lat: searchLat, lng: searchLng);
        });
        _fitMapToSearchResults();
        print("✅ دیتا با موفقیت دریافت شد");
      } else {
        print("❌ خطای سرور: ${response.body}");
      }
    } catch (e) {
      print("EV Error: $e");
    } finally {
      print("🏁 پایان فراخوانی و توقف لودینگ");
      setState(() => isLoading = false);
    }
  }

Future<void> _openGoogleMapsForParkingFallback({
  double? lat,
  double? lng,
  String? postalCode,
  String? cityName,
  bool isCurrentLocation = false,
}) async {
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(translate('parking_no_data_redirect', widget.currentLang)),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  // ۱. ساختن کوئری جستجوی هوشمند بر اساس اولویت داده‌ها
  String query = 'parking';

  if (postalCode != null && postalCode.trim().isNotEmpty) {
    query = 'parking near ${postalCode.trim()}';
  } else if (cityName != null && cityName.trim().isNotEmpty) {
    query = 'parking near ${cityName.trim()}';
  } else {
    query = 'parking near me';
  }

  await _openNavigation(
    destLat: lat,
    destLng: lng,
    searchQuery: query,
  );
}

  Future<void> fetchParkingData({
  double? lat,
  double? lng,
  String? postalCode,
  String? cityName,
  bool isCurrentLocation = false,
}) async {
  setState(() {
    isLoading = true;
    stations = []; 
  });

  double searchLat = lat ?? 0.0;
  double searchLng = lng ?? 0.0;

  // اگر مختصات پاس داده نشده باشد، سعی می‌کنیم لوکیشن فعلی دستگاه را بگیریم
  if ((lat == null || lng == null) && (postalCode == null || postalCode.isEmpty) && (cityName == null || cityName.isEmpty)) {
    try {
      Position position = await _getFastPosition();
      searchLat = position.latitude;
      searchLng = position.longitude;
      isCurrentLocation = true; // مشخص می‌کنیم که جستجو بر اساس موقعیت فعلی بوده است
    } catch (e) {
      debugPrint("Error getting current location: $e");
    }
  }

  setState(() {
    userLat = searchLat;
    userLng = searchLng;
  });

  if (searchLat != 0.0 && searchLng != 0.0) {
    _saveLastLocation(searchLat, searchLng);
  }
  
  bool dataFound = false;

  // اجرای درخواست Overpass API فقط در صورت داشتن مختصات معتبر
  if (searchLat != 0.0 && searchLng != 0.0) {
    final radiusMeters = (_fuelSearchRadiusKm * 1000).round();

    try {
      final elements = await _queryOverpassParking(
        lat: searchLat,
        lng: searchLng,
        radiusMeters: radiusMeters,
      );
      final parkingStations = _parkingStationsFromOverpass(
        elements,
        searchLat,
        searchLng,
      );

      if (parkingStations.isNotEmpty) {
        dataFound = true;
        setState(() {
          stations = parkingStations;
          _restoreSelectedStationAtTop();
          _syncMapStationsFromList(lat: searchLat, lng: searchLng);
        });
        _fitMapToSearchResults();
      }
    } catch (e) {
      debugPrint("Parking Error: $e");
    }
  }

  if (mounted) {
    setState(() => isLoading = false);
  }
  
  // 👈 اگر به هر دلیلی دیتا پیدا نشد، گوگل مپ را با بهترین کوئری ممکن باز کن
  if (!dataFound) {
    _openGoogleMapsForParkingFallback(
      lat: searchLat,
      lng: searchLng,
      postalCode: postalCode,
      cityName: cityName,
      isCurrentLocation: isCurrentLocation || (lat == null && lng == null),
    );
  }
}



  // تابع کمکی برای ساخت آیکون‌های کوچک
  Widget _buildIcon(IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Icon(icon, size: 16, color: color),
    );
  }

  Widget _buildServicePage() {
    return Column(
      children: [  

        // نمایش محتوا بر اساس انتخاب کاربر
        Expanded(
          child: serviceView == 'history'
              ? _buildServiceHistoryList() // تابع لیست سرویس‌ها
              : _buildParkingList(), // تابع لیست پارکینگ‌ها
        ),
      ],
    );
  }

  void _showAddCategoryDialog() {
    String newType = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Custom Service/Part"),
        content: TextField(
          decoration: const InputDecoration(
            hintText: "e.g. Fuel Pump, Battery...",
          ),
          onChanged: (val) => newType = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (newType.isNotEmpty) {
                setState(() {
                  serviceCategories.add(newType); // اضافه کردن به لیست
                  selectedServiceType = newType; // انتخاب خودکار آیتم جدید
                });
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }


  Future<void> _deleteMaintenanceItem(MaintenanceItem item) async {
    setState(() {
      maintenanceItems.remove(item);
    });
    await _saveMaintenanceData();
    await NotificationService.cancelMaintenanceNotification(item.key);
    await _refreshAllMaintenanceReminders();
  }

  Future<void> _moveMaintenanceItem(MaintenanceItem item, int direction) async {
    final currentIndex = maintenanceItems.indexOf(item);
    if (currentIndex == -1) return;
    final newIndex = currentIndex + direction;
    if (newIndex < 0 || newIndex >= maintenanceItems.length) return;

    setState(() {
      maintenanceItems.removeAt(currentIndex);
      maintenanceItems.insert(newIndex, item);
    });
    await _saveMaintenanceData();
  }

  Widget _buildServiceHistoryList() {
    if (_isMaintenanceLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    int tier = AppTimelineManager().currentTier;
    bool isPremium = PurchaseManager().isPremiumUser.value;

  // 🔒 فاز ۳: قطعی کامل دسترسی به تب سرویس
  if (!isPremium && tier >= 4) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.block, size: 80, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              widget.currentLang == 'fa' 
                  ? 'دسترسی به بخش سرویس قطع شده است. برای استفاده نامحدود ارتقا دهید.' 
                  : 'Service access is blocked. Upgrade to premium to unlock.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
              onPressed: () => _showTankenPremiumDialog(context),
              child: Text(translate('activate_premium_6months', widget.currentLang)),
            )
          ],
        ),
      ),
    );
  }

  // 📺 فاز ۲: تماشای ویدیو برای آزادسازی موقت تب سرویس
  if (!isPremium && tier == 3 && !_isServiceUnlockedForSession) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.ondemand_video, size: 80, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              widget.currentLang == 'fa' 
                  ? 'برای مشاهده و ویرایش اطلاعات سرویس، ابتدا یک ویدیو تبلیغاتی تماشا کنید.' 
                  : 'Watch a video to access and edit your service history.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.shade700),
              onPressed: () {
                AppAdManager().showNavigationRewardedAd(() {
                  setState(() {
                    _isServiceUnlockedForSession = true; // باز کردن قفل پس از تماشای ویدیو
                  });
                });
              },
              child: const Text('تماشای ویدیو', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

    final displayItems = maintenanceItems;

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               
                
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: translate('current_mileage', widget.currentLang),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.speed),
                  ),
                  controller: TextEditingController(text: currentKm),
                  onChanged: (value) async {
                    currentKm = value;
                    await _saveMaintenanceData();
                    await _recordPerformanceUpdate();
                    await _refreshAllMaintenanceReminders();
                  },
                ),
                
                const SizedBox(height: 10),
                TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: translate('insurance_phone', widget.currentLang),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.phone),
                    hintText: 'e.g. 030123456',
                  ),
                  controller: TextEditingController(text: insurancePhone),
                  onChanged: (value) async {
                    insurancePhone = value;
                    await _saveMaintenanceData();
                  },
                ),
                const SizedBox(height: 10),
                _isEditingWorkshopPhone || !_isValidPhoneNumber(workshopPhone)
                    ? TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: translate('phone_number', widget.currentLang),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.phone),
                          hintText: 'e.g. 030123456',
                        ),
                        controller: TextEditingController(text: workshopPhone),
                        onChanged: (value) async {
                          workshopPhone = value;
                          // setState(() {
                          //   _isEditingWorkshopPhone = !_isValidPhoneNumber(value);
                          // });
                          await _saveMaintenanceData();
                        },
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.green.shade300),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.green.shade50,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.phone, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                workshopPhone,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: () {
                                setState(() {
                                  _isEditingWorkshopPhone = true;
                                });
                              },
                              tooltip: 'Edit phone',
                            ),
                          ],
                        ),
                      ),
                const SizedBox(height: 8),

              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          translate('maintenance_overview', widget.currentLang),
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 12,
            headingRowHeight: 48,
            dataRowHeight: 110,
            columns: [
              DataColumn(label: Text(translate('item', widget.currentLang))),
              //DataColumn(label: Text(translate('mileage', widget.currentLang))),
              DataColumn(label: Text(translate('date', widget.currentLang))),
              //DataColumn(label: Text(translate('contact', widget.currentLang))),
              DataColumn(label: Text(translate('alarm', widget.currentLang))),
            ],
            rows: displayItems.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isIncomplete = !_isMaintenanceItemConfigured(item);
              final isHighlighted = highlightedMaintenanceKey.isNotEmpty && highlightedMaintenanceKey == item.key;
              final bool hideMileage = item.key == 'adac' || item.key == 'tuev' || item.key == 'tuv' || item.key == 'lights';
              return DataRow(
                color: isIncomplete
                    ? MaterialStatePropertyAll(Colors.red.shade50)
                    : null,
                cells: [

        DataCell(
  SizedBox(
    width: 100, 
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _maintenanceTitle(item),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isHighlighted ? Colors.red : Colors.black,
          ),
        ),
        
        // 👈 اضافه شدن دراپ‌دان انتخاب فصل مخصوص لاستیک
        if (item.key == 'tires') ...[
          const SizedBox(height: 4),
          DropdownButton<String>(
            value: item.tireType,
            isDense: true,
            style: const TextStyle(fontSize: 11, color: Colors.blue, fontWeight: FontWeight.bold),
            items: [
              DropdownMenuItem(
                value: '4season', 
                child: Text(widget.currentLang == 'fa' ? '۴ فصل' : '4-Seasons')
              ),
              DropdownMenuItem(
                value: '2season', 
                child: Text(widget.currentLang == 'fa' ? '۲ فصل (ت/ز)' : '2-Seasons')
              ),
            ],
            onChanged: (String? newValue) async {
              if (newValue != null) {
                setState(() {
                  item.tireType = newValue;
                });
                await _saveMaintenanceData();
                await _refreshAllMaintenanceReminders();
              }
            },
          ),
        ],
        
       if (!hideMileage) ...[
          const SizedBox(height: 6),
     
          SizedBox(
            width: 100, 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
             
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus && item.mileage.isNotEmpty && currentKm.isNotEmpty) {
                        int entered = int.tryParse(item.mileage) ?? 0;
                        int current = int.tryParse(currentKm) ?? 0;

                        // 👈 ۱. بررسی عدم ثبت کیلومتر بزرگتر از کیلومتر فعلی
                            if (entered > current) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('خطا در ثبت کیلومتر', style: TextStyle(color: Colors.red)),
                                  content: Text('کیلومتر وارد شده ($entered) نمی‌تواند بیشتر از کیلومتر فعلی ماشین ($currentKm) باشد!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          item.mileage = ''; // پاک کردن مقدار اشتباه
                                          item.isConfigured = _isMaintenanceItemConfigured(item);
                                        });
                                        _saveMaintenanceData();
                                        Navigator.pop(context);
                                      },
                                      child: const Text('متوجه شدم، اصلاح می‌کنم'),
                                    ),
                                  ],
                                ),
                              );
                            }


                        if ((entered - current).abs() > 30000) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('هشدار: اختلاف کیلومتر زیاد', style: TextStyle(color: Colors.red)),
                              content: Text('مقدار وارد شده (${item.mileage}) با کیلومتر فعلی ماشین ($currentKm) بیش از ۳۰,۰۰۰ کیلومتر اختلاف دارد. آیا مطمئن هستید؟'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      item.mileage = '';
                                      item.isConfigured = _isMaintenanceItemConfigured(item);
                                    });
                                    _saveMaintenanceData();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('خیر، اصلاح می‌کنم'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('بله، مطمئنم'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8), // 👈 پدینگ کمتر برای فضای تنگ
                        hintText: translate('km', widget.currentLang, {'val': ''}).trim(),
                        border: const OutlineInputBorder(),
                      ),
                      controller: TextEditingController(text: item.mileage),
                      onTap: () {
                        if (currentKm.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('کیلومتر فعلی ثبت نشده!'),
                              content: const Text('لطفا ابتدا "کیلومتر فعلی" ماشین را در بالای صفحه وارد کنید.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('متوجه شدم'),
                                )
                              ],
                            )
                          );
                          FocusScope.of(context).unfocus();
                        }
                      },
                      onChanged: (value) async {
                        if (currentKm.isNotEmpty) {
                          int entered = int.tryParse(value) ?? 0;
                          int current = int.tryParse(currentKm) ?? 0;

                          if (entered <= current || value.isEmpty) {
                          item.mileage = value;
                          item.isConfigured = _isMaintenanceItemConfigured(item);
                          await _saveMaintenanceData();
                          await _updateMaintenanceReminder(item);
                          }
                        }
                      },
                    ),
                  ),
                ),
               
                SizedBox(
                  width: 28,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 15,
                    icon: const Icon(Icons.refresh, size: 20, color: Colors.lightGreen),
                    tooltip: 'ثبت در کیلومتر فعلی',
                    onPressed: () async {
                      if (currentKm.isEmpty) {
                         ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ابتدا کیلومتر فعلی را در بالای صفحه وارد کنید.'))
                         );
                         return;
                      }
                      setState(() {
                        item.mileage = currentKm;
                        item.isConfigured = _isMaintenanceItemConfigured(item);
                      });
                      await _saveMaintenanceData();
                      await _updateMaintenanceReminder(item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],

      ],
    ),
  ),
),

   
             
  DataCell(
  SizedBox(
    width: 120, // کمی عریض‌تر برای جا شدن متن تاریخ
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.calendar_today, size: 18),
              onPressed: () => _pickMaintenanceDate(item),
            ),
            // نمایش تاریخ ثبت شده در صورت وجود
            if (item.serviceDate.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  item.serviceDate,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.websiteUrl.trim().isNotEmpty && !(item.contact.trim().isEmpty && _isValidPhoneNumber(workshopPhone)))
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.link, color: Colors.blue, size: 18),
                onPressed: () => _openMaintenanceLink(item),
                tooltip: translate('open_website', widget.currentLang),
              ),
            if (item.websiteUrl.trim().isNotEmpty && (item.key == 'tuv' || !(item.contact.trim().isEmpty && _isValidPhoneNumber(workshopPhone))))
              const SizedBox(width: 8),

            if (item.key != 'tuv')
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.phone, color: Colors.green, size: 18),
                onPressed: () => _callMaintenanceContact(item),
                tooltip: translate('call', widget.currentLang),
              ),
          ],
        ),
      ],
    ),
  ),
),
                  
                  DataCell(
                    SizedBox(
                      width: 160,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
GestureDetector(
  onTap: () async {
    if (!item.alarmEnabled) {
      // اگر لاستیک ۲ فصل نباشد، حتماً باید تاریخ پر شده باشد
      //if (item.serviceDate.trim().isEmpty && !(item.key == 'tires' && item.tireType == '2season')) {
        final is2SeasonTire = (item.key == 'tires' && item.tireType == '2season');
        if (item.serviceDate.trim().isEmpty && !is2SeasonTire) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                const SizedBox(width: 8),
                Text(widget.currentLang == 'fa' ? 'تنظیم تاریخ الزامی است' : 'Date Required'),
              ],
            ),
            content: Text(
              widget.currentLang == 'fa'
                  ? 'لطفاً ابتدا تاریخ (سرویس قبلی) را تنظیم کنید، سپس اقدام به فعال‌سازی آلارم نمایید.'
                  : 'Please set the date (previous service) first before enabling the alarm.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(translate('ok', widget.currentLang)),
              ),
            ],
          ),
        );
        return; 
      }
    }

    setState(() {
      item.alarmEnabled = !item.alarmEnabled;
      item.isConfigured = _isMaintenanceItemConfigured(item);
    });
    await _saveMaintenanceData();
    await _updateMaintenanceReminder(item);
  },
  child: Icon(
    item.alarmEnabled ? Icons.notifications_active : Icons.notifications_off,
    size: 22,
    color: item.alarmEnabled ? Colors.amber.shade700 : Colors.grey.shade400,
  ),
),
                             const SizedBox(width: 8), // یک فاصله مناسب بین آیکون‌ها
        
                              // دکمه‌ی تنظیم زمان آلارم (تنظیم یادآور)
                              IconButton(
                                icon: Icon(
                                  item.alarmEnabled ? Icons.alarm_on : Icons.alarm_off,
                                  color: item.alarmEnabled ? Colors.green : Colors.grey,
                                ),
                                onPressed: () => _showAlarmDialog(item),
                                tooltip: translate('set_reminder', widget.currentLang),
                              ),
                            ],
                          ),
                          
                          Row(
                            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_upward, size: 15),
                                    color: index == 0 ? Colors.grey : Colors.blue,
                                    onPressed: index == 0 ? null : () => _moveMaintenanceItem(item, -1),
                                    tooltip: translate('move_up', widget.currentLang),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.arrow_downward, size: 15),
                                    color: index == displayItems.length - 1 ? Colors.grey : Colors.blue,
                                    onPressed: index == displayItems.length - 1 ? null : () => _moveMaintenanceItem(item, 1),
                                    tooltip: translate('move_down', widget.currentLang),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 15),
                                onPressed: () => _deleteMaintenanceItem(item),
                                tooltip: translate('remove_service', widget.currentLang),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          translate('incomplete_row_note', widget.currentLang),
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }

  // متد نمایش پیام به کاربر برای پشتیبانی
  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            textDirection: TextDirection.rtl,
            children: [
              Icon(Icons.support_agent, color: Color(0xff004d99)),
              SizedBox(width: 8),
              Text(
                "پشتیبانی و پیشنهادات",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Tahoma',
                ),
              ),
            ],
          ),
          content: const Text(
            "شما می‌توانید مشکلات یا پیشنهادات خود را در مورد اپلیکیشن مستقیماً به ایمیل support.smartcarmanager@gmail.com ارسال کنید. آیا مایل به باز کردن برنامه ایمیل هستید؟",
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontFamily: 'Tahoma', fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("انصراف", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff004d99),
              ),
              onPressed: () {
                Navigator.pop(context); // بستن دیالوگ
                _sendSupportEmail(); // باز کردن ایمیل
              },
              child: const Text("ارسال ایمیل", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  String? _encodeQueryParameters(Map<String, String> params) {
  return params.entries
      .map((MapEntry<String, String> e) =>
          '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
      .join('&');
}

  // متد باز کردن برنامه ایمیل کاربر با متن پیش‌فرض
  Future<void> _sendSupportEmail() async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: 'support.smartcarmanager@gmail.com',
    query: _encodeQueryParameters({
      'subject': 'پیشنهاد یا گزارش مشکل در اپلیکیشن',
      'body': 'سلام تیم پشتیبانی،\n\nمن پیشنهاد یا مشکلی درباره اپلیکیشن داشتم که در زیر مطرح می‌کنم:\n\n',
    }),
  );

  try {
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('امکان باز کردن مستقیم برنامه ایمیل وجود ندارد. لطفاً به صورت دستی به ایمیل ما پیام دهید.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطایی در اجرای برنامه ایمیل رخ داد: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}


  // لیست پارکینگ‌ها (دقیقاً با همان استایلی که برای بنزین داشتی)
  Widget _buildParkingList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        // بخش انتخاب حالت نمایش برای پارکینگ
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SegmentedButton<String>(
            segments: [
            //const [
              ButtonSegment(
                value: 'map',
                //label: Text('Map View'),
                label: Text(translate('map_view', widget.currentLang)),
                icon: Icon(Icons.map),
              ),
              ButtonSegment(
                value: 'list',
                //label: Text('List View'),
                label: Text(translate('list_view', widget.currentLang)),
                icon: Icon(Icons.list),
              ),
            ],
            selected: {parkingViewMode},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                parkingViewMode = newSelection.first;
              });
            },
          ),
        ),

        // نمایش بر اساس حالت انتخاب شده
        Expanded(
          child: parkingViewMode == 'map'
              ? _buildParkingMap()
              : ListView.builder(
                  itemCount: stations.length,
                  itemBuilder: (context, index) {
                    final s = stations[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.local_parking,
                          color: Colors.blue,
                        ),
                        title: Text(s['name'] ?? 'Parkhaus'),
                        subtitle: Text("${s['street']} - ${s['dist']} km"),
                        trailing: Text(
                          "${s['free_slots'] ?? 'N/A'}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        onTap: () => _openMap(s['lat'], s['lng']),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

@override
Widget build(BuildContext context) {
  // این بخش جادویی باعث میشه _fontScale روی کل اجزای صفحه اثر بذاره
  return MediaQuery(
    data: MediaQuery.of(context).copyWith(
      // در نسخه‌های جدید فلاتر از textScaler استفاده می‌شود
      textScaler: TextScaler.linear(_fontScale), 
    ),
    child: Stack( // کل اسکافولد را داخل استک می‌گذاریم
      children: [    
    Scaffold(
      appBar: AppBar(     
       title: GestureDetector(
          onDoubleTap: () async {
            // فقط در صورتی که در مود تست باشیم کار کند
            if (AppTimelineManager().isTestingMode) {
              await AppTimelineManager().resetTimelineForTesting();
              
              // آپدیت کردن استیت کل صفحه برای اعمال فوری تغییرات بنر و تبلیغات
              setState(() {}); 

              // نمایش یک پیغام کوچک در پایین صفحه جهت اطمینان از ریست شدن
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⏱️ Timeline Reset Successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: Text(
            _selectedIndex == 0 
                ? translate('fuel_live', widget.currentLang) 
                : translate('car_service_parking', widget.currentLang),
          ),
        ),
        centerTitle: true,
        actions: [  
          IconButton(
                icon: const Icon(Icons.mark_email_unread_outlined),
                tooltip: 'تنظیم ایمیل یادآور',
                onPressed: () => _showEmailSetupDialog(context),
              ),       
          IconButton(
            icon: const Icon(Icons.settings_applications),
            onPressed: () => Geolocator.openAppSettings(),
            tooltip: 'Settings',
          ),
          IconButton(
            icon: const Icon(Icons.support_agent_outlined),
            tooltip: 'پشتیبانی و پیشنهادات',
            onPressed: _showSupportDialog,
          ),
          // دکمه‌های زوم برای بزرگ و کوچک کردن همه چیز
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() {
                if (_fontScale < 1.5) _fontScale += 0.1;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() {
                if (_fontScale > 0.8) _fontScale -= 0.1;
              });
            },
          ),
        ],
      ),

      body: _selectedIndex == 0
          ? Column(
              children: [
                // بنر تحلیل نفت
                if (oilAnalysis != null) _buildOilBanner(), 
                
                // محتویات صفحه بنزین
                Expanded(child: _buildFuelPage(context)),
              ],
            )
          : _buildServicePage(),

      bottomNavigationBar: Column(
       mainAxisSize: MainAxisSize.min, // مانع از پر شدن کل صفحه توسط کالم می‌شود
        children: [
          
          // ۱. بخش هوشمند بنر فیس‌تیر و تبلیغات گوگل (مخصوص کاربران غیرپرمیوم)
          ValueListenableBuilder<bool>(
            valueListenable: PurchaseManager().isPremiumUser,
            builder: (context, isPremium, child) {
              // اگر کاربر پرمیوم باشد، کل این بخش (بنرها و تبلیغات ادموب) کلاً غیب می‌شود
              if (isPremium) return const SizedBox.shrink();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                
                  if (AppTimelineManager().currentTier >= 1) ...[
                     _buildBottomPremiumBanner(context, widget.currentLang),
                    if (_isAdLoaded && _bannerAd != null)
                      Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: AdWidget(ad: _bannerAd!),
                      )
                    else
                      Container(
                        width: double.infinity,
                        height: 50,
                        color: Colors.grey.shade50,
                        alignment: Alignment.center,
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ],
              );
            },
          ),

          BottomNavigationBar(  
            currentIndex: _selectedIndex,
            onTap: (index) {
              if (index == 1) {
                if (!AppLicenseManager.isFeatureActive('car_service')) {
                  // از ماه ۷ به بعد پاپ‌آپ باز می‌شود و با return جلوی تغییر تب گرفته می‌شود
                  AppLicenseManager.showPremiumDialog(context);
                  return; 
                }
              }

              int tier = AppTimelineManager().currentTier;
              bool isPremium = PurchaseManager().isPremiumUser.value;

              // 📄 فاز ۲ و بالاتر (۳۰ روز به بعد): تبلیغ بین‌صفحه‌ای موقع تغییر تب
              if (!isPremium && tier >= 2) {
                AppAdManager().showInterstitialAd(() {
                  _selectMainTab(index);
                });
              } else {
                _selectMainTab(index);
              }             

            },
            items: [ 
              BottomNavigationBarItem(
                icon: const Icon(Icons.local_gas_station),
                label: translate('nav_fuel', widget.currentLang),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.build_circle),
                label: translate('nav_services', widget.currentLang),
              ),
            ],
          ),
        ],
      ),
    ), // 👈 این پرانتز برای بستن صحیح ویجت Scaffold جا افتاده بود که اضافه شد
    ValueListenableBuilder<bool>(
          valueListenable: PurchaseManager().isProcessing,
          builder: (context, isProcessing, child) {
            if (!isProcessing) return const SizedBox.shrink();
            return Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      translate('connecting_google_play', widget.currentLang),
                      style: const TextStyle(color: Colors.white, decoration: TextDecoration.none, fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
      ),
  );
}

  Widget _buildClassicFuelPage() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedFuel,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down_circle, color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                  items: [
                    DropdownMenuItem(
                      value: 'diesel',
                      child: Row(
                        children: [
                          const Icon(Icons.oil_barrel, color: Colors.black54, size: 20),
                          const SizedBox(width: 10),
                          Text(translate('fuel_diesel', widget.currentLang)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'e10',
                      child: Row(
                        children: [
                          const Icon(Icons.local_gas_station, color: Colors.green, size: 20),
                          const SizedBox(width: 10),
                          const Text('E10'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'e5',
                      child: Row(
                        children: [
                          const Icon(Icons.local_gas_station, color: Colors.green, size: 20),
                          const SizedBox(width: 10),
                          const Text('E5'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'ev',
                      child: Row(
                        children: [
                          const Icon(Icons.electric_car, color: Colors.blue, size: 20),
                          const SizedBox(width: 10),
                          Text(translate('fuel_ev', widget.currentLang)),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'parking',
                      child: Row(
                        children: [
                          const Icon(Icons.local_parking, color: Colors.orange, size: 20),
                          const SizedBox(width: 10),
                          Text(translate('parking', widget.currentLang)),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) _onFuelTypeChanged(newValue);
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      textInputAction: TextInputAction.search,
                      onChanged: (value) {
                        setState(() {});
                        _updatePlaceSuggestions(value);
                      },
                      onSubmitted: (_) => _performSearch(),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        labelText: translate('search_label', widget.currentLang),
                        hintText: translate('search_hint', widget.currentLang),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => placeSuggestions = []);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: ElevatedButton.icon(
                            onPressed: isSearchLoading ? null : _performSearch,
                            icon: const Icon(Icons.search, size: 18),
                            label: Text(
                              isSearchLoading ? '...' : translate('search', widget.currentLang),
                              style: TextStyle(fontSize: 12 * _fontScale),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          flex: 4,
                          child: OutlinedButton.icon(
                            onPressed: _searchNearby,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: Text(
                              translate('location', widget.currentLang),
                              style: TextStyle(fontSize: 12 * _fontScale),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              translate('radius', widget.currentLang),
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10 * _fontScale),
                            ),
                            DropdownButton<double>(
                              value: const [5.0, 10.0, 20.0, 50.0].contains(searchRadius)
                                  ? searchRadius
                                  : 5.0,
                              isDense: true,
                              underline: Container(),
                              items: [5.0, 10.0, 20.0, 50.0].map((double val) {
                                return DropdownMenuItem<double>(
                                  value: val,
                                  child: Text(
                                    translate('km', widget.currentLang, {'val': val.toInt().toString()}),
                                    style: TextStyle(fontSize: 12 * _fontScale),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => searchRadius = val);
                                _searchStations(userLat, userLng, _searchController.text.trim());
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (placeSuggestions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...placeSuggestions.map((suggestion) {
                        return ListTile(
                          dense: true,
                          title: Text(suggestion['display_name']?.toString() ?? ''),
                          onTap: () {
                            _searchController.text = suggestion['display_name']?.toString() ?? '';
                            setState(() => placeSuggestions = []);
                            _performSearch();
                          },
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'map',
                  label: Text(translate('map_view', widget.currentLang)),
                  icon: const Icon(Icons.map),
                ),
                ButtonSegment(
                  value: 'list',
                  label: Text(translate('list_view', widget.currentLang)),
                  icon: const Icon(Icons.list),
                ),
              ],
              selected: {fuelViewMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() => fuelViewMode = newSelection.first);
              },
            ),
          ),
          if (fuelViewMode == 'map')
            selectedFuel == 'parking'
                ? _buildParkingMap(fill: false)
                : _buildProfessionalMap(fill: false),
          if (fuelViewMode == 'list') _buildStationsListView(nested: true),
        ],
      ),
    );
  }

  Widget _buildFuelPage(BuildContext context) {
    if (!_useCompactMapSearch) {
      return _buildClassicFuelPage();
    }
    return Stack(
      children: [
        Positioned.fill(
          child: fuelViewMode == 'map'
              ? (selectedFuel == 'parking' ? _buildParkingMap() : _buildProfessionalMap())
              : _buildStationsListView(),
        ),
        Positioned(
          top: 8,
          left: 8,
          right: 8,
          child: _buildCompactSearchOverlay(),
        ),
        Positioned(
          right: 10,
          bottom: 10,
          child: Material(
            color: Colors.white,
            elevation: 5,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: SegmentedButton<String>(
                showSelectedIcon: false,
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                segments: [
                  ButtonSegment(
                    value: 'map',
                    icon: const Icon(Icons.map, size: 18),
                    tooltip: translate('map_view', widget.currentLang),
                  ),
                  ButtonSegment(
                    value: 'list',
                    icon: const Icon(Icons.list, size: 18),
                    tooltip: translate('list_view', widget.currentLang),
                  ),
                ],
                selected: {fuelViewMode},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    fuelViewMode = newSelection.first;
                    _searchFocusNode.unfocus();
                  });
                },
              ),
            ),
          ),
        ),
        if (isLoading || isSearchLoading)
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(minHeight: 2),
          ),
      ],
    );
  }

  Widget _buildCompactSearchOverlay() {
    final bool showDrawer = _searchFocusNode.hasFocus &&
        (placeSuggestions.isNotEmpty || searchHistory.isNotEmpty);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withOpacity(0.96),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
            child: Row(
              children: [
                SizedBox(
                  width: 102,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFuel,
                      isDense: true,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, size: 18),
                      items: [
                        DropdownMenuItem(
                          value: 'diesel',
                          child: Text(
                            translate('fuel_diesel', widget.currentLang),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        const DropdownMenuItem(
                          value: 'e10',
                          child: Text('E10', style: TextStyle(fontSize: 12)),
                        ),
                        const DropdownMenuItem(
                          value: 'e5',
                          child: Text('E5', style: TextStyle(fontSize: 12)),
                        ),
                        DropdownMenuItem(
                          value: 'ev',
                          child: Text(
                            translate('fuel_ev', widget.currentLang),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'parking',
                          child: Text(
                            translate('parking', widget.currentLang),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        if (newValue != null) _onFuelTypeChanged(newValue);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    textInputAction: TextInputAction.search,
                    onChanged: (value) {
                      setState(() {});
                      _updatePlaceSuggestions(value);
                    },
                    onSubmitted: (_) => _performSearch(),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      hintText: translate('search_hint', widget.currentLang),
                      prefixIcon: const Icon(Icons.search, size: 18),
                      prefixIconConstraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      suffixIcon: _searchController.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              visualDensity: VisualDensity.compact,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => placeSuggestions = []);
                              },
                            ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue.shade100),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: translate('location', widget.currentLang),
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.my_location, size: 20),
                  onPressed: isSearchLoading ? null : _searchNearby,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<double>(
                    value: const [5.0, 10.0, 20.0, 50.0].contains(searchRadius)
                        ? searchRadius
                        : 5.0,
                    isDense: true,
                    items: [5.0, 10.0, 20.0, 50.0].map((double val) {
                      return DropdownMenuItem<double>(
                        value: val,
                        child: Text(
                          translate('km', widget.currentLang, {'val': val.toInt().toString()}),
                          style: const TextStyle(fontSize: 11),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setState(() => searchRadius = val);
                      _searchStations(userLat, userLng, _searchController.text.trim());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDrawer) ...[
          const SizedBox(height: 6),
          Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                children: [
                  ...placeSuggestions.map((suggestion) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 18),
                      title: Text(
                        suggestion['display_name']?.toString() ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        _searchController.text = suggestion['display_name']?.toString() ?? '';
                        setState(() => placeSuggestions = []);
                        _performSearch();
                      },
                    );
                  }),
                  if (placeSuggestions.isNotEmpty && searchHistory.isNotEmpty)
                    const Divider(height: 8),
                  if (searchHistory.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent Searches',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _clearSearchHistory,
                            child: const Text(
                              'Clear',
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ...searchHistory.map((history) {
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.history, size: 18, color: Colors.grey),
                      title: Text(
                        history,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      onTap: () {
                        _searchController.text = history;
                        _performSearch();
                      },
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStationsListView({bool nested = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView.builder(
                    padding: EdgeInsets.only(top: nested ? 8 : 72, bottom: nested ? 16 : 56),
                    shrinkWrap: nested,
                    physics: nested ? const NeverScrollableScrollPhysics() : null,
                    itemCount: stations.length,
                    itemBuilder: (context, index) {
                      final s = stations[index];
                      final double? priceValue = double.tryParse(
                        s['price'].toString(),
                      );
                      final bool isCheap =
                          priceValue != null && priceValue < 1.70;
                      final facilities = getFacilities(s['lat'], s['lng']);

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            _selectFuelStation(s);
                            _openMap(s['lat'], s['lng']);
                          },
                          onLongPress: () => _showDetails(s),
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(
                              12.0,
                            ), // کنترل کامل پدینگ دست خودمان است
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // بخش لوگو سمت چپ
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Colors.blue.withOpacity(0.1),
                                  child: const Icon(
                                    Icons.local_gas_station,
                                    color: Colors.blue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // بخش وسط (نام، آدرس، امکانات)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s['brand']?.toUpperCase() ??
                                                  s['name'],
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          _buildStatusBadge(s['isOpen']),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${s['street']} ${s['houseNumber']}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                         
                                          if (facilities['wc'] == 1)
                                            _buildIcon(Icons.wc, Colors.blue),
                                          if (facilities['lkw'] == 1)
                                            _buildIcon(
                                              Icons.local_shipping,
                                              Colors.orange,
                                            ),
                                          if (facilities['rest'] == 1)
                                            _buildIcon(
                                              Icons.restaurant,
                                              Colors.red,
                                            ),
                                          if (facilities['play'] == 1)
                                            _buildIcon(
                                              Icons.child_care,
                                              Colors.green,
                                            ),
                                          if (facilities['shop'] == 1)
                                            _buildIcon(
                                              Icons.shopping_basket,
                                              Colors.brown,
                                            ),
                                          if (facilities['wash'] == 1)
                                            _buildIcon(
                                              Icons.local_car_wash,
                                              Colors.cyan,
                                            ),
                                          const Spacer(),
                                          Text(
                                            "${s['dist']} km",
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      iconSize: 20,
                                      icon: Icon(
                                        selectedStationId == s['id']?.toString()
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: selectedStationId == s['id']?.toString()
                                            ? Colors.amber
                                            : Colors.grey,
                                      ),
                                      onPressed: () => _selectFuelStation(s),
                                      tooltip: selectedStationId == s['id']?.toString()
                                          ? 'Deselect station'
                                          : 'Select station',
                                    ),
                                    const SizedBox(height: 4),
                                    if (selectedFuel == 'parking')
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              // چک کن اگر فیلد وجود نداشت کرش نکند
                                              color:
                                                  (s['free_slots'] != null &&
                                                      s['free_slots'] is int &&
                                                      s['free_slots'] > 5)
                                                  ? Colors.green
                                                  : Colors.orange,
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Spaces: ${s['free_slots'] ?? 'N/A'}",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "${s['price'] ?? 'Public'}",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      )
                                    else
                                      // --- ظاهر پیش‌فرض برای بنزین، دیزل و EV ---
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "${s['price']}",
                                                style: TextStyle(
                                                  fontSize:
                                                      18 *
                                                      _fontScale, // اعمال بزرگ‌نمایی
                                                  fontWeight: FontWeight.bold,
                                                  color: selectedFuel == 'ev'
                                                      ? Colors.blue
                                                      : Colors.green,
                                                ),
                                              ),
                                              if (selectedFuel !=
                                                  'ev') // فلش برای برقی نباشد
                                                Icon(
                                                  isCheap
                                                      ? Icons.arrow_downward
                                                      : Icons.arrow_upward,
                                                  size: 16,
                                                  color: isCheap
                                                      ? Colors.green
                                                      : Colors.red,
                                                ),
                                            ],
                                          ),
                                          Text(
                                            selectedFuel == 'ev' ? "KW" : "EUR",
                                            style: const TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),

                                    // --- دکمه مسیریابی (مشترک برای همه حالات) ---
                                    const SizedBox(height: 4),
                                    IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.directions,
                                        color: Colors.blue,
                                        size: 28,
                                      ),
                                      onPressed: () =>
                                          _openMap(s['lat'], s['lng']),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
    );
  }


  // این متد را درون کلاس _FuelDashboardState قرار دهید
void _onFuelTypeChanged(String newFuelType) {
  if (selectedFuel == newFuelType) return;
  
  setState(() {
    selectedFuel = newFuelType;
    isLoading = true;
    stations = []; // خالی کردن لیست قبلی برای جلوگیری از پرش تصویر
    _mapStations = [];
  });
  
  // فراخوانی مجدد متد با موقعیت مکانی فعلی کاربر
  //fetchPrices(lat: userLat, lng: userLng);
  // ذخیره انتخاب جدید در حافظه
    Hive.box('settingsBox').put('lastSelectedFuel', newFuelType);
    
    // فراخوانی متد جامع جستجو با آخرین موقعیت مکانی (چه GPS چه شهر جستجو شده)
    _searchStations(userLat, userLng);
}

// فراخوانی این متد درون initState صفحه اصلی
Future<void> _checkThreeMonthMileageReminder() async {
  var box = Hive.box('settingsBox');
  String? lastCheckStr = box.get('lastMileageReminderDate');
  DateTime now = DateTime.now();

  if (lastCheckStr == null) {
    // اولین بار تاریخ امروز را ذخیره میکنیم تا ۳ ماه بعد هشدار دهد
    box.put('lastMileageReminderDate', now.toIso8601String());
    return;
  }

  DateTime lastCheck = DateTime.parse(lastCheckStr);
  
  // بررسی گذشت ۹۰ روز (۳ ماه)
  if (now.difference(lastCheck).inDays >= 90) {
    
    // ۱. زمان‌بندی نوتیفیکیشن صبحگاهی برای فردا ساعت 09:00 صبح
    DateTime morningTime = DateTime(now.year, now.month, now.day + 1, 9, 0);
    await NotificationService.showScheduledNotification(
      id: 888,
      title: translate('performance_update_title', widget.currentLang),
      body: translate('performance_update_body', widget.currentLang),
      scheduledTime: morningTime,
    );

    // ۲. نمایش دایالوگ آنی درون برنامه در صورتی که کاربر هم‌اکنون داخل اپ است
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(translate('performance_update_title', widget.currentLang)),
          content: Text(translate('performance_update_body', widget.currentLang)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translate('save', widget.currentLang)),
            ),
          ],
        ),
      );
    }

    // بروزرسانی تاریخ آخرین چک برای ۳ ماه آینده
    box.put('lastMileageReminderDate', now.toIso8601String());
  }
}



Future<void> _saveEmailSettings() async {
  var box = Hive.box('settingsBox');
  String email = _emailController.text.trim();

  await box.put('enableEmailReminders', enableEmailReminders);
  await box.put('userEmail', email);

  // اگر فعال بود، اطلاعات را در فایرستور ثبت می‌کنیم تا سرویس ابری سر ساعت ۹ صبح ایمیل بزند
  if (enableEmailReminders && email.isNotEmpty) {
    String deviceId = "unknown_tanken_device";
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        var androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
      } else if (Platform.isIOS) {
        var iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? "unknown_ios";
      }

      await FirebaseFirestore.instance.collection('email_notifications').doc(deviceId).set({
        'email': email,
        'subscribed': enableEmailReminders,
        'target_hour': "09:00",
        'last_updated': Timestamp.fromDate(DateTime.now()),
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تنظیمات ارسال ایمیل با موفقیت ذخیره شد.')),
      );
    } catch (e) {
      print("Firestore Email Sync Error: $e");
    }
  }
}


Widget _buildEmailNotificationOption() {
  return Card(
    margin: const EdgeInsets.all(12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.email_outlined, color: Colors.blueAccent),
                  SizedBox(width: 8),
                  Text(
                    'ارسال هشدارهای مهم (TÜV) به ایمیل',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              Switch(
                value: enableEmailReminders,
                onChanged: (val) {
                  setState(() {
                    enableEmailReminders = val;
                  });
                  _saveEmailSettings();
                },
              ),
            ],
          ),
          if (enableEmailReminders) ...[
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'ایمیل خود را وارد کنید (e.g. name@domain.com)',
                prefixIcon: const Icon(Icons.alternate_email),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40)),
              onPressed: _saveEmailSettings,
              child: Text(translate('save', widget.currentLang)),
            ),
            Text(
              'سررسید مواردی همچون معاینه فنی (TÜV) رأس ساعت 09:00 صبح به این ایمیل ارسال خواهد شد.',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            )
          ]
        ],
      ),
    ),
  );
}

  // تابع کمکی برای برچسب باز/بسته
  Widget _buildStatusBadge(bool? isOpen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isOpen == true
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isOpen == true ? "OPEN" : "CLOSED",
        style: TextStyle(
          color: isOpen == true ? Colors.green : Colors.red,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _wrapMap({required bool fill, required Widget child}) {
    final painted = Stack(
      children: [
        Positioned.fill(child: RepaintBoundary(child: child)),
        if (_isLoadingMapStations)
          const Positioned(
            top: 8,
            right: 8,
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
    if (fill) return SizedBox.expand(child: painted);
    return SizedBox(
      height: 300 * (_fontScale > 1.2 ? 1.1 : 1.0),
      child: painted,
    );
  }

  void _activateFullMapSearchView() {
    if (!mounted) return;
    setState(() {
      _useCompactMapSearch = true;
      fuelViewMode = 'map';
    });
  }

  void _selectMainTab(int index) {
    if (!mounted) return;
    setState(() {
      _selectedIndex = index;
      if (index != 0) {
        _useCompactMapSearch = false;
        placeSuggestions = [];
        _searchFocusNode.unfocus();
      }
    });
  }

  // ۲. ویجت نقشه حرفه‌ای برای پارکینگ
  Widget _buildParkingMap({bool fill = true}) {
    return _wrapMap(
      fill: fill,
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: ll.LatLng(userLat, userLng),
          initialZoom: 15.0,
          onTap: (_, __) => _searchFocusNode.unfocus(),
          onPositionChanged: (camera, hasGesture) {
            if (hasGesture) {
              _onUserMovedMap(camera.center, mapKind: 'parking');
            }
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tenken.adak',
            keepBuffer: 2,
            panBuffer: 1,
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 25 * _fontScale,
                height: 25 * _fontScale,
                point: ll.LatLng(userLat, userLng),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(Icons.my_location, size: 15 * _fontScale, color: Colors.white),
                ),
              ),
              for (final s in _visibleMapStations)
                if (_pointOfStation(s) != null)
                  Marker(
                    width: 34 * _fontScale,
                    height: 34 * _fontScale,
                    alignment: Alignment.center,
                    point: _pointOfStation(s)!,
                    child: GestureDetector(
                      onTap: () {
                        final point = _pointOfStation(s)!;
                        _openMap(point.latitude, point.longitude);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E88E5),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 3,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

Widget _buildProfessionalMap({bool fill = true}) {
  return _wrapMap(
    fill: fill,
    child: FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: ll.LatLng(userLat, userLng),
        initialZoom: 13.0,
        onTap: (_, __) => _searchFocusNode.unfocus(),
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture) _onUserMovedMap(camera.center);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tenken.adak',
          keepBuffer: 2,
          panBuffer: 1,
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 25 * _fontScale,
              height: 25 * _fontScale,
              point: ll.LatLng(userLat, userLng),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.my_location, size: 15 * _fontScale, color: Colors.white),
              ),
            ),
            for (final s in _visibleMapStations)
              if (_pointOfStation(s) != null)
                Marker(
                  width: 72 * _fontScale,
                  height: 36 * _fontScale,
                  point: _pointOfStation(s)!,
                  child: GestureDetector(
                    onTap: () {
                      final point = _pointOfStation(s)!;
                      _openMap(point.latitude, point.longitude);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: s['isOpen'] == true ? Colors.blueAccent : Colors.blueGrey,
                        borderRadius: BorderRadius.circular(10 * _fontScale),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          _mapMarkerLabel(s),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * _fontScale,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
          ],
        ),
      ],
    ),
  );
}

  // این تابع جادویی برای فرار از ارور LatLng
  dynamic dynamicLatLng(double lat, double lng) {
    // این کد باعث میشه flutter_map فکر کنه داره LatLng واقعی میگیره
    return Function.apply(MapOptions().initialCenter.runtimeType as Function, [
      lat,
      lng,
    ]);
  }



}
