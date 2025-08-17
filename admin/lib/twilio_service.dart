import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TwilioService {
  // يجب أن يتم تخزين هذه المتغيرات في ملف .env
  final String? accountSid = dotenv.env['TWILIO_ACCOUNT_SID'];
  final String? authToken = dotenv.env['TWILIO_AUTH_TOKEN'];
  final String? fromPhone = dotenv.env['TWILIO_PHONE_NUMBER'];

  Future<void> sendSmsMessage(String toPhone, String customerName, String productName, double totalPrice) async {
    if (accountSid == null || authToken == null || fromPhone == null) {
      throw Exception('Twilio credentials not found in environment variables.');
    }

    final String message = 'تم إتمام الدفع بنجاح من العميل $customerName. المنتج: $productName. المبلغ الكلي هو: $totalPrice د.أ';

    final url = Uri.parse('https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Basic ' + base64Encode(utf8.encode('$accountSid:$authToken')),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'From': fromPhone!,
          'To': toPhone,
          'Body': message,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Message sent: ${response.body}');
      } else {
        throw Exception('Failed to send SMS. Status code: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      print('Error sending SMS: $e');
      throw e;
    }
  }
}