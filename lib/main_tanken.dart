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

//import 'package:latlong2/latlong2.dart' as real_latlong;


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('settingsBox');
  await Hive.openBox('carServiceBox');
  await Hive.openBox('searchBox');
  await Hive.openBox('oilBox');
  await NotificationService.init();

  if (!kIsWeb) {
    Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // تسک اول: همون تسک ۲ ساعته خودت که داشتی
    Workmanager().registerPeriodicTask(
      "fuel-task-id",
      "periodicFuelCheck",
      frequency: const Duration(hours: 2),
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // ==========================================
    // منطق محاسبه زمان باقی‌مانده تا 9 صبح بعدی
    // ==========================================
    final now = DateTime.now();
    var targetTime = DateTime(now.year, now.month, now.day, 09, 30); // امروز ساعت 9

    // اگر الان از ساعت 9 صبح گذشته، هدف رو بذار برای 9 صبح فردا
    if (now.isAfter(targetTime)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    
    // محاسبه اختلاف زمان الان تا 9 صبح
    final delayTo9AM = targetTime.difference(now);

    // تسک دوم: گزارش قیمت راس ساعت 9 صبح هر روز
    Workmanager().registerPeriodicTask(
      "morning-fuel-task", // آیدی یکتا
      "morningFuelCheck", // اسم تسک
      frequency: const Duration(days: 1), // تکرار هر 24 ساعت
      initialDelay: delayTo9AM, // تاخیر تا اولین 9 صبح
      constraints: Constraints(
        networkType: NetworkType.connected, // حتما اینترنت وصل باشه
      ),
    );
  }
  
  runApp(const AdakTenkenPro());
}

// ==========================================
// آپدیت کردن callbackDispatcher برای مدیریت هر دو تسک
// ==========================================
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "periodicFuelCheck") {
      // این همون تسک قبلی خودته
      // await NotificationService.fetchPricesAndNotify();
    } 
    else if (task == "morningFuelCheck") {
      // این تسک جدیدیه که ساعت 9 صبح اجرا میشه
      await NotificationService.fetchMorningDieselPriceAndNotify();
    }
    return Future.value(true);
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
  bool isLoading = false;
  double _fontScale = 1.0;
  String carModel = "";
  //String selectedServiceType = 'Oil Change';
  String selectedServiceType = 'cat_oil'; // یا 'oil' (دقیقاً همان کلیدی که در translations.dart داری)
  String currentKm = '';
  int _selectedIndex = 0; // 0 برای بنزین، 1 برای سرویس‌ها
  String serviceView = 'history'; // مقدار پیش‌فرض: تاریخچه سرویس
  double userLat = 52.5200; // مقدار پیش‌فرض (برلین)
  double userLng = 13.4050;
  double searchRadius = 10.0; // شعاع جستجو به کیلومتر
  BannerAd? _bannerAd;
    bool _showPaywall = false;
  bool _isAdLoaded = false;
  final MapController _mapController = MapController();
  Key _mapKey = UniqueKey();
  Map<String, dynamic>? oilAnalysis; // متغیری برای ذخیره تحلیل نفت
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
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // آیدی تست بنر گوگل
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

  void _showPremiumPaywall() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      title: Text(widget.currentLang == 'fa' ? "ارتقا به نسخه ویژه" : "Upgrade to Premium"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.stars, size: 50, color: Colors.orange),
          const SizedBox(height: 12),
          Text(
            widget.currentLang == 'fa' 
              ? "با تهیه اشتراک ویژه، تبلیغات آزاردهنده به طور کامل حذف شده و بخش خدمات خودرو فعال می‌گردد."
              : "Unlock full features and completely remove ads from the interface instantly.",
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.currentLang == 'fa' ? "انصراف" : "Cancel"),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () {
            Navigator.pop(context);
            PurchaseManager().buyPremium(); // فراخوانی متد خرید گوگل پلی
          },
          child: Text(widget.currentLang == 'fa' ? "خرید نسخه پرمیوم" : "Buy Premium", style: const TextStyle(color: Colors.white)),
        )
      ],
    ),
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
            Text('Legal Privacy Consent'),
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

  Future<void> _searchStations(double lat, double lng) async {
    if (selectedFuel == 'ev') {
      await fetchEVStations(lat: lat, lng: lng);
    } else if (selectedFuel == 'parking') {
      await fetchParkingData(lat: lat, lng: lng);
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
    await _searchStations(lat, lng);
    
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

  Future<void> _selectPlaceSuggestion(Map<String, String> place) async {
    final lat = double.tryParse(place['lat'] ?? '');
    final lng = double.tryParse(place['lon'] ?? '');
    if (lat == null || lng == null) return;

    _searchController.text = place['display_name'] ?? _searchController.text;
    setState(() {
      placeSuggestions = [];
    });
    await _saveSearchHistory(_searchController.text);
    await _searchStations(lat, lng);
  }

  void _toggleZoom() {
    setState(() {
      _fontScale = (_fontScale == 1.0) ? 1.6 : 1.0; // ۶۰ درصد بزرگتر
    });
  }

  Future<void> _openMap(double lat, double lng) async {

    if (!AppLicenseManager.isFeatureActive('open_link_navigator')) {
      AppLicenseManager.showPremiumDialog(context);
      return;
    }
    // لینک استاندارد گوگل مپ برای مسیریابی (Direction) از مکان فعلی به مقصد
    final url = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving",
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Map<String, bool>> fetchStationFacilities(
    double lat,
    double lng,
  ) async {
    final query =
        """
  [out:json][timeout:15];
  (
    node(around:100, $lat, $lng)["amenity"="fuel"];
    way(around:100, $lat, $lng)["amenity"="fuel"];
  );
  out tags;
  """;

    try {
      final response = await http.post(
        Uri.parse("https://overpass-api.de/api/interpreter"),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['elements'] != null && data['elements'].isNotEmpty) {
          final Map<String, dynamic> tags = data['elements'][0]['tags'] ?? {};

          return {
            // اگر تگ toilets داشت یا اگر ویلچر داشت (معمولاً پمپ های ویلچرخور دستشویی دارند)
            'hasToilet':
                tags['toilets'] == 'yes' ||
                tags['wheelchair'] == 'yes' ||
                tags['wheelchair'] == 'limited',

            // اگر AdBlue داشت یا hgv بود، برای کامیون (LKW) مناسب است
            'isLKW':
                tags['hgv'] == 'yes' ||
                tags['fuel:adblue'] == 'yes' ||
                tags['fuel:diesel:class2'] == 'yes',

            // اگر کلمه shop یا supermarket یا convenience در تگ ها بود
            'hasFood':
                tags.containsKey('shop') ||
                tags['amenity'] == 'restaurant' ||
                tags['cuisine'] != null,
          };
        }
      }
    } catch (e) {
      print("OSM Error: $e");
    }
    return {'hasToilet': false, 'isLKW': false, 'hasFood': false};
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
    _loadSearchHistory();
    _loadAnalysisData(); // تابعی که قیمت نفت رو میگیره و تحلیل میکنه
    _loadHistory();
     if (!kIsWeb) {
     PurchaseManager().initialize(
    onError: (errorMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
      );
    },
   onSuccess: () {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(widget.currentLang == 'fa' ? "اشتراک ویژه فعال شد!" : "Premium activated!"),
      backgroundColor: Colors.green, // اضافه کردن رنگ برای ظاهر بهتر
    ), // سمی‌کالن اینجا کاملاً حذف شد
  ); // پرانتز شو اسنک‌بار اینجا به درستی بسته شد
},
  );
    //Hive.box('settingsBox').put('isPremiumUser', false);
    //NotificationService.testAlarmOneMinuteLater();
    NotificationService.scheduleDailyCarServiceAlert();
  }
    selectedFuel = Hive.box('settingsBox').get('lastSelectedFuel', defaultValue: 'diesel');
    //fetchPrices();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    _checkNotificationPermissionOnFirstLaunch();
  });

  if (AppLicenseManager.shouldShowAds()) {
      _loadBannerAd();
    }  

    // این تکه کد را به انتهای متد initState اضافه کنید:
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
            content: Text(widget.currentLang == 'fa' ? "اشتراک ویژه با موفقیت فعال شد!" : "Premium activated successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    },
  );
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
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'ahmdel@gmail.com',
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
          // تبدیل فرمت دیتا به فرمتی که در لیست نمایش می‌دهید
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

  Future<void> fetchParkingData({double? lat, double? lng}) async {
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

    // استفاده از Overpass API برای پیدا کردن پارکینگ‌های اطراف
    final String url =
        //"https://overpass-api.de/api/interpreter?data=[out:json];node(around:5000,$searchLat,$searchLng)[\"amenity\"=\"parking\"];out;";
        "https://overpass-api.de/api/interpreter?data=[out:json];node(around:${(searchRadius * 1000).toInt()},$searchLat,$searchLng)[\"amenity\"=\"parking\"];out;";
    try {
      //final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 15));
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              "User-Agent": "GermanyFuelApp/1.0", // یک نام دلخواه
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        Map<String, dynamic> decoded = json.decode(response.body);
        List<dynamic> elements = decoded['elements'];

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
              'price': 'P', // دیتای قیمت پارکینگ‌های عمومی معمولاً در API نیست
              'isOpen': true,
              'free_slots': 10, // مقدار تستی چون API رایگان ظرفیت لحظه‌ای نمیده
              'dist': 'Nearby',
            };
          }).toList();
        });
      }
    } catch (e) {
      print("Parking Error: $e");
    } finally {
      setState(() => isLoading = false);
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
        // تبلت انتخابگر بین سرویس و پارکینگ
        Padding(
          padding: const EdgeInsets.all(16.0),
          // child: SegmentedButton<String>(
          //   segments: const [
          //     ButtonSegment(
          //       value: 'history',
          //       label: Text('Car Service'),
          //       icon: Icon(Icons.history),
          //     ),
          //     ButtonSegment(
          //       value: 'parking',
          //       label: Text('Parking'),
          //       icon: Icon(Icons.local_parking),
          //     ),
          //   ],
          child: SegmentedButton<String>(
            segments: [ // 👈 const hazf shod
              ButtonSegment(
                value: 'history',
                label: Text(translate('tab_car_service', widget.currentLang)), // 👈
                icon: const Icon(Icons.history),
              ),
              ButtonSegment(
                value: 'parking',
                label: Text(translate('tab_parking', widget.currentLang)), // 👈
                icon: const Icon(Icons.local_parking),
              ),
            ],
            selected: {serviceView},
            onSelectionChanged: (Set<String> newSelection) {
              setState(() {
                serviceView = newSelection.first;
                stations = []; // لیست رو خالی می‌کنیم برای دیتای جدید
              });
              if (serviceView == 'parking') {
                fetchParkingData(); // فراخوانی دیتای پارکینگ
              }
            },
          ),
        ),

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

  // لیست سرویس‌های ماشین
  Widget _buildServiceHistoryList() {
    final List<String> serviceKeys = [
  'cat_oil', 
  'cat_timing_belt', 
  'cat_brake', 
  'cat_spark', 
  'cat_tires', 
  'cat_tuv'
];
    return ListView(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //const 
                Center(
                  child: Text(
                    translate('smart_service_log', widget.currentLang),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Car Model Field ---
                TextField(
                  decoration: 
                  //const 
                  InputDecoration(
                    labelText: translate('car_model', widget.currentLang),// "Car Model",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.directions_car),
                  ),
                  onChanged: (val) => carModel = val,
                ),
                const SizedBox(height: 15),

                // --- Service Type Dropdown ---
                // --- کل این بخش جایگزین کدهای قبلی دراپ‌داون شود ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: 
                       DropdownButton<String>(
  // شرط ایمنی: اگر مقدار فعلی در لیست کلیدها نبود، اولین کلید را انتخاب کن
  value: serviceKeys.contains(selectedServiceType) ? selectedServiceType : serviceKeys.first,
  
  items: serviceKeys.map((String key) {
    return DropdownMenuItem<String>(
      value: key, // مقدار ثابت که هرگز با تغییر زبان عوض نمی‌شود
      child: Text(translate(key, widget.currentLang)), // متنی که به کاربر نمایش داده می‌شود (ترجمه شده)
    );
  }).toList(),
  
  onChanged: (String? newValue) {
    setState(() {
      selectedServiceType = newValue!;
    });
  },
),
                     
                    ),
                    const SizedBox(width: 8),
                    // دکمه سبز برای اضافه کردن فیلد جدید
                    IconButton(
                      padding: const EdgeInsets.only(top: 8),
                      icon: const Icon(
                        Icons.add_circle,
                        color: Colors.green,
                        size: 36,
                      ),
                      onPressed: () =>
                          _showAddCategoryDialog(), // دیالوگی که قبلاً نوشتیم
                    ),
                  ],
                ),
                // --- پایان بخش اصلاح شده ---
                const SizedBox(height: 15),

                //--- Mileage Field ---
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: 
                  //const 
                  InputDecoration(
                    //labelText: "Current Mileage (Km)",
                    labelText: translate('current_mileage', widget.currentLang),
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.speed),
                  ),
                  onChanged: (val) => currentKm = val,
                ),
                const SizedBox(height: 20),

                // --- Date Picker & Submit ---
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.save),
                  label: Text(translate('log_service_date', widget.currentLang)),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      // حالا تمام اطلاعات را می‌فرستیم: مدل، تاریخ، نوع سرویس و کیلومتر
                      saveServiceInfo(
                        carModel,
                        picked.toIso8601String(),
                        selectedServiceType,
                        currentKm,
                      );
                      _sendEmailReminder();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Service logged successfully!"),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),

       
          // بعد:
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              translate('recent_history', widget.currentLang),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),

        _buildPreviousLogs(),
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

  // void _editServiceEntry(dynamic key, Map data) {
  //   setState(() {
  //     carModel = data['model'];
  //     selectedServiceType = data['type'];
  //     currentKm = data['km'];

      
  //     Hive.box('carServiceBox').delete(key);
  //     await _notificationsPlugin.cancel(101);

  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           "Editing ${data['type']}. Old record removed. Update fields and save.",
  //         ),
  //       ),
  //     );
  //   });
  // }

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
        title: Text(
          _selectedIndex == 0 
              ? translate('fuel_live', widget.currentLang) 
              : translate('car_service_parking', widget.currentLang),
        ),
        centerTitle: true,
        actions: [         
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
        mainAxisSize: MainAxisSize.min, // 👈 بسیار مهم: مانع از پر شدن کل صفحه توسط کالم می‌شود
        children: [
          // ۱. نمایش هوشمند بنر تبلیغاتی ادموب (از ماه ۴ به بعد خودکار ظاهر می‌شود)
if (AppLicenseManager.shouldShowAds())      
      if (_isAdLoaded && _bannerAd != null) ...[
  TextButton(
    onPressed: _showPremiumPaywall, // پاپ‌آپ خرید را باز می‌کند
    child: const Text("No Ads? Go Premium", style: TextStyle(fontSize: 12, color: Colors.blue)),
  ),
  Container(
    width: _bannerAd!.size.width.toDouble(),
    height: _bannerAd!.size.height.toDouble(),
    margin: const EdgeInsets.symmetric(vertical: 2),
    child: AdWidget(ad: _bannerAd!),
  ),
]
            else
              // این کادر کوچک تا زمان لود شدن تبلیغ از اینترنت نشان داده می‌شود
              Container(
                width: double.infinity,
                height: 50,
                color: Colors.grey.shade50,
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 20, 
                  height: 20, 
                  child: CircularProgressIndicator(strokeWidth: 2)
                ),
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
              
              // در غیر این صورت (ماه ۱ تا ۶ یا کاربر پرمیوم) تب به راحتی تغییر می‌کند
              setState(() => _selectedIndex = index);
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
                      widget.currentLang == 'fa' ? 'در حال برقراری ارتباط با گوگل‌پلی...' : 'Connecting to Google Play...',
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
                      setState(() {
                        selectedFuel = newValue;
                        stations = []; // پاک کردن لیست قبلی موقع تغییر سوخت
                      });

                      // ذخیره انتخاب جدید در حافظه تا برای دفعه بعد بماند
                      Hive.box('settingsBox').put('lastSelectedFuel', newValue);

                      // فراخوانی تابع‌ها بر اساس انتخاب جدید
                      if (selectedFuel == 'ev') {
                        fetchEVStations();
                      } else if (selectedFuel == 'parking') {
                        fetchParkingData();
                      } else {
                        // fetchPrices(); // اگر تابعی برای بنزین/دیزل داری اینجا صدا بزن
                      }
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
            _buildProfessionalMap()
          else
            //_buildPriceAlertSetter(),
            ...[
            // وقتی در حالت لیست هستیم، تنظیم آلارم را اینجا به صورت کشویی نشان می‌دهیم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ExpansionTile(
                title: const Text(
                  "Set Price Drop Alert",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                leading: const Icon(Icons.notifications_active, color: Colors.blue),
                backgroundColor: Colors.blue.withOpacity(0.05),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                children: [
                  _buildPriceAlertSetter(), // همان تابع تنظیم آلارم تو
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],

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
                          onTap: () =>
                              _openMap(s['lat'], s['lng']), //_showDetails(s),
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
