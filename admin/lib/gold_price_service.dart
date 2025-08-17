import 'dart:convert';
import 'package:http/http.dart' as http;

class GoldPriceService {
  static Future<Map<String, double>> fetchGoldPrices() async {
    final apiKey = '8e342d633f6443f000eec1872e5ceb98'; // مفتاح الـ API
    final url = "https://api.metalpriceapi.com/v1/latest?apiKey=$apiKey&base=USD&currencies=XAU"; // URL الصحيح

    double defaultPrice = 2750 ; // السعر الثابت الذي سيتم استخدامه في حالة الفشل

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body); // فك ترميز الاستجابة

        // استخراج أسعار الأعيرة المختلفة
        double ouncePrice = data['rates']['USDXAU']; // استخراج سعر الأونصة

        // حساب أسعار الأعيرة المختلفة بناءً على المعادلة
        double gramPrice24 = ((ouncePrice * 32.15 * 0.885 * 0.71) + 200) / 1000;
        double gramPrice22 = gramPrice24 * 0.916; // عيار 22
        double gramPrice21 = gramPrice24 * 0.875; // عيار 21
        double gramPrice18 = gramPrice24 * 0.790; // عيار 18

        return {
          'عيار 24': gramPrice24,
          'عيار 22': gramPrice22,
          'عيار 21': gramPrice21,
          'عيار 18': gramPrice18,
        };
      } else {
        // في حالة حدوث خطأ في الاتصال أو رد غير صحيح من الـ API
        throw Exception('فشل في جلب بيانات سعر الذهب');
      }
    } catch (e) {
      // في حالة حدوث أي خطأ (مثل انقطاع الإنترنت) سيتم استخدام السعر الثابت
      print("خطأ في جلب البيانات من الإنترنت: $e");

      // استخدام السعر الثابت 2750 إذا فشل الاتصال بالإنترنت
      double gramPrice24 = ((defaultPrice * 32.15 * 0.885 * 0.71) + 200) / 1000;
      double gramPrice22 = gramPrice24 * 0.916; // عيار 22
      double gramPrice21 = gramPrice24 * 0.875; // عيار 21
      double gramPrice18 = gramPrice24 * 0.790; // عيار 18

      return {
        'عيار 24': gramPrice24,
        'عيار 22': gramPrice22,
        'عيار 21': gramPrice21,
        'عيار 18': gramPrice18,
      };
    }
  }
}
