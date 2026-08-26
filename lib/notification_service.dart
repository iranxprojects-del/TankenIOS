import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:workmanager/workmanager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

const String _serviceReminderCategoryId = 'service_reminder';

// 🔴 این تابع باید بیرون از کلاس و در سطح فایل (Top-level) باشد تا در بک‌گراند کار کند
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.actionId == 'delete_alarm' && response.payload != null) {
    final id = NotificationService.idForKey(response.payload!);
    await FlutterLocalNotificationsPlugin().cancel(id);

    await Hive.initFlutter();
    var box = await Hive.openBox('carServiceBox');
    final savedData = box.get('maintenanceData');
    if (savedData is Map) {
      final items = savedData['items'] as List<dynamic>? ?? [];
      for (var item in items) {
        if (response.payload == 'master' || item['key'] == response.payload) {
          item['alarmEnabled'] = false;
        }
      }
      savedData['items'] = items;
      await box.put('maintenanceData', savedData);
    }
  } else if (response.actionId == 'snooze_1_day') {
    await NotificationService._snoozePayload(response.payload);
  } else if (response.actionId == 'service_completed') {
    await Hive.initFlutter();
    var box = await Hive.openBox('carServiceBox');
    await box.clear();
    await FlutterLocalNotificationsPlugin().cancel(101);
  }
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);
  static String? selectedServiceKey;

  int daysForFreeTrial = 0;
  int daysForAdsLimit = 0;
  static const String fuelPriceChannelId = 'fuel_price_alerts';
  static const String fuelPriceChannelName = 'Fuel Price Alerts';
  static const String serviceChannelId = 'car_service_reminders';
  static const String serviceChannelName = 'Car Service Reminders';

  /// App is Germany-focused. IANA id is required — CET/CEST from
  /// DateTime.timeZoneName are NOT valid timezone database keys.
  static const String _fallbackTimeZone = 'Europe/Berlin';

  static int idForKey(String key) =>
      key == 'master' ? 99999 : _notificationIdForKey(key);

  static int _notificationIdForKey(String key) => key.hashCode.abs() % 100000;

  static DarwinNotificationDetails get _iOSDetails =>
      const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        categoryIdentifier: _serviceReminderCategoryId,
        interruptionLevel: InterruptionLevel.timeSensitive,
      );

  static AndroidNotificationDetails _androidDetails({
    required String channelId,
    required String channelName,
    List<AndroidNotificationAction>? actions,
  }) {
    return AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/launcher_icon',
      actions: actions,
    );
  }

  static NotificationDetails _details({
    String channelId = serviceChannelId,
    String channelName = serviceChannelName,
    List<AndroidNotificationAction>? actions,
  }) {
    return NotificationDetails(
      android: _androidDetails(
        channelId: channelId,
        channelName: channelName,
        actions: actions,
      ),
      iOS: _iOSDetails,
    );
  }

  static Future<void> _handleNotificationTap(NotificationResponse response) async {
    if (response.actionId == 'delete_alarm') {
      final id = response.payload == null
          ? 99999
          : idForKey(response.payload!);
      await cancelNotification(id);
      return;
    }
    if (response.actionId == 'snooze_1_day') {
      await _snoozePayload(response.payload);
      return;
    }

    if (response.actionId == 'service_completed') {
      var box = await Hive.openBox('carServiceBox');
      await box.clear();
      await cancelNotification(101);
    }
    if (response.payload != null &&
        response.payload!.isNotEmpty &&
        response.payload != 'master') {
      selectedServiceKey = response.payload;
    }
    if (response.actionId == 'open_services' || response.payload != null) {
      tabNotifier.value = 1;
    }
  }

  static Future<void> _snoozePayload(String? payload) async {
    final key = (payload == null || payload.isEmpty) ? 'master' : payload;
    final id = idForKey(key);
    await cancelNotification(id);

    tz.initializeTimeZones();
    await _configureLocalTimeZone();
    final next = _ensureFuture(
      tz.TZDateTime.now(tz.local).add(const Duration(days: 1)),
    );
    await _zonedSchedule(
      id: id,
      title: 'Car Service Reminder 🔧',
      body: 'Snoozed reminder — please check your car service page.',
      scheduledDate: next,
      details: _details(
        actions: const [
          AndroidNotificationAction(
            'open_services',
            'Open',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'delete_alarm',
            'Delete',
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze_1_day',
            'Snooze',
            cancelNotification: true,
          ),
        ],
      ),
      payload: key,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      notificationCategories: [
        DarwinNotificationCategory(
          _serviceReminderCategoryId,
          actions: [
            DarwinNotificationAction.plain('open_services', 'Open'),
            DarwinNotificationAction.plain(
              'delete_alarm',
              'Delete',
              options: {
                DarwinNotificationActionOption.destructive,
              },
            ),
            DarwinNotificationAction.plain('snooze_1_day', 'Snooze 1 day'),
          ],
        ),
      ],
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        await _handleNotificationTap(response);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    final NotificationAppLaunchDetails? launchDetails =
        await _notificationsPlugin.getNotificationAppLaunchDetails();
    if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
      final NotificationResponse? response = launchDetails.notificationResponse;
      if (response != null) {
        await _handleNotificationTap(response);
      }
    }

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
      importance: Importance.max,
      playSound: true,
    );

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(fuelPriceChannel);
    await androidImplementation?.createNotificationChannel(serviceChannel);

    await _configureLocalTimeZone();
    await requestPermission();
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
    debugPrint('Notification with ID $id has been canceled.');
  }

  static Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_fallbackTimeZone));
  }

  static tz.TZDateTime _toTz(DateTime dateTime) {
    return tz.TZDateTime(
      tz.local,
      dateTime.year,
      dateTime.month,
      dateTime.day,
      dateTime.hour,
      dateTime.minute,
      dateTime.second,
    );
  }

  /// Never schedule "now or past" — that silently drops the alarm, then the
  /// next app-open schedules tomorrow, producing every-other-day behavior.
  static tz.TZDateTime _ensureFuture(tz.TZDateTime scheduled) {
    final now = tz.TZDateTime.now(tz.local);
    var result = scheduled;
    while (!result.isAfter(now)) {
      result = result.add(const Duration(days: 1));
    }
    return result;
  }

  static Future<void> _zonedSchedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    required NotificationDetails details,
    String? payload,
    DateTimeComponents? matchDateTimeComponents,
  }) async {
    Future<void> schedule(AndroidScheduleMode mode) {
      return _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        payload: payload,
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: matchDateTimeComponents,
      );
    }

    try {
      await schedule(AndroidScheduleMode.alarmClock);
    } catch (e) {
      debugPrint('alarmClock schedule failed, falling back to exact: $e');
      await schedule(AndroidScheduleMode.exactAllowWhileIdle);
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    return _ensureFuture(scheduled);
  }

  static Future<void> testAlarmOneMinuteLater() async {
    await _configureLocalTimeZone();
    final tz.TZDateTime scheduledDate =
        tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1));

    debugPrint('Alarm Test Set For: $scheduledDate');

    await _zonedSchedule(
      id: 999,
      title: 'Alarm test',
      body: 'Notification system is working.',
      scheduledDate: scheduledDate,
      details: _details(),
    );
  }

  static Future<void> scheduleDailyCarServiceAlert() async {
    await Hive.initFlutter();
    var box = await Hive.openBox('carServiceBox');

    if (box.isEmpty) {
      await cancelNotification(101);
      return;
    }

    await _configureLocalTimeZone();
    final scheduledDate = _nextInstanceOfTime(8, 30);

    await _zonedSchedule(
      id: 101,
      title: 'Car Service Reminder 🚗',
      body: 'Please check your car oil and service status.',
      scheduledDate: scheduledDate,
      details: _details(
        actions: const [
          AndroidNotificationAction(
            'service_completed',
            'Service Completed',
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'open_services',
            'Open Services',
            showsUserInterface: true,
          ),
        ],
      ),
      payload: 'open_services',
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static Future<void> fetchMorningDieselPriceAndNotify() async {
    try {
      await Hive.initFlutter();
      var settingsBox = await Hive.openBox('settingsBox');
      String fuelType = settingsBox.get('alertFuelType', defaultValue: 'diesel');

      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      const String apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";
      final url =
          "https://creativecommons.tankerkoenig.de/json/list.php?lat=${pos.latitude}&lng=${pos.longitude}&rad=10&sort=price&type=$fuelType&apikey=$apiKey";

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['stations'].isNotEmpty) {
          var cheapestStation = data['stations'][0];
          double currentPrice = cheapestStation['price'];
          String name = cheapestStation['name'];

          await _notificationsPlugin.show(
            102,
            "Morning $fuelType price ☕⛽",
            "Cheapest nearby: $name at €$currentPrice",
            _details(
              channelId: fuelPriceChannelId,
              channelName: fuelPriceChannelName,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Morning fetch error: $e");
    }
  }

  static Future<bool> requestPermission() async {
    var granted = false;

    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      final bool notificationsGranted =
          await androidImplementation.requestNotificationsPermission() ?? true;
      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Exact alarm permission request failed: $e');
      }
      granted = notificationsGranted;
    }

    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      granted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }

    return granted;
  }

  static Future<void> showNotification(
    String title,
    String body, {
    String channelId = serviceChannelId,
    String channelName = serviceChannelName,
    String? payload,
  }) async {
    final int id = payload == null || payload.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.remainder(100000)
        : idForKey(payload);

    await _notificationsPlugin.show(
      id,
      title,
      body,
      _details(channelId: channelId, channelName: channelName),
      payload: payload,
    );
  }

  static Future<void> cancelMaintenanceNotification(String itemKey) async {
    await cancelNotification(idForKey(itemKey));
  }

  static Future<void> scheduleMaintenanceReminder({
    required String itemKey,
    required String title,
    required String body,
    required DateTime firstRun,
    bool repeatDaily = false,
    String? payload,
    required String btnOpenText,
    required String btnDeleteText,
    required String btnSnoozeText,
  }) async {
    await _configureLocalTimeZone();

    final int notificationId = idForKey(itemKey);
    await _notificationsPlugin.cancel(notificationId);

    final tz.TZDateTime scheduledDate = _ensureFuture(_toTz(firstRun));

    await _zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      details: _details(
        actions: [
          AndroidNotificationAction(
            'open_services',
            btnOpenText,
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'delete_alarm',
            btnDeleteText,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze_1_day',
            btnSnoozeText,
            cancelNotification: true,
          ),
        ],
      ),
      payload: payload ?? itemKey,
      matchDateTimeComponents:
          repeatDaily ? DateTimeComponents.time : null,
    );
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
        await settingsBox.put(
          'nextPerformanceReminder',
          nextReminder.toIso8601String(),
        );
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
        await settingsBox.put(
          'nextPerformanceReminder',
          updatedReminder.toIso8601String(),
        );
      }
    } catch (e) {
      debugPrint('Quarterly performance reminder error: $e');
    }
  }

  static Future<void> processDailyServiceReminders() async {
    try {
      await Hive.initFlutter();
      var box = await Hive.openBox('carServiceBox');
      final savedData =
          box.get('maintenanceData', defaultValue: <String, dynamic>{});
      if (savedData is! Map) return;

      final int currentKm =
          int.tryParse(savedData['currentKm']?.toString() ?? '') ?? -1;
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
            payload: itemKey,
          );
        }
      }
      await _checkQuarterlyPerformanceReminder();
    } catch (e) {
      debugPrint('Daily service reminder error: $e');
    }
  }

  static Future<void> showScheduledNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    if (kIsWeb) return;

    await _configureLocalTimeZone();
    final tz.TZDateTime tzScheduledTime = _ensureFuture(_toTz(scheduledTime));

    await _zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      details: _details(),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "periodicFuelCheck") {
      await checkFuelPricesAndNotify();
    }

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

    double userThreshold = settingsBox.get('targetPrice', defaultValue: 0.0);
    String fuelType = settingsBox.get('alertFuelType', defaultValue: 'diesel');

    if (userThreshold == 0.0) return;

    Position pos = await Geolocator.getCurrentPosition();
    const String apiKey = "ece7e50d-72fe-4e51-a996-555e56ca910c";

    final url =
        "https://creativecommons.tankerkoenig.de/json/list.php?lat=${pos.latitude}&lng=${pos.longitude}&rad=10&sort=price&type=$fuelType&apikey=$apiKey";

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
    debugPrint("Background Task Error: $e");
  }
}
