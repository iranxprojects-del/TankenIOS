import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class AppLicenseManager {
  // 💡 متغیر شبیه‌ساز برای تست راحت شما:
  // مقدار null یعنی از روزهای واقعی استفاده کن.
  // اگر عدد بذارید (مثلاً 0 یا 100 یا 200)، برنامه دقیقاً در همان روز شبیه‌سازی می‌شود.
  static const int? debugSimulatedDays = null;

  static int daysForFreeTrial = 0; //90   // تا ماه ۳ رایگان
  static int daysForAdsLimit = 10; //180  // تا ماه ۶ تبلیغات دارد

  /// دریافت تعداد روزهای گذشته از اولین اجرای برنامه
  static int getElapsedDays() {
    if (debugSimulatedDays != null) {
      return debugSimulatedDays!;
    }

    final box = Hive.box('settingsBox');
    final String? firstLaunchStr = box.get('firstLaunchDate');

    if (firstLaunchStr == null) {
      final now = DateTime.now();
      box.put('firstLaunchDate', now.toIso8601String());
      return 0;
    }

    final firstLaunchDate = DateTime.parse(firstLaunchStr);
    return DateTime.now().difference(firstLaunchDate).inDays;
  }

  /// فاز ۱: ماه ۱ تا ۳ (روز ۰ تا ۹۰) -> کاملاً رایگان و بدون تبلیغات
  /// فاز ۲: ماه ۴ به بعد (روز ۹۱ به بعد) -> نمایش تبلیغات بنری گوگل
  static bool shouldShowAds() {
    // اگر کاربر قبلاً پرمیوم شده باشد، تبلیغات نشان داده نشود
    if (isUserPremium()) return false;
    return getElapsedDays() >= daysForFreeTrial; // از روز ۱ (شروع ماه چهارم) تبلیغات فعال می‌شود
  }

  /// امکانات دیگر با تایم‌لاین تبلیغات محدود می‌شوند، نه با پاپ‌آپ دعوت/امتیاز.
  static bool isFeatureActive(String featureKey) {
    return true;
  }

  /// بررسی اینکه آیا کاربر اشتراک خریده است
  static bool isUserPremium() {
    final box = Hive.box('settingsBox');
    return box.get('isPremiumUser', defaultValue: false);
  }

  /// ثبت وضعیت پرمیوم برای کاربر
  static void setPremiumTrue() {
    Hive.box('settingsBox').put('isPremiumUser', true);
  }

  /// بررسی و مدیریت کلیک روی ویژگی‌ها
  static void runFeature({
    required BuildContext context,
    required String featureKey,
    required VoidCallback onFeatureAction,
  }) {
    onFeatureAction();
  }

  /// پاپ‌آپ دعوت به ۲ نفر / امتیاز گوگل‌پلی حذف شده است.
  static void showPremiumDialog(BuildContext context) {
    return;
  }
}
