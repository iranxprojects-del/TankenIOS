import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

class AppLicenseManager {
  // 💡 متغیر شبیه‌ساز برای تست راحت شما:
  // مقدار null یعنی از روزهای واقعی استفاده کن.
  // اگر عدد بذارید (مثلاً 0 یا 100 یا 200)، برنامه دقیقاً در همان روز شبیه‌سازی می‌شود.
  static const int? debugSimulatedDays = null; 

  static int daysForFreeTrial = 0; //90   // تا ماه ۳ رایگان
  static int daysForAdsLimit = 10;  //180  // تا ماه ۶ تبلیغات دارد


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

  /// فاز ۳: ماه ۷ به بعد (روز ۱۸۱ به بعد) -> محدود شدن تدریجی امکانات
  static bool isFeatureActive(String featureKey) {
    if (isUserPremium()) return true;
    
    // از روز ۱۸۱ (شروع ماه هفتم) دسترسی‌ها غیرفعال می‌شوند
    if (getElapsedDays() >= daysForAdsLimit) {
      return false; 
    }
    return true;
  }

  /// بررسی اینکه آیا کاربر اشتراک خریده یا کارهای معرفی را انجام داده است
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
    if (isFeatureActive(featureKey)) {
      onFeatureAction();
    } else {
      // نمایش دیالوگ خرید اشتراک یا ریفرال
      showPremiumDialog(context);
    }
  }

  /// نمایش پاپ‌آپ جذاب خرید اشتراک / ریفرال / کامنت گوگل پلی
  static void showPremiumDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.star_purple500_rounded, color: Colors.amber, size: 28),
              SizedBox(width: 10),
              Text(
                'نسخه ویژه (Premium)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'مهلت استفاده رایگان شما از این قابلیت به پایان رسیده است. برای باز کردن مجدد تمامی امکانات، یکی از دو روش زیر را انتخاب کنید:',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 20),
              
              // گزینه اول: خرید اشتراک
              _buildOptionCard(
                icon: Icons.credit_card_rounded,
                color: Colors.blueAccent,
                title: 'خرید اشتراک ویژه',
                subtitle: 'دسترسی نامحدود و حذف کامل تبلیغات',
                onTap: () {
                  Navigator.pop(context);
                  // منطق درگاه یا پرداخت شما
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('انتقال به صفحه پرداخت...')),
                  );
                },
              ),
              const SizedBox(height: 12),
              
              // گزینه دوم: ریفرال و کامنت گوگل پلی
              _buildOptionCard(
                icon: Icons.card_giftcard_rounded,
                color: Colors.green,
                title: 'فعال‌سازی رایگان (محدود)',
                subtitle: 'ارسال دعوت‌نامه به ۲ نفر و ثبت نظر در گوگل پلی',
                onTap: () async {
                  Navigator.pop(context);
                  // باز کردن لینک گوگل پلی برای ثبت نظر
                  final Uri url = Uri.parse('https://play.google.com/store/apps/details?id=com.example.tenken_adak');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                  
                  // شبیه‌سازی فعال شدن لایسنس بعد از انجام کار
                  AppLicenseManager.setPremiumTrue();
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('با تشکر! حساب شما با موفقیت به نسخه ویژه ارتقا یافت.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('بعداً', style: TextStyle(color: Colors.grey)),
            ),
          ],
        );
      },
    );
  }

  static Widget _buildOptionCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.5), width: 1.5),
          borderRadius: BorderRadius.circular(12),
          color: color.withOpacity(0.05),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color,
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }
}