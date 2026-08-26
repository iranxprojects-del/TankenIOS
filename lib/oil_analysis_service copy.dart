import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class OilAnalysisService {
  // Use US Oil (CL=F) or Brent (BZ=F) - Finnhub sometimes prefers 'USO' for free tier
  static const String apiKey = "d7urd69r01qnv95okas0d7urd69r01qnv95okasg"; 

  static Future<void> updateOilAnalysis() async {
  final url = "https://query1.finance.yahoo.com/v8/finance/chart/BZ=F?interval=1d&range=1d";
  
  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // استخراج قیمت از مسیر پیچیده یاهو
      final result = data['chart']['result'][0];
      final meta = result['meta'];
      double currentPrice = double.parse(meta['regularMarketPrice'].toString());
      double previousClose = double.parse(meta['chartPreviousClose'].toString());
      
      if (currentPrice > 0) {
        var box = await Hive.openBox('oilBox');
        
        // ذخیره قیمت فعلی و قیمت قبلی (برای تشخیص صعودی/نزولی)
        box.put('todayPrice', currentPrice);
        box.put('yesterdayPrice', previousClose);
        
        print("✅ Success! Brent Price: \$ $currentPrice");
      }
    }
  } catch (e) {
    print("❌ Yahoo API Error: $e");
  }
}

  // static Future<void> updateOilAnalysis() async {
   
  //   //final url = "https://finnhub.io/api/v1/quote?symbol=XBRUSD&token=$apiKey";
  //   //final url = "https://finnhub.io/api/v1/quote?symbol=USO&token=$apiKey";

  //   final url = "https://query1.finance.yahoo.com/v8/finance/chart/BZ=F?interval=1d&range=1d";
    
  //   try {
  //     final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       double currentPrice = double.parse(data['c'].toString());
        
  //       if (currentPrice > 0) {
  //         var box = await Hive.openBox('oilBox');
  //         double? lastPrice = box.get('todayPrice');
  //         if (lastPrice != null && lastPrice != currentPrice) {
  //           box.put('yesterdayPrice', lastPrice);
  //         }
  //         box.put('todayPrice', currentPrice);
  //         print("✅ Oil Price Updated: \$ $currentPrice");
  //       }
  //     }
  //   } catch (e) {
  //     print("❌ Oil API Error: $e");
  //   }
  // }
static Map<String, dynamic> getSimpleAnalysis() {
    // ۱. بررسی باز بودن باکس برای جلوگیری از کرش
    if (!Hive.isBoxOpen('oilBox')) {
      return {
        "message": "Connecting to market...", 
        "color": "Blue"
      };
    }

    var box = Hive.box('oilBox');
    
    // ۲. گرفتن دیتا با مقدار پیش‌فرض صفر
    double today = box.get('todayPrice', defaultValue: 0.0);
    double yesterday = box.get('yesterdayPrice', defaultValue: 0.0);

    // ۳. اگر هنوز دیتایی در باکس ذخیره نشده
    if (today == 0) {
      return {
        "message": "Updating Brent Crude prices...", 
        "color": "Blue"
      };
    }

    // ۴. محاسبه روند قیمت
    String trend = "";
    if (yesterday > 0) {
      double diff = today - yesterday;
      trend = diff >= 0 ? " (↑ rising)" : " (↓ falling)";
    }

    return {
      "message": "Brent Crude: \$$today$trend",
      "color": "Blue"
    };
  }
}