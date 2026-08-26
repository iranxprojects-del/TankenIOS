import 'package:latlong2/latlong.dart' as ll;
import 'package:flutter/material.dart';

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

//import 'package:latlong2/latlong2.dart' as real_latlong;

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
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  await Hive.openBox('carServiceBox');
  await Hive.openBox('searchBox');
  await Hive.openBox('oilBox');
  await NotificationService.init();

  await AppTimelineManager().initializeAndSync();
  AppAdManager().loadInterstitialAd();
  AppAdManager().loadRewardedAd(); 
  
  runApp(const AdakTenkenPro());
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
  double searchRadius = 10.0; // شعاع جستجو به کیلومتر
  BannerAd? _bannerAd;
  bool enableEmailReminders = false;
  TextEditingController _emailController = TextEditingController();

  bool _isAdLoaded = false;
  final MapController _mapController = MapController();
  Key _mapKey = UniqueKey();
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
  List<String> searchHistory = [];
  List<Map<String, String>> placeSuggestions = [];
  bool isSearchLoading = false;

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: AppAdManager().bannerUnitId,//'ca-app-pub-3940256099942544/6300978111', // آیدی تست بنر گوگل
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() { _isAdLoaded = true; });
          }
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // پاک کردن تبلیغ از حافظه وقتی صفحه بسته می‌شود
    PurchaseManager().dispose();
    _searchController.dispose();
    _priceController.dispose();
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

  void _showPremiumPaywall() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(translate('upgrade_to_premium', widget.currentLang)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, size: 50, color: Colors.orange),
          const SizedBox(height: 12),
          Text(
           translate('premium_desc', widget.currentLang), textAlign: TextAlign.center, style: const TextStyle(fontSize: 14),            
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(translate('cancel', widget.currentLang)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.pop(context);
            PurchaseManager().buyPremium(); // فراخوانی متد خرید گوگل پلی
          },
          child: Text(translate('buy_premium', widget.currentLang), style: const TextStyle(color: Colors.white)),
        )
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

  Widget _buildPriceAlertSetter() {
    // اگر دیتایی لود نشده یا لیستی نداریم، ویجت را نشان نده
    if (stations.isEmpty) return const SizedBox.shrink();

    // تنظیم مقدار اولیه بر اساس ارزان‌ترین قیمت فعلی (فقط برای بار اول)
    if (myThreshold == null) {
      myThreshold = stations[0]['price'];
      _priceController.text = myThreshold!.toStringAsFixed(2);
    }

    return Card(
      margin: const EdgeInsets.all(15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Text(
              translate('set_price_alert_title', widget.currentLang),
              //"Set Price Drop Alert",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              translate('set_price_alert_subtitle', widget.currentLang),
              //"Get notified when price goes below this amount",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle,
                    color: Colors.red,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      myThreshold = (myThreshold ?? 0.0) - 0.02;
                      _priceController.text = myThreshold!.toStringAsFixed(2);
                    });
                  },
                ),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: _priceController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      suffixText: "€",
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (val) {
                      myThreshold = double.tryParse(val) ?? myThreshold;
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.green,
                    size: 35,
                  ),
                  onPressed: () {
                    setState(() {
                      myThreshold = (myThreshold ?? 0.0) + 0.02;
                      _priceController.text = myThreshold!.toStringAsFixed(2);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
              ),
              icon: const Icon(Icons.notifications_active),
              //label: const Text("Save Alert Settings"),
              label: Text(translate('save_alert_btn', widget.currentLang)),
              onPressed: () async {
                var box = await Hive.openBox('settingsBox');
                await box.put('targetPrice', myThreshold);
                // ذخیره نوع سوخت فعلی هم مهم است تا در بک‌گراند بدانیم چه چیزی را چک کنیم
                await box.put('alertFuelType', selectedFuel);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      //"Alert set for €${myThreshold!.toStringAsFixed(2)}",
                      translate('alert_success_snack', widget.currentLang, {
                        'price': myThreshold!.toStringAsFixed(2), }),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomPremiumBanner(BuildContext context, String currentLang) {
  final timelineManager = AppTimelineManager();
  final purchaseManager = PurchaseManager();

  // اگر کاربر قبلاً پرمیوم را خریده باشد، این بنر کلاً مخفی می‌شود
  if (purchaseManager.isPremiumUser.value) {
    return const SizedBox.shrink();
  }

  final bool isExpired = timelineManager.isFreeTierExpired;
  final int days = timelineManager.remainingFreeDays;
  final bool isRtl = currentLang == 'fa';

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

  Future<void> _handleLocationButton() async {
  // ۱. بررسی روشن بودن GPS دستگاه
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please enable Location Services (GPS).')),
    );
    return;
  }

  // ۲. پرسش دستی از کاربر (این همان بخشی است که "هر بار" سوال می‌پرسد)
  bool? userConfirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Location Access"),
      content: const Text("Do you want to use your current location to find nearby stations?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text("Yes, Locate Me"),
        ),
      ],
    ),
  );

  // اگر کاربر دکمه No یا خارج دیالوگ را زد، متوقف شو
  if (userConfirmed != true) return;

  // ۳. بررسی مجوزهای سیستم‌عاملی
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied.')),
      );
      return;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Permissions are permanently denied. Please enable in settings.')),
    );
    return;
  }

  // ۴. گرفتن لوکیشن و آپدیت کردن نقشه و لیست
  setState(() => isLoading = true);
  try {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high
    );
    
    setState(() {
      userLat = position.latitude;
      userLng = position.longitude;
    });
    _saveLastLocation(userLat, userLng);
    // جستجوی ایستگاه‌ها با لوکیشن جدید
    await _searchStations(userLat, userLng);
    
  } catch (e) {
    print("Error: $e");
  } finally {
    setState(() => isLoading = false);
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
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        searchLat = position.latitude;
        searchLng = position.longitude;
      }

      setState(() {
        userLat = searchLat;
        userLng = searchLng;
      });
      _saveLastLocation(searchLat, searchLng);

      const apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
      final url =
          //"https://creativecommons.tankerkoenig.de/json/list.php?lat=$searchLat&lng=$searchLng&rad=10&sort=price&type=$selectedFuel&apikey=$apiKey";
          "https://creativecommons.tankerkoenig.de/json/list.php?lat=$searchLat&lng=$searchLng&rad=$searchRadius&sort=price&type=$selectedFuel&apikey=$apiKey";

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true) {
          setState(() {
            stations = (data['stations'] as List).where((s) {
              return s['isOpen'] == true &&
                  s['price'] != null &&
                  s['price'] > 0;
            }).toList();

            stations.sort((a, b) => a['price'].compareTo(b['price']));
            _restoreSelectedStationAtTop();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  Future<void> _requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Location permission granted. You can now fetch nearby stations.",
          ),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enable location permission in app settings."),
        ),
      );
      await Geolocator.openAppSettings();
    }
  }

  Future<void> _openAppSettings() async {
    bool opened = await Geolocator.openAppSettings();
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Unable to open app settings. Please open settings manually.",
          ),
        ),
      );
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

  // Future<void> _saveSearchHistory(String query) async {
  //   if (query.trim().isEmpty) return;
  //   var box = await Hive.openBox('searchBox');
  //   final saved = box.get('history', defaultValue: <String>[]) as List<dynamic>;
  //   final history = saved.cast<String>().toList();
  //   history.remove(query);
  //   history.insert(0, query);
  //   if (history.length > 10) history.removeLast();
  //   await box.put('history', history);
  //   setState(() {
  //     searchHistory = history;
  //   });
  // }

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
    // ۲. تلاش برای جابجایی دوربین نقشه (بدون ایجاد خطا اگر نقشه رندر نشده باشد)
    try {
      _mapController.move(ll.LatLng(lat, lng), 13.0);
    } catch (e) {
      // این بخش ارور "MapController not ready" را نادیده می‌گیرد
      debugPrint("Map not ready yet, skipping controller move.");
    }

    // ۳. به‌روزرسانی فیلد متن و ذخیره در تاریخچه (بدون تکراری)
    final displayName = place['display_name'] ?? query;
    _searchController.text = displayName;
    await _saveSearchHistory(displayName);

    // ۴. دریافت لیست ایستگاه‌های جدید
    await _searchStations(lat, lng, query);
    
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
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    userLat = position.latitude;
    userLng = position.longitude;

    // گرفتن ایستگاه‌ها
    await _searchStations(userLat, userLng);

    // حرکت نرم روی نقشه با مکانیزم گلِ Move!
    if (_mapController != null) {
      _mapController.move(ll.LatLng(userLat, userLng), 13.0);
    }
    
    setState(() {});

  } catch (e) {
    debugPrint('Location Error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  } finally {
    if (mounted) {
      setState(() => isSearchLoading = false);
    }
  }
}

  // Future<void> _selectPlaceSuggestion(Map<String, String> place) async {
  //   final lat = double.tryParse(place['lat'] ?? '');
  //   final lng = double.tryParse(place['lon'] ?? '');
  //   if (lat == null || lng == null) return;

  //   _searchController.text = place['display_name'] ?? _searchController.text;
  //   setState(() {
  //     placeSuggestions = [];
  //   });
  //   await _saveSearchHistory(_searchController.text);
  //   await _searchStations(lat, lng);
  // }

  // void _toggleZoom() {
  //   setState(() {
  //     _fontScale = (_fontScale == 1.0) ? 1.6 : 1.0; // ۶۰ درصد بزرگتر
  //   });
  // }

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

    final url = Uri.parse("https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving");

    // 📺 فاز ۳ (روز ۶۰ تا ۹۰): نمایش ویدیو طولانی قبل از باز شدن نقشه
    if (!isPremium && tier >= 3) {
      AppAdManager().showNavigationRewardedAd(() async {
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
        }
      });
      return; // توقف اجرای خطوط بعدی تا زمان اتمام تبلیغ
    }

    // 🟢 فاز ۰ تا ۲: باز شدن عادی بدون ویدیو
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget _buildFacilityIcon(IconData icon, String stationId, String feature) {
    bool? isAvailable = facilitiesCache[stationId]?[feature];

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Icon(
        icon,
        size: 16,
        // اگر دیتا داشتیم و true بود رنگی، وگرنه خاکستری
        color: isAvailable == true ? Colors.blue : Colors.grey.shade300,
      ),
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
        // ردیف اول: آیکون و پیام تحلیل
        // Row(
        //   children: [
        //     Icon(Icons.auto_graph, color: Colors.blue.shade800, size: 20 * _fontScale),
        //     const SizedBox(width: 8),
        //     Expanded(
        //       child: Text(
        //         message,
        //         style: TextStyle(
        //           fontWeight: FontWeight.bold, 
        //           fontSize: 13 * _fontScale,
        //           color: Colors.blue.shade900
        //         ),
        //       ),
        //     ),
        //   ],
        // ),
        // const SizedBox(height: 10),
        // ردیف دوم: قیمت‌های ۳ روز اخیر
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


  // یک تابع کمکی برای اینکه کد تمیزتر شود و "Unknown" حذف شود
  Widget _buildDetailRow(
    IconData icon,
    String title, {
    bool? status,
    String? trailingText,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: (status == true || trailingText != null)
            ? Colors.blue
            : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 14 * _fontScale), // اعمال بزرگ‌نمایی
      ),
      trailing: Text(
        // اگر متن خاصی فرستاده بودیم (مثل قیمت) همان را نشان بده، در غیر این صورت Yes/No
        trailingText ??
            (status == true
                ? "Yes"
                : (status == false ? "No" : "Searching...")),
        style: TextStyle(
          color: (status == true || trailingText != null)
              ? Colors.green
              : Colors.grey,
          fontWeight: FontWeight.bold,
          fontSize: 16 * _fontScale, // اعمال بزرگ‌نمایی
        ),
      ),
    );
  }

  Future<void> loadOfflineData() async {
    try {
      String jsonString = await rootBundle.loadString(
        'assets/germany_stations.json',
      );
      List<dynamic> list = json.decode(jsonString);

      // تبدیل لیست به Map برای دسترسی سریع با کلید مختصات
      // کلید: "lat_lng" با دقت ۳ رقم اعشار برای خطای جزیی GPS
      for (var s in list) {
        String key =
            "${s['lat'].toStringAsFixed(3)}_${s['lng'].toStringAsFixed(3)}";
        offlineStations[key] = s;
      }
      setState(() {});
    } catch (e) {
      print("Error loading offline data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    loadOfflineData(); // لود کردن دیتای ۱۸ هزار ایستگاه
    _loadSavedCarModel();
    _loadMaintenanceData();
    _loadSearchHistory();
    _loadAnalysisData(); // تابعی که قیمت نفت رو میگیره و تحلیل میکنه
    _loadHistory();
    _loadEmailSettings();
    _checkThreeMonthMileageReminder();

    // --- کدهای جدید: خواندن آخرین لوکیشن از حافظه ---
    var settingsBox = Hive.box('settingsBox');
    userLat = settingsBox.get('lastLat', defaultValue: 52.5200);
    userLng = settingsBox.get('lastLng', defaultValue: 13.4050);
    selectedStationId = settingsBox.get('selectedStationId');
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
          }
        }
      });
    }
    selectedFuel = settingsBox.get('lastSelectedFuel', defaultValue: 'diesel');
   
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkNotificationPermissionOnFirstLaunch();
    _searchStations(userLat, userLng);
    _checkAndForceUpdate();
  });

  if (AppLicenseManager.shouldShowAds()) {
      _loadBannerAd();
    }  

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

// Future<void> _refreshAllMaintenanceReminders() async {
//   for (var item in maintenanceItems) {
//     // اگر آیتم لاستیک ۲ فصل نباشد و تاریخ هم خالی باشد، آلارم نباید روشن بماند
//     if (item.serviceDate.trim().isEmpty && !(item.key == 'tires' && item.tireType == '2season')) {
//       if (item.alarmEnabled) {
//         item.alarmEnabled = false;
//       }
//       await NotificationService.cancelMaintenanceNotification(item.key);
//       continue;
//     }
//   }
//   await NotificationService.cancelNotification(99999);

//   int activeCount = 0;
//   MaintenanceItem? singleItem;
//   String singleBody = '';

//   final now = DateTime.now();
//   final int currentKmValue = int.tryParse(currentKm) ?? -1;

//   for (var item in maintenanceItems) {
//     if (!item.alarmEnabled) continue;

//     String tempBody = '';

//     // ⚡ منطق اختصاصی برای لاستیک‌های ۲ فصل در آلمان
//     if (item.key == 'tires' && item.tireType == '2season') {
//       DateTime winterDeadline = DateTime(now.year, 10, 15); // ۱۵ اکتبر
//       DateTime summerDeadline = DateTime(now.year, 4, 15);  // ۱۵ آوریل
//       DateTime nextDeadline;
//       String tireTarget = '';

//       if (now.isAfter(summerDeadline) && now.isBefore(winterDeadline)) {
//         nextDeadline = winterDeadline;
//         tireTarget = widget.currentLang == 'fa' ? 'زمستانی' : 'Winter';
//       } else if (now.isAfter(winterDeadline)) {
//         nextDeadline = DateTime(now.year + 1, 4, 15);
//         tireTarget = widget.currentLang == 'fa' ? 'تابستانی' : 'Summer';
//       } else {
//         nextDeadline = summerDeadline;
//         tireTarget = widget.currentLang == 'fa' ? 'تابستانی' : 'Summer';
//       }

//       final int daysUntilDeadline = nextDeadline.difference(now).inDays;

//       if (daysUntilDeadline <= 14 && daysUntilDeadline >= 0) {
//         tempBody = widget.currentLang == 'fa'
//             ? 'کمتر از ۲ هفته ($daysUntilDeadline روز) به موعد قانونی تعویض لاستیک $tireTarget در آلمان باقی مانده است!'
//             : 'Less than 2 weeks ($daysUntilDeadline days) left for legal German $tireTarget tire change!';
//       } else if (daysUntilDeadline < 0) {
//         tempBody = widget.currentLang == 'fa' ? 'موعد قانونی تعویض لاستیک گذشته است!' : 'Legal tire change deadline has passed!';
//       } else {
//         tempBody = widget.currentLang == 'fa' ? 'وضعیت لاستیک‌ها عادی است.' : 'Tire status is normal.';
//       }
//     } 
//     // منطق پیش‌فرض سایر قطعات و سرویس‌ها
//     else {
//       if (item.serviceDate.isEmpty) continue;
      
//       final int intDays = item.intervalDays ?? getDefaultIntervalDays(item.key);
//       final int intKm = item.intervalKm ?? getDefaultIntervalKm(item.key);

//       final prevDate = _parseMaintenanceDate(item.serviceDate);
//       final DateTime dueDate = prevDate.year == 2100 ? DateTime(2100) : prevDate.add(Duration(days: intDays));

//       final int prevKm = int.tryParse(item.mileage) ?? -1;
//       final int targetKm = (prevKm > 0 && intKm > 0) ? (prevKm + intKm) : -1;

//       final bool hasDueDate = item.serviceDate.isNotEmpty && dueDate.year != 2100;
//       final bool hasTargetKm = targetKm > 0 && currentKmValue > 0;

//       int alertDaysThreshold = item.key == 'tuv' ? 45 : 30;
//       int alertKmThreshold = 1000;

//       final int daysUntil = hasDueDate ? dueDate.difference(now).inDays : 9999;
//       final int remainingKm = hasTargetKm ? (targetKm - currentKmValue) : 999999;

//       if (!hasDueDate && !hasTargetKm) {
//         tempBody = translate('service_active', widget.currentLang, {'item': _maintenanceTitle(item)});
//       } 
//       else if ((hasDueDate && daysUntil < 0) || (hasTargetKm && remainingKm < 0)) {
//         tempBody = translate('service_overdue', widget.currentLang, {'item': _maintenanceTitle(item)});
//       } 
//       else if ((hasDueDate && daysUntil <= alertDaysThreshold) || (hasTargetKm && remainingKm <= alertKmThreshold)) {
//         if (hasDueDate && daysUntil <= alertDaysThreshold && (!hasTargetKm || remainingKm > alertKmThreshold)) {
//           tempBody = translate('service_due_days', widget.currentLang, {'days': daysUntil.toString(), 'item': _maintenanceTitle(item)});
//         } else {
//           tempBody = translate('service_due_km', widget.currentLang, {'km': remainingKm.toString(), 'item': _maintenanceTitle(item)});
//         }
//       } 
//       else {
//         tempBody = translate('service_active', widget.currentLang, {'item': _maintenanceTitle(item)});
//       }
//     }

//     activeCount++;
//     if (tempBody.contains('due') || tempBody.contains('moed') || tempBody.contains('کمتر') || singleBody.isEmpty) {
//       singleItem = item;
//       singleBody = tempBody;
//     }
//   }

//   // --- بخش اصلاح شده برای مدیریت تداخل آلارم‌ها ---

//   // سناریو صفر: هیچ آلارم فعالی وجود ندارد
//   if (activeCount == 0) {
//     await NotificationService.cancelMaintenanceNotification('master');
//     for (var item in maintenanceItems) {
//       await NotificationService.cancelMaintenanceNotification(item.key);
//     }
//     return;
//   }

//   // DateTime scheduleTime = DateTime(now.year, now.month, now.day, 9, 0);
//   // if (!scheduleTime.isAfter(now)) {
//   //   scheduleTime = scheduleTime.add(const Duration(days: 1));
//   // }

//   DateTime scheduleTime = DateTime.now().add(const Duration(seconds: 10));

//   // سناریو اول: فقط یک آلارم فعال داریم
//   if (activeCount == 1 && singleItem != null) {
//     // ۱. حتماً آلارم دسته‌جمعی (master) را لغو می‌کنیم
//     await NotificationService.cancelMaintenanceNotification('master');
    
//     // ۲. سایر آلارم‌های انفرادی را لغو می‌کنیم (به جز این یکی)
//     for (var item in maintenanceItems) {
//       if (item.key != singleItem.key) {
//         await NotificationService.cancelMaintenanceNotification(item.key);
//       }
//     }

//     // ۳. حالا آلارم تکی را ثبت یا به روزرسانی می‌کنیم
//     await NotificationService.scheduleMaintenanceReminder(
//       itemKey: singleItem.key,
//       title: translate('service_reminder_title', widget.currentLang),
//       body: singleBody,
//       firstRun: scheduleTime,
//       repeatDaily: true,
//       payload: singleItem.key,
//       btnOpenText: translate('btn_open', widget.currentLang),
//       btnDeleteText: translate('btn_delete', widget.currentLang),
//       btnSnoozeText: translate('btn_snooze', widget.currentLang),
//     );
//   } 
//   // سناریو دوم: چند آلارم فعال داریم (باید یکی شوند)
//   else {
//     // ۱. تک‌تک آلارم‌های انفرادی را لغو می‌کنیم تا مزاحم آلارم دسته‌جمعی نشوند
//     for (var item in maintenanceItems) {
//       await NotificationService.cancelMaintenanceNotification(item.key);
//     }

//     // ۲. فقط آلارم دسته‌جمعی (master) را ثبت می‌کنیم
//     await NotificationService.scheduleMaintenanceReminder(
//       itemKey: 'master',
//       title: translate('service_reminder_title', widget.currentLang),
//       body: translate('grouped_service_alert_body', widget.currentLang, {'count': activeCount.toString()}),
//       firstRun: scheduleTime,
//       repeatDaily: true,
//       payload: 'master',
//       btnOpenText: translate('btn_open', widget.currentLang),
//       btnDeleteText: translate('btn_delete', widget.currentLang),
//       btnSnoozeText: translate('btn_snooze', widget.currentLang),
//     );
//   }
// }

Future<void> _refreshAllMaintenanceReminders() async {
  final now = DateTime.now();
  final int currentKmValue = int.tryParse(currentKm) ?? -1;
  bool anyOverdue = false;

  // ۱. بررسی وضعیت قطعات و تشخیص اینکه آیا موردی سررسید شده یا خیر
  for (var item in maintenanceItems) {
    
    // اگر تاریخ خالی باشد (بجز لاستیک ۲ فصل)، آلارم آن را خاموش می‌کنیم تا با UI هماهنگ شود
    if (item.serviceDate.trim().isEmpty && !(item.key == 'tires' && item.tireType == '2season')) {
      if (item.alarmEnabled) {
        item.alarmEnabled = false;
      }
      continue;
    }

    // اگر کاربر تیک آلارم این قطعه را کلاً روشن نکرده باشد، از آن عبور می‌کنیم
    if (!item.alarmEnabled) continue;

    // الف) بررسی وضعیت لاستیک‌های ۲ فصل آلمان
    if (item.key == 'tires' && item.tireType == '2season') {
      DateTime winterDeadline = DateTime(now.year, 10, 15); // ۱۵ اکتبر
      DateTime summerDeadline = DateTime(now.year, 4, 15);  // ۱۵ آوریل
      DateTime nextDeadline;

      if (now.isAfter(summerDeadline) && now.isBefore(winterDeadline)) {
        nextDeadline = winterDeadline;
      } else if (now.isAfter(winterDeadline)) {
        nextDeadline = DateTime(now.year + 1, 4, 15);
      } else {
        nextDeadline = summerDeadline;
      }

      final int daysUntilDeadline = nextDeadline.difference(now).inDays;
      
      // اگر کمتر از ۲ هفته (۱۴ روز) مانده باشد یا از موعد گذشته باشد
      if (daysUntilDeadline <= 14) {
        anyOverdue = true;
        break; // پیدا شد! نیازی به بررسی بقیه لیست نیست
      }
    } 
    // ب) بررسی سایر قطعات عادی (بر اساس تاریخ یا کیلومتر)
    else {
      bool isDateDue = false;
      bool isKmDue = false;

      // بررسی سررسید تاریخ
      if (item.serviceDate.trim().isNotEmpty) {
        final int intDays = item.intervalDays ?? getDefaultIntervalDays(item.key);
        final prevDate = _parseMaintenanceDate(item.serviceDate);
        if (prevDate.year != 2100) {
          final DateTime dueDate = prevDate.add(Duration(days: intDays));
          final int daysUntil = dueDate.difference(now).inDays;
          int alertDaysThreshold = item.key == 'tuv' ? 45 : 30;

          if (daysUntil <= alertDaysThreshold) {
            isDateDue = true;
          }
        }
      }

      // بررسی سررسید کیلومتر
      final int prevKm = int.tryParse(item.mileage) ?? -1;
      final int intKm = item.intervalKm ?? getDefaultIntervalKm(item.key);
      if (prevKm > 0 && intKm > 0 && currentKmValue > 0) {
        final int targetKm = prevKm + intKm;
        final int remainingKm = targetKm - currentKmValue;
        int alertKmThreshold = 1000;

        if (remainingKm <= alertKmThreshold) {
          isKmDue = true;
        }
      }

      // اگر بر اساس تاریخ یا کیلومتر موعدش رسیده باشد
      if (isDateDue || isKmDue) {
        anyOverdue = true;
        break; // پیدا شد! بقیه حلقه را متوقف کن
      }
    }
  }

  // ۲. لغو تمام آلارم‌های انفرادی قدیمی جهت جلوگیری از تداخل نوتیفیکیشن‌ها
  for (var item in maintenanceItems) {
    await NotificationService.cancelMaintenanceNotification(item.key);
  }

  // ۳. تنظیم زمان اجرای آلارم (موقتاً ۱۰ ثانیه بعد برای تست سریع)
  // نکته: پس از اتمام تست، می‌توانید خط زیر را با زمان ثابت ۹ صبح فردا جایگزین کنید.
  //DateTime scheduleTime = DateTime.now().add(const Duration(seconds: 10));
  DateTime scheduleTime = DateTime(now.year, now.month, now.day, 9, 0);
  if (!scheduleTime.isAfter(now)) {
    scheduleTime = scheduleTime.add(const Duration(days: 1));
  }

  // ۴. ثبت یا لغو آلارم واحد (Master)
  if (anyOverdue) {
    // ثبت تک آلارم کلی
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
    // اگر هیچ قطعه‌ای سررسید نشده بود، آلارم کلی را پاک کن
    await NotificationService.cancelMaintenanceNotification('master');
  }
}

  // متد آپدیت تکی حالا فقط رفرش کلی را صدا می‌زند تا همه‌چیز یکپارچه بررسی شود
  Future<void> _updateMaintenanceReminder(MaintenanceItem item) async {
    await _refreshAllMaintenanceReminders();
  }

  List<MaintenanceItem> _sortedMaintenanceItems() {
    final items = List<MaintenanceItem>.from(maintenanceItems);
    items.sort((a, b) {
      final aIncomplete = !_isMaintenanceItemConfigured(a);
      final bIncomplete = !_isMaintenanceItemConfigured(b);
      if (aIncomplete != bIncomplete) {
        return aIncomplete ? -1 : 1;
      }
      return _parseMaintenanceDate(a.serviceDate).compareTo(_parseMaintenanceDate(b.serviceDate));
    });
    return items;
  }

  Future<void> _pickMaintenanceDate(MaintenanceItem item) async {
    final initialDate = _parseMaintenanceDate(item.serviceDate).year == 2100
        ? DateTime.now()
        : _parseMaintenanceDate(item.serviceDate);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
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
      Position position = await Geolocator.getCurrentPosition();
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
        "https://api.openchargemap.io/v3/poi/?output=json&countrycode=DE&latitude=$searchLat&longitude=$searchLng&maxresults=20&compact=true&verbose=false&key=$apiKey";
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
        });
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
        content: Text(
          widget.currentLang == 'fa'
              ? 'پارکینگی در این محدوده یافت نشد. در حال انتقال به گوگل‌مپ...'
              : 'No parking data found. Redirecting to Google Maps...',
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.orange.shade700,
      ),
    );
  }

  // ۱. ساختن کوئری جستجوی هوشمند بر اساس اولویت داده‌ها
  String query = 'parking';

  if (postalCode != null && postalCode.trim().isNotEmpty) {
    // جستجو بر اساس کد پستی (مثلاً: parking near 30159)
    query = 'parking+near+${Uri.encodeComponent(postalCode.trim())}';
  } else if (cityName != null && cityName.trim().isNotEmpty) {
    // جستجو بر اساس نام شهر (مثلاً: parking near Hannover)
    query = 'parking+near+${Uri.encodeComponent(cityName.trim())}';
  } else { //if (isCurrentLocation) {
    // جستجوی مستقیم اطراف موقعیت فعلی کاربر با قابلیت GPS گوگل‌مپ
    query = 'parking+near+me';
  } 
  // else if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
  //   // جستجوی مستقیم در مختصات (فرمت استاندارد بدون کلمه near که دقیق عمل می‌کند)
  //   query = 'parking+$lat,$lng';
  // }

  final Uri googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$query');

  if (await canLaunchUrl(googleMapsUrl)) {
    await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('Could not launch Google Maps.');
  }
}

  // Future<void> _openGoogleMapsForParkingFallback(double lat, double lng) async {
  //   if (mounted) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           widget.currentLang == 'fa'
  //               ? 'پارکینگی در این محدوده یافت نشد. در حال انتقال به گوگل‌مپ...'
  //               : 'No parking data found. Redirecting to Google Maps...',
  //         ),
  //         duration: const Duration(seconds: 3),
  //         backgroundColor: Colors.orange.shade700,
  //       ),
  //     );
  //   }

  //   // ساختن لینک هوشمند جستجوی پارکینگ در حوالی مختصات کاربر/شهر انتخاب شده
  //   final Uri googleMapsUrl = Uri.parse(
  //       'https://www.google.com/maps/search/?api=1&query=parking+near+$lat,$lng');

  //   if (await canLaunchUrl(googleMapsUrl)) {
  //     await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
  //   } else {
  //     debugPrint('Could not launch Google Maps.');
  //   }
  // }

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
      Position position = await Geolocator.getCurrentPosition();
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
    final String url =
        "https://overpass-api.de/api/interpreter?data=[out:json];node(around:${(searchRadius * 1000).toInt()},$searchLat,$searchLng)[\"amenity\"=\"parking\"];out;";
        
    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "User-Agent": "GermanyFuelApp/1.0",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        List<dynamic> elements = decoded['elements'] ?? [];

        if (elements.isNotEmpty) {
          dataFound = true;
          
          setState(() {
            stations = elements.map((p) {
              var tags = p['tags'] ?? {};
              return {
                'name': tags['name'] ?? 'Parkplatz',
                'brand': 'Parking',
                'street': tags['street'] ?? 'Public Area',
                'houseNumber': '',
                'lat': p['lat'],
                'lng': p['lon'],
                'price': 'P', 
                'isOpen': true,
                'free_slots': 10,
                'dist': 'Nearby',
              };
            }).toList();
            _restoreSelectedStationAtTop();
          });
        }
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

  // Future<void> fetchParkingData({double? lat, double? lng}) async {
  //   setState(() {
  //     isLoading = true;
  //     stations = []; 
  //   });

  //   double searchLat = lat ?? 0.0;
  //   double searchLng = lng ?? 0.0;
  //   if (lat == null || lng == null) {
  //     Position position = await Geolocator.getCurrentPosition();
  //     searchLat = position.latitude;
  //     searchLng = position.longitude;
  //   }

  //   setState(() {
  //     userLat = searchLat;
  //     userLng = searchLng;
  //   });
  //   _saveLastLocation(searchLat, searchLng);
    
  //   final String url =
  //       "https://overpass-api.de/api/interpreter?data=[out:json];node(around:${(searchRadius * 1000).toInt()},$searchLat,$searchLng)[\"amenity\"=\"parking\"];out;";
        
  //   bool dataFound = false; // 👈 نشانگر وضعیت دریافت دیتا

  //   try {
  //     final response = await http
  //         .get(
  //           Uri.parse(url),
  //           headers: {
  //             "User-Agent": "GermanyFuelApp/1.0",
  //             "Accept": "application/json",
  //           },
  //         )
  //         .timeout(const Duration(seconds: 15));

  //     if (response.statusCode == 200) {
  //       Map<String, dynamic> decoded = json.decode(response.body);
  //       List<dynamic> elements = decoded['elements'];

  //       // اگر لیست خالی نبود، دیتا پیدا شده است
  //       if (elements.isNotEmpty) {
  //         dataFound = true;
          
  //         setState(() {
  //           stations = elements.map((p) {
  //             var tags = p['tags'] ?? {};
  //             return {
  //               'name': tags['name'] ?? 'Parkplatz',
  //               'brand': 'Parking',
  //               'street': tags['street'] ?? 'Public Area',
  //               'houseNumber': '',
  //               'lat': p['lat'],
  //               'lng': p['lon'],
  //               'price': 'P', 
  //               'isOpen': true,
  //               'free_slots': 10,
  //               'dist': 'Nearby',
  //             };
  //           }).toList();
  //           _restoreSelectedStationAtTop();
  //         });
  //       }
  //     }
  //   } catch (e) {
  //     print("Parking Error: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() => isLoading = false);
  //     }
      
  //     // 👈 اگر به هر دلیلی دیتا پیدا نشد (خطا یا خالی بودن)، گوگل مپ را باز کن
  //     if (!dataFound) {
  //       _openGoogleMapsForParkingFallback(searchLat, searchLng);
  //     }
  //   }
  // }



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

  Future<void> _addCustomMaintenanceItem() async {
    String customName = "";
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(translate('add_custom_service', widget.currentLang)),
          content: TextField(
            decoration: InputDecoration(
              labelText: translate('custom_service_name_label', widget.currentLang),
              hintText: translate('custom_service_hint', widget.currentLang),
            ),
            onChanged: (value) => customName = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translate('cancel', widget.currentLang)),
            ),
            ElevatedButton(
              onPressed: () {
                if (customName.trim().isNotEmpty) {
                  final newItem = MaintenanceItem(
                    key: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    title: customName.trim(),
                  );
                  setState(() {
                    maintenanceItems.add(newItem);
                  });
                  _saveMaintenanceData();
                  Navigator.pop(context);
                }
              },
              child: Text(translate('add_btn', widget.currentLang)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMaintenanceItem(MaintenanceItem item) async {
    setState(() {
      maintenanceItems.remove(item);
    });
    await _saveMaintenanceData();
    await NotificationService.cancelMaintenanceNotification(item.key);
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
          // 👈 یک SizedBox با حداکثر عرض مجاز (100) اضافه می‌کنیم
          SizedBox(
            width: 100, 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 👈 استفاده از Expanded به جای عرض ثابت
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus && item.mileage.isNotEmpty && currentKm.isNotEmpty) {
                        int entered = int.tryParse(item.mileage) ?? 0;
                        int current = int.tryParse(currentKm) ?? 0;
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
                          item.mileage = value;
                          item.isConfigured = _isMaintenanceItemConfigured(item);
                          await _saveMaintenanceData();
                          await _updateMaintenanceReminder(item);
                        }
                      },
                    ),
                  ),
                ),
                // 👈 محدود کردن فضای آیکون برای جلوگیری از Overflow
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

        // if (!hideMileage) ...[
        //   const SizedBox(height: 6),
        //   SizedBox(
        //     width: 100,
        //     child: TextField(
        //       keyboardType: TextInputType.number,
        //       decoration: InputDecoration(
        //         isDense: true,
        //         hintText: translate('km', widget.currentLang, {'val': ''}).trim(),
        //         border: const OutlineInputBorder(),
        //       ),
        //       controller: TextEditingController(text: item.mileage),
        //       onChanged: (value) async {
        //         item.mileage = value;
        //         item.isConfigured = _isMaintenanceItemConfigured(item);
        //         await _saveMaintenanceData();
        //         await _updateMaintenanceReminder(item);
        //       },
        //     ),
        //   ),
        // ],
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

  Widget _buildPreviousLogs() {
    return FutureBuilder(
      future: Hive.openBox('carServiceBox'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          var box = Hive.box('carServiceBox');
          // تبدیل مقادیر باکس به لیست و معکوس کردن (برای نمایش جدیدترین‌ها در بالا)
          final logs = box.values.toList().reversed.toList();

          if (logs.isEmpty) {
            return Center(
             child: Text(translate('no_history_found', widget.currentLang)),
            );
          }

          return Column(
            children: List.generate(logs.length, (index) {
              final item = logs[index] as Map;
              final dynamic key = box.keyAt(
                box.length - 1 - index,
              ); // پیدا کردن کلید اصلی برای حذف/ویرایش

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.history, color: Colors.white),
                ),
                title: Text("${item['type']} - ${item['model']}"),
                subtitle: Text(
                  "Date: ${item['date'].toString().split('T')[0]} | KM: ${item['km']}",
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // دکمه ویرایش
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.grey),
                      onPressed: () => _editServiceEntry(key, item),
                    ),
                    // دکمه حذف
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () async {
                        await box.delete(key);
                        setState(() {}); // رفرش لیست
                      },
                    ),
                  ],
                ),
              );
            }),
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }


  // ۱. حتماً کلمه async رو اینجا اضافه کن
void _editServiceEntry(dynamic key, Map data) async {
  
  // ۲. کارهای سنگین و async رو بیرون از setState انجام بده
  await Hive.box('carServiceBox').delete(key);
  await NotificationService.cancelNotification(101);

  // ۳. حالا وضعیت UI رو آپدیت کن
  setState(() {
    carModel = data['model'];
    selectedServiceType = data['type'];
    currentKm = data['km'];
  });

  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Editing ${data['type']}. Old record removed. Update fields and save.",
        ),
      ),
    );
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
                    if (_isAdLoaded && _bannerAd != null) ...[
                      
                      Container(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ] else ...[
                      // این کادر کوچک تا زمان لود شدن کامل تبلیغ از اینترنت نشان داده می‌شود
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
                  setState(() => _selectedIndex = index);
                });
              } else {
                setState(() => _selectedIndex = index);
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

  Widget _buildFuelPage(BuildContext context) {
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
                  isExpanded: true, // برای اینکه عرض کامل را بگیرد
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
                    if (newValue != null) {
                      _onFuelTypeChanged(newValue);




                      
                    }
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
        
          // --- فیلد سرچ ---
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: _updatePlaceSuggestions,
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
                  setState(() {
                    placeSuggestions = [];
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          

          Row(
            children: [
              // ۱. دکمه سرچ
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: isSearchLoading ? null : _performSearch,
                  icon: const Icon(Icons.search, size: 18),
                  label: Text(
                    //isSearchLoading ? '...' : 'Search',
                    isSearchLoading ? '...' : translate('search', widget.currentLang),
                    style: TextStyle(fontSize: 12 * _fontScale),
                  ),
                ),
              ),
              const SizedBox(width: 4),

              // ۲. دکمه لوکیشن من
              Expanded(
                flex: 4,
                child: OutlinedButton.icon(
                  onPressed: _searchNearby, // متدی که هانوفر رو پیدا می‌کنه
                  icon: const Icon(Icons.my_location, size: 18),
                  label: Text(
                    //'Location',
                    translate('location', widget.currentLang),
                    style: TextStyle(fontSize: 12 * _fontScale),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // ۳. بخش انتخاب شعاع (Radius)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(translate('radius', widget.currentLang), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10 * _fontScale)),
                  DropdownButton<double>(
                    value: searchRadius,
                    isDense: true, // برای اینکه جای کمتری بگیره
                    underline: Container(), // حذف خط زیر دراپ‌دان برای تمیزی
                    items: [5.0, 10.0, 20.0, 50.0].map((double val) {
                      return DropdownMenuItem<double>(
                        value: val,
                        child: Text(
                        //child: Text("${val.toInt()} km", 
                        translate('km', widget.currentLang, {'val': val.toInt().toString()}),
                        style: TextStyle(fontSize: 12 * _fontScale)),                      
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        searchRadius = val!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),

          // --- نمایش پیشنهادات مکان (Suggestions) ---
          if (placeSuggestions.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...placeSuggestions.map((suggestion) {
              return ListTile(
                title: Text(suggestion['display_name']?.toString() ?? ''),
                onTap: () {
                  _searchController.text = suggestion['display_name']?.toString() ?? '';
                  setState(() => placeSuggestions = []);
                  _performSearch();
                },
              );
            }).toList(),
          ],

      

if (searchHistory.isNotEmpty) ...[
      const Divider(),
      Theme(
        // حذف خطوط بالا و پایین ExpansionTile در حالت باز شده
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          // تنظیم چگالی بصری برای فشرده‌تر شدن (جایگزین mini)
          visualDensity: VisualDensity.compact,
          dense: true,
          title: Text(
            "Recent Searches", 
            style: TextStyle(fontSize: 12 * _fontScale, color: Colors.grey)
          ),
          trailing: TextButton(
            onPressed: _clearSearchHistory, 
            child: Text(
              "Clear", 
              style: TextStyle(color: Colors.red, fontSize: 11 * _fontScale)
            )
          ),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 40, 
                maxHeight: 150 * _fontScale, 
              ),
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Wrap(
                    spacing: 8.0 * _fontScale,
                    runSpacing: 0.0,
                    children: searchHistory.map((history) => ActionChip(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      padding: EdgeInsets.symmetric(horizontal: 6 * _fontScale, vertical: 2),
                      label: Text(
                        history, 
                        style: TextStyle(fontSize: 11 * _fontScale)
                      ),
                      onPressed: () {
                        _searchController.text = history;
                        _performSearch();
                      },
                    )).toList(),
                  ),
                ),
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
),

          // ۱.۵. بخش انتخاب حالت نمایش (Map یا List)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
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
              selected: {fuelViewMode},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  fuelViewMode = newSelection.first;
                });
              },
            ),
          ),

       
          const SizedBox(height: 10),

          // نمایش بر اساس حالت انتخاب شده
          if (fuelViewMode == 'map')
            _buildProfessionalMap(),
          // else
          //   //_buildPriceAlertSetter(),
          //   ...[
          //   // وقتی در حالت لیست هستیم، تنظیم آلارم را اینجا به صورت کشویی نشان می‌دهیم
          //   Padding(
          //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
          //     child: ExpansionTile(
          //       title: const Text(
          //         "Set Price Drop Alert",
          //         style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
          //       ),
          //       leading: const Icon(Icons.notifications_active, color: Colors.blue),
          //       backgroundColor: Colors.blue.withOpacity(0.05),
          //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //       collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          //       // children: [
          //       //   _buildPriceAlertSetter(), // همان تابع تنظیم آلارم تو
          //       //   const SizedBox(height: 10),
          //       // ],
          //     ),
          //   ),
          // ],

          if (fuelViewMode == 'list')
            isLoading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 50.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
                                          // _buildFacilityIcon(Icons.wc, s['id'], 'hasToilet'),
                                          // const SizedBox(width: 4),
                                          // _buildFacilityIcon(Icons.local_shipping, s['id'], 'isLKW'),
                                          // const SizedBox(width: 4),
                                          // _buildFacilityIcon(Icons.shopping_basket, s['id'], 'hasFood'),
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
                  ),
        ],
      ),
      //),
    );
  }


  // این متد را درون کلاس _FuelDashboardState قرار دهید
void _onFuelTypeChanged(String newFuelType) {
  if (selectedFuel == newFuelType) return;
  
  setState(() {
    selectedFuel = newFuelType;
    isLoading = true;
    stations = []; // خالی کردن لیست قبلی برای جلوگیری از پرش تصویر
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


Future<void> _toggleAlarmWithPermissionCheck(MaintenanceItem item, bool newValue) async {
  var box = Hive.box('settingsBox');
  bool isFirstAlarmAction = box.get('isFirstAlarmAction', defaultValue: true);

  if (newValue && isFirstAlarmAction) {
    // نمایش MessageBox راهنمایی
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('فعال‌سازی اعلان‌های برنامه', style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text(
            'برای دریافت هشدارهای سررسید سرویس خودرو، لطفا مطمئن شوید که دسترسی Notification این اپلیکیشن در تنظیمات سیستم‌عامل فعال است. اکنون به صفحه تنظیمات منتقل می‌شوید.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(translate('cancel', widget.currentLang)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // غیرفعال کردن پرچم اولین بار
                await box.put('isFirstAlarmAction', false);
                // انتقال مستقیم به صفحه تنظیمات اختصاصی اپلیکیشن در اندروید/آی‌او‌اس
                await Geolocator.openAppSettings();
              },
              child: const Text('انتقال به تنظیمات سیستم'),
            ),
          ],
        );
      },
    );
    return; // متوقف کردن موقت عملیات تا کاربر برگردد
  }

  // فرآیند عادی ذخیره‌سازی آلارم در صورت تایید قبلی یا غیرفعال‌سازی
  setState(() {
    item.alarmEnabled = newValue;
  });
  
  var serviceBox = Hive.box('carServiceBox');
  await serviceBox.put(item.key, item.toMap());
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

  // ۲. ویجت نقشه حرفه‌ای برای پارکینگ
  Widget _buildParkingMap() {
    if (stations.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 300,
      child: FlutterMap(
        options: MapOptions(
          initialCenter: ll.LatLng(
            stations[0]['lat'] as double,
            stations[0]['lng'] as double,
          ),
          initialZoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.tenken.adak',
          ),

          MarkerLayer(
            markers: stations.map((s) {
              return Marker(
                width: 90,
                height: 45,
                point: ll.LatLng(s['lat'] as double, s['lng'] as double),
                child: GestureDetector(
                  onTap: () => _openMap(s['lat'] as double, s['lng'] as double),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.greenAccent,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        const BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.local_parking,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

Widget _buildProfessionalMap() {
  return SizedBox(
    height: 300 * (_fontScale > 1.2 ? 1.1 : 1.0),
    child: FlutterMap(
      // این کلید باعث میشه با تغییر لوکیشن، نقشه بمیره و دوباره زنده بشه (Force Rebuild)
      key: _mapKey, 
      mapController: _mapController,
      options: MapOptions(
        initialCenter: ll.LatLng(userLat, userLng),
        initialZoom: 13.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.tenken.adak',
        ),
        MarkerLayer(
          markers: [
            // مارکر مکان فعلی خودت (نقطه قرمز)
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

            // مارکر ایستگاه‌ها
            if (stations.isNotEmpty)
              ...stations.map((s) {
                return Marker(
                  width: 90 * _fontScale,
                  height: 45 * _fontScale,
                  point: ll.LatLng(s['lat'] as double, s['lng'] as double),
                  child: GestureDetector(
                    onTap: () => _openMap(s['lat'] as double, s['lng'] as double),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(10 * _fontScale),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Center(
                        child: Text(
                          "€${s['price']}",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12 * _fontScale,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
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

  // ۳. طراحی حباب قیمت (دقیقاً شبیه Clever Tanken)
  Widget _buildPriceMarker(String price, bool isOpen) {
    return Container(
      decoration: BoxDecoration(
        color: isOpen ? Colors.blue.shade700 : Colors.grey,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [const BoxShadow(color: Colors.black26, blurRadius: 4)],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          "€$price",
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  } 
}
