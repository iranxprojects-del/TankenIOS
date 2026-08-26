import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive/hive.dart';

class OilAnalysisService {
  // Use US Oil (CL=F) or Brent (BZ=F) - Finnhub sometimes prefers 'USO' for free tier
  static const String apiKey = "d7urd69r01qnv95okas0d7urd69r01qnv95okasg"; 

static Future<void> updateOilAnalysis() async {
  // Range ro gozashtam 5d ke motmaen bashim dadeye chand rooz e ghabl hast
  final url = "https://query1.finance.yahoo.com/v8/finance/chart/BZ=F?interval=1d&range=5d";
  
  try {
    final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final result = data['chart']['result'][0];
      final List<dynamic> timestamps = result['timestamp'];
      final List<dynamic> closePrices = result['indicators']['quote'][0]['close'];

      if (closePrices.isNotEmpty) {
        var box = await Hive.openBox('oilBox');
        
        // Akharin gheymat (Emruz)
        double today = double.parse(closePrices.last.toString());
        // Yeki moonde be akhar (Diruz)
        double yesterday = closePrices.length > 1 ? double.parse(closePrices[closePrices.length - 2].toString()) : 0.0;
        // Do ta moonde be akhar (Pariruz)
        double dayBefore = closePrices.length > 2 ? double.parse(closePrices[closePrices.length - 3].toString()) : 0.0;

        box.put('todayPrice', today);
        box.put('yesterdayPrice', yesterday);
        box.put('dayBeforePrice', dayBefore);
        
        print("✅ Oil Updated: Today: $today, Yest: $yesterday, DayBefore: $dayBefore");
      }
    }
  } catch (e) {
    print("❌ Error fetching oil history: $e");
  }
}

static Map<String, dynamic> getSimpleAnalysis() {
  if (!Hive.isBoxOpen('oilBox')) return {"message": "Loading...", "color": "Blue"};
  
  var box = Hive.box('oilBox');
  double today = box.get('todayPrice', defaultValue: 0.0);
  double yesterday = box.get('yesterdayPrice', defaultValue: 0.0);
  double dayBefore = box.get('dayBeforePrice', defaultValue: 0.0);

  if (today == 0) return {"message": "Syncing Market...", "color": "Blue"};

  // Inja text ro juri misazim ke gheimat haye ghabli koochik neshun dade beshan
  // Be dalil mahdoodiat Text widget, ma faghat string midim, 
  // vali tu UI mitonim bahash bazi konim.
  return {
    "today": today.toStringAsFixed(2),
    "yesterday": yesterday.toStringAsFixed(2),
    "dayBefore": dayBefore.toStringAsFixed(2),
    "message": "Brent: \$$today",
    "color": "Blue"
  };
}
}