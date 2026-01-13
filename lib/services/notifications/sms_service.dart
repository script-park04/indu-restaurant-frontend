import 'package:supabase_flutter/supabase_flutter.dart';

class SmsService {
  final _supabase = Supabase.instance.client;

  /// Sends an OTP or message using the secure 'send-sms' Edge Function
  Future<bool> sendSms({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-sms',
        body: {
          'phoneNumber': phoneNumber,
          'message': message,
        },
      );

      if (response.status == 200) {
        final data = response.data;
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      // debugPrint('SmsService Error: $e');
      return false;
    }
  }

  /// Specialized method for Order Confirmation
  Future<bool> sendOrderConfirmationSms({
    required String phoneNumber,
    required String orderId,
    required String amount,
  }) async {
    final message = 'Your order #$orderId for ₹$amount has been received! - Indu Restaurant';
    return sendSms(phoneNumber: phoneNumber, message: message);
  }
}
