import 'package:supabase_flutter/supabase_flutter.dart';

class EmailService {
  final _supabase = Supabase.instance.client;

  /// Sends an email using the secure 'send-email' Edge Function
  Future<bool> sendEmail({
    required String recipientEmail,
    required String subject,
    required String body,
    bool isHtml = false,
  }) async {
    try {
      final response = await _supabase.functions.invoke(
        'send-email',
        body: {
          'recipient': recipientEmail,
          'subject': subject,
          'body': body,
          'isHtml': isHtml,
        },
      );

      return response.status == 200;
    } catch (e) {
      // debugPrint('Email Service Error: $e');
      return false;
    }
  }

  /// Specialized method for Order Confirmation Email
  Future<bool> sendOrderConfirmationEmail({
    required String recipientEmail,
    required String orderId,
    required String amount,
    required String itemsSummary,
  }) async {
    final subject = 'Order Confirmation - #$orderId';
    final body = '''
      <h1>Order Confirmed!</h1>
      <p>Thank you for ordering from Indu Restaurant.</p>
      <p><strong>Order ID:</strong> #$orderId</p>
      <p><strong>Total Amount:</strong> ₹$amount</p>
      <p><strong>Items:</strong></p>
      <p>$itemsSummary</p>
      <p>We'll notify you when your food is on the way!</p>
    ''';
    
    return sendEmail(
      recipientEmail: recipientEmail,
      subject: subject,
      body: body,
      isHtml: true,
    );
  }
}
