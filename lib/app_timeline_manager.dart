import 'package:hive_flutter/hive_flutter.dart';

class AppTimelineManager {
  static final AppTimelineManager _instance = AppTimelineManager._internal();
  factory AppTimelineManager() => _instance;
  AppTimelineManager._internal();

  late DateTime _installDate;
  DateTime? _postPremiumFallbackDate;

  Future<void> initializeAndSync() async {
    var box = Hive.box('settingsBox');
    
    // ۱. خواندن تاریخ نصب اولیه
    String? installStr = box.get('installDate');
    if (installStr == null) {
      _installDate = DateTime.now();
      await box.put('installDate', _installDate.toIso8601String());
    } else {
      _installDate = DateTime.parse(installStr);
    }

    // ۲. خواندن تاریخ ابطال پرمیوم (اگر قبلاً پرمیوم بوده و منقضی شده)
    String? fallbackStr = box.get('postPremiumFallbackDate');
    if (fallbackStr != null) {
      _postPremiumFallbackDate = DateTime.parse(fallbackStr);
    }
  }

  // متدی که توسط PurchaseManager زمان انقضای لایسنس صدا زده می‌شود
 Future<void> setPostPremiumFallbackDate(DateTime expirationDate) async {
  var box = Hive.box('settingsBox');
  _postPremiumFallbackDate = expirationDate; // خط اصلاح شده
  await box.put('postPremiumFallbackDate', expirationDate.toIso8601String());
}

  int get currentTier {
    DateTime now = DateTime.now();
    DateTime referenceDate = _postPremiumFallbackDate ?? _installDate;
    
    int daysPassed = now.difference(referenceDate).inDays;

    // اگر کاربر سابقه انقضای پرمیوم دارد، او را مستقیماً به روز ۳۰ اُم (شروع فاز ۲) پرتاب می‌کنیم
    if (_postPremiumFallbackDate != null) {
       daysPassed += 30; 
    }

    // منطق فازبندی
    if (daysPassed < 30) {
      return 1; // فاز ۰ و ۱: رایگان و بدون محدودیت
    } else if (daysPassed >= 30 && daysPassed < 60) {
      return 3; // فاز ۲ (Tier 3): محدود شده با تبلیغ ویدیویی اجباری
    } else {
      return 4; // فاز ۳ (Tier 4): قفل کامل امکانات اصلی (نیازمند خرید مجدد)
    }
  }

  bool get isFreeTierExpired {
    return currentTier >= 3;
  }

  int get remainingFreeDays {
    DateTime now = DateTime.now();
    DateTime referenceDate = _postPremiumFallbackDate ?? _installDate;
    
    int daysPassed = now.difference(referenceDate).inDays;
    
    if (_postPremiumFallbackDate != null) {
      daysPassed += 30; // شیفت به فاز ۲
    }

    if (daysPassed < 30) {
      return 30 - daysPassed; // روزهای مانده از فاز ۱
    } else if (daysPassed >= 30 && daysPassed < 60) {
      return 60 - daysPassed; // روزهای مانده از فاز ۲ (فرصت قبل از قفل کامل)
    } else {
      return 0; // قفل کامل شده است
    }
  }
}