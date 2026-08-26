import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';


// 🔴 این تابع باید بیرون از کلاس و در سطح فایل (Top-level) باشد تا در بک‌گراند کار کند
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == 'service_completed') {
    await Hive.initFlutter();
    var box = await Hive.openBox('carServiceBox');
    await box.clear(); // حذف تمام رکوردهای سرویس
    await FlutterLocalNotificationsPlugin().cancel(101); // حذف آلارم
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);
  static String? selectedServiceKey;
  
  int daysForFreeTrial = 0; //90   // تا ماه ۳ رایگان
  int daysForAdsLimit = 0;  //
  static const String fuelPriceChannelId = 'fuel_price_alerts';
  static const String fuelPriceChannelName = 'Fuel Price Alerts';
  static const String serviceChannelId = 'car_service_reminders';
  static const String serviceChannelName = 'Car Service Reminders';

  // 1. Initializing Notifications
  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    
    // 🔴 اضافه شدن هندلرهای کلیک روی نوتیفیکیشن
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.actionId == 'service_completed') {
          // اگر کاربر زد رفتم تعمیرگاه
          var box = await Hive.openBox('carServiceBox');
          await box.clear();
          await cancelNotification(101);
        }

        if (response.payload != null && response.payload!.isNotEmpty) {
          try {
            final payloadData = json.decode(response.payload!);
            if (payloadData is Map && payloadData['itemKey'] != null) {
              selectedServiceKey = payloadData['itemKey'];
            }
          } catch (_) {
            if (response.payload == 'open_services') {
              selectedServiceKey = null;
            }
          }
        }

        if (response.actionId == 'open_services' || response.payload == 'open_services' || selectedServiceKey != null) {
          tabNotifier.value = 1;
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    const AndroidNotificationChannel fuelPriceChannel = AndroidNotificationChannel(
      fuelPriceChannelId,
      fuelPriceChannelName,
      description: 'Notifications for cheap fuel prices',
      importance: Importance.max,
      playSound: true,
    );

    const AndroidNotificationChannel serviceChannel = AndroidNotificationChannel(
      serviceChannelId,
      serviceChannelName,
      description: 'Reminders for oil change and repairs',
      importance: Importance.high,
      playSound: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(fuelPriceChannel);
    await androidImplementation?.createNotificationChannel(serviceChannel);

    await _configureLocalTimeZone();
  
  }

  // متد عمومی برای لغو نوتیفیکیشن‌ها از بیرون کلاس
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    print("❌ Notification with ID $id has been canceled.");
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZoneName = DateTime.now().timeZoneName;

    try {
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      return;
    } catch (_) {}

    final match = RegExp(r'GMT([+-])(\d{1,2}):?(\d{2})?').firstMatch(timeZoneName);
    if (match != null) {
      final sign = match.group(1) == '+' ? '-' : '+'; // reversed for Etc/GMT naming
      final hours = int.parse(match.group(2)!);
      final offsetName = 'Etc/GMT$sign${hours.toString().padLeft(2, '0')}';
      try {
        tz.setLocalLocation(tz.getLocation(offsetName));
        return;
      } catch (_) {}
    }

    tz.setLocalLocation(tz.UTC);
  }

  static tz.TZDateTime _nextInstanceOfHour(int hour) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static int _notificationIdForKey(String key) => key.hashCode.abs() % 100000;

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> testAlarmOneMinuteLater() async {
    tz.initializeTimeZones();
    final tz.Location germany = tz.getLocation('Europe/Berlin');
    
    // گرفتن زمان دقیقِ همین الان
    final tz.TZDateTime now = tz.TZDateTime.now(germany);
    
    // تنظیم برای دقیقاً ۱ دقیقه دیگر
    final tz.TZDateTime scheduledDate = now.add(const Duration(minutes: 1));

    print("⏰ Alarm Test Set For: $scheduledDate");

    await _notificationsPlugin.zonedSchedule(
      999, // یک آیدی تستی
      'تست آلارم 🚀',
      'احمد! سیستم نوتیفیکیشن سالم است!',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          serviceChannelId,
          serviceChannelName,
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }



  static Future<void> scheduleDailyCarServiceAlert() async {

  await Hive.initFlutter();
    var box = await Hive.openBox('carServiceBox');
    
    // 🔴 شرط مهم: اگر باکس خالی است، اصلاً آلارم ست نشه و آلارم قبلی هم پاک بشه
    if (box.isEmpty) {
      await cancelNotification(101);
      return;
    }
  // ۱. مطمئن شدن از لود شدن دیتابیس تایم‌زون‌ها
  tz.initializeTimeZones();
  
  // ۲. تنظیم موقعیت جغرافیایی روی آلمان (CET / CEST)
  final tz.Location germany = tz.getLocation('Europe/Berlin');
  
  // ۳. گرفتن زمان فعلی در آلمان
  final tz.TZDateTime now = tz.TZDateTime.now(germany);
  
  // ۴. ساختن زمان هدف: امروز ساعت ۱۶:۰۰
  tz.TZDateTime scheduledDate = tz.TZDateTime(
    germany,
    now.year,
    now.month,
    now.day,
    8, // ساعت ۱۶
    30,  // دقیقه ۰۰
  );

  // اگر الان از ساعت ۱۶ گذشته، آلارم را برای فردا ساعت ۱۶ تنظیم کن
  if (scheduledDate.isBefore(now)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }

  // ۵. ارسال دستور زمان‌بندی دقیق به سیستم عامل
  await _notificationsPlugin.zonedSchedule(
    101, // یک آی‌دی منحصربه‌فرد برای این نوتیفیکیشن
    'Car Service Reminder 🚗',
    'Please check your car oil and service status.',
    scheduledDate,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        serviceChannelId, // کانال مربوط به سرویس ماشین
        serviceChannelName,
        importance: Importance.max,
        priority: Priority.high,

        // 🔴 اضافه کردن دکمه‌ها (Actions) به نوتیفیکیشن
          actions: [
            AndroidNotificationAction(
              'service_completed', // آیدی اکشن
              'Service Completed', // متن دکمه
              cancelNotification: true, // بسته شدن خودکار نوتیفیکیشن
            ),
            AndroidNotificationAction(
              'open_services', // آیدی اکشن
              'Open Services', // متن دکمه
              showsUserInterface: true, // اپلیکیشن رو بیار بالا
            ),
          ],
      ),
    ),
    payload: 'open_services', // برای وقتی که روی خود بدنه نوتیفیکیشن کلیک میشه
    // 🔑 نکته اصلی: این خط باعث میشه اندروید حتی در حالت خواب (Doze Mode) راس ساعت بیدار بشه
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, 
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    // 🔁 این خط باعث میشه نوتیفیکیشن هر روز راس همین ساعت تکرار بشه
    matchDateTimeComponents: DateTimeComponents.time, 
  );
}

// این تابع وظیفه داره همون لحظه که صدا زده میشه، قیمت رو بگیره و نشون بده
  static Future<void> fetchMorningDieselPriceAndNotify() async {
    try {
      await Hive.initFlutter();
      var settingsBox = await Hive.openBox('settingsBox');
      String fuelType = settingsBox.get('alertFuelType', defaultValue: 'diesel');

      // گرفتن لوکیشن کاربر
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      const String apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
      final url = "https://creativecommons.tankerkoenig.de/json/list.php?lat=${pos.latitude}&lng=${pos.longitude}&rad=10&sort=price&type=$fuelType&apikey=$apiKey";
      
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['stations'].isNotEmpty) {
          
          var cheapestStation = data['stations'][0];
          double currentPrice = cheapestStation['price'];
          String name = cheapestStation['name'];

          // نمایش آنی نوتیفیکیشن
          await _notificationsPlugin.show(
            102, // آیدی متفاوت برای آلارم صبحگاهی
            "گزارش صبحگاهی قیمت $fuelType ☕⛽",
            "ارزان‌ترین پمپ بنزین اطراف شما: $name با قیمت €$currentPrice",
            const NotificationDetails(
              android: AndroidNotificationDetails(
                fuelPriceChannelId,
                fuelPriceChannelName,
                importance: Importance.max,
                priority: Priority.high,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print("Morning fetch error: $e");
    }
  }

// این متد را برای گرفتن اجازه نوتیفیکیشن اضافه کن
  static Future<bool> requestPermission() async {
    // گرفتن دسترسی مخصوص اندروید ۱۳ به بالا
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      final bool? granted = await androidImplementation.requestNotificationsPermission();
      return granted ?? false;
    }
    return false;
  } 

  // 2. Alarm dekhāḍavā māṭe nū function
  static Future<void> showNotification(
    String title,
    String body, {
    String channelId = serviceChannelId,
    String channelName = serviceChannelName,
    String? payload,
  }) async {
    await _notificationsPlugin.show(
      0,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: payload,
    );
  }

  static Future<void> cancelMaintenanceNotification(String itemKey) async {
    await cancelNotification(_notificationIdForKey(itemKey));
  }

  static Future<void> scheduleMaintenanceReminder({
    required String itemKey,
    required String title,
    required String body,
    required DateTime firstRun,
    bool repeatDaily = false,
    String? payload,
  }) async {
  // ۱. مطمئن شدن از لود شدن دیتابیس تایم‌زون‌ها
  tz.initializeTimeZones();
  
  // ۲. تنظیم موقعیت جغرافیایی روی آلمان (Europe/Berlin)
  final tz.Location germany = tz.getLocation('Europe/Berlin');
  
  // ۳. گرفتن زمان فعلی بر اساس تایم‌زون آلمان
  final tz.TZDateTime now = tz.TZDateTime.now(germany);
  
  await _notificationsPlugin.cancel(_notificationIdForKey(itemKey));
  
  final int notificationId = _notificationIdForKey(itemKey);
  final tz.TZDateTime scheduledDate = tz.TZDateTime(
    germany,
    firstRun.year,
    firstRun.month,
    firstRun.day,
    firstRun.hour,
    firstRun.minute,
  );

  if (scheduledDate.isAfter(now)) {
    await _notificationsPlugin.zonedSchedule(
      notificationId,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          serviceChannelId,
          serviceChannelName,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: repeatDaily ? DateTimeComponents.time : null,
    );
  }
  }

  static DateTime _addMonths(DateTime original, int months) {
    final int year = original.year + ((original.month - 1 + months) ~/ 12);
    final int month = ((original.month - 1 + months) % 12) + 1;
    final int day = original.day.clamp(1, DateTime(year, month + 1, 0).day);
    return DateTime(
      year,
      month,
      day,
      original.hour,
      original.minute,
      original.second,
      original.millisecond,
      original.microsecond,
    );
  }

  static Future<void> _checkQuarterlyPerformanceReminder() async {
    try {
      await Hive.initFlutter();
      final settingsBox = await Hive.openBox('settingsBox');
      final now = DateTime.now();
      DateTime nextReminder;
      final stored = settingsBox.get('nextPerformanceReminder');

      if (stored is String && stored.isNotEmpty) {
        nextReminder = DateTime.tryParse(stored) ?? now;
      } else {
        nextReminder = _addMonths(now, 3);
        await settingsBox.put('nextPerformanceReminder', nextReminder.toIso8601String());
      }

      if (!now.isBefore(nextReminder)) {
        await showNotification(
          'Car Performance Update',
          'It has been 3 months. Please update your car performance and review service data.',
          channelId: serviceChannelId,
          channelName: serviceChannelName,
          payload: 'open_services',
        );
        final updatedReminder = _addMonths(nextReminder, 3);
        await settingsBox.put('nextPerformanceReminder', updatedReminder.toIso8601String());
      }
    } catch (e) {
      print('Quarterly performance reminder error: $e');
    }
  }

  static Future<void> processDailyServiceReminders() async {
    try {
      await Hive.initFlutter();
      var box = await Hive.openBox('carServiceBox');
      final savedData = box.get('maintenanceData', defaultValue: <String, dynamic>{});
      if (savedData is! Map) return;

      final int currentKm = int.tryParse(savedData['currentKm']?.toString() ?? '') ?? -1;
      final List<dynamic> items = savedData['items'] as List<dynamic>? ?? [];
      final now = DateTime.now();

      for (var raw in items) {
        if (raw is! Map) continue;
        final itemKey = raw['key']?.toString() ?? '';
        if (itemKey.isEmpty) continue;
        final itemTitle = raw['title']?.toString() ?? 'Service';
        final bool alarmEnabled = raw['alarmEnabled'] ?? false;
        if (!alarmEnabled) continue;

        final String serviceDate = raw['serviceDate']?.toString() ?? '';
        final int dueKm = int.tryParse(raw['mileage']?.toString() ?? '') ?? -1;
        bool shouldNotify = false;
        String body = '';

        if (serviceDate.isNotEmpty) {
          try {
            final dueDate = DateTime.parse(serviceDate);
            final daysUntil = dueDate.difference(now).inDays;
            if (daysUntil <= 30) {
              shouldNotify = true;
              body = daysUntil >= 0
                  ? '$itemTitle expires in $daysUntil days.'
                  : '$itemTitle is overdue.';
            }
          } catch (_) {}
        }

        if (!shouldNotify && dueKm > 0 && currentKm > 0) {
          final remainingKm = dueKm - currentKm;
          if (remainingKm <= 1000) {
            shouldNotify = true;
            body = remainingKm >= 0
                ? '$itemTitle is due in $remainingKm km.'
                : '$itemTitle should be checked now.';
          }
        }

        if (shouldNotify) {
          await showNotification(
            'Car Service Reminder 🚗',
            body,
            channelId: serviceChannelId,
            channelName: serviceChannelName,
            payload: json.encode({'itemKey': itemKey}),
          );
        }
      }
      await _checkQuarterlyPerformanceReminder();
    } catch (e) {
      print('Daily service reminder error: $e');
    }
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // --- LOGIC 1: FUEL CHECK (Dar kalake, pan fakt divase) ---
    if (task == "periodicFuelCheck") {
      //if (now.hour >= 7 && now.hour <= 22) {
        await checkFuelPricesAndNotify();
      //}
    }

    // --- LOGIC 2: SERVICE CHECK (Dar 24 kalake) ---
    if (task == "dailyServiceCheck") {
      await NotificationService.processDailyServiceReminders();
    }

    return Future.value(true);
  });
}
Future<void> checkFuelPricesAndNotify() async {
  try {
    await Hive.initFlutter();
    var settingsBox = await Hive.openBox('settingsBox');
    
    // خواندن قیمت هدف و نوع سوخت از تنظیمات کاربر
    double userThreshold = settingsBox.get('targetPrice', defaultValue: 0.0);
    String fuelType = settingsBox.get('alertFuelType', defaultValue: 'diesel');

    if (userThreshold == 0.0) return; // اگر تنظیمی انجام نشده بود

    Position pos = await Geolocator.getCurrentPosition();
    const String apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
    
    final url = "https://creativecommons.tankerkoenig.de/json/list.php?lat=${pos.latitude}&lng=${pos.longitude}&rad=10&sort=price&type=$fuelType&apikey=$apiKey";
    
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['ok'] == true && data['stations'].isNotEmpty) {
        var cheapestStation = data['stations'][0];
        double currentPrice = cheapestStation['price'];
        String name = cheapestStation['name'];

        if (currentPrice <= userThreshold) {
          await NotificationService.showNotification(
            "Fuel Price Alert! ⛽",
            "Price at $name is now €$currentPrice (Below your €$userThreshold target)",
            channelId: NotificationService.fuelPriceChannelId,
            channelName: NotificationService.fuelPriceChannelName,
          );
        }
      }
    }
  } catch (e) {
    print("Background Task Error: $e");
  }
}
