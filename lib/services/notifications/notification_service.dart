import 'sms_service.dart';
import 'push_notification_service.dart';
import 'email_service.dart';

class NotificationService {
  final SmsService _smsService = SmsService();
  final PushNotificationService _pushService = PushNotificationService();
  final EmailService _emailService = EmailService();

  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  /// Initialize all notification services
  Future<void> initialize() async {
    await _pushService.initialize();
  }

  /// Notify user about order confirmation
  Future<void> sendOrderConfirmation({
    required String phoneNumber,
    required String email,
    required String orderId,
    required String amount,
    required String itemsSummary,
    String? fcmToken,
  }) async {
    // 1. Send SMS (MSG91)
    await _smsService.sendOrderConfirmationSms(
      phoneNumber: phoneNumber,
      orderId: orderId,
      amount: amount,
    );

    // 2. Send Email (Zoho)
    await _emailService.sendOrderConfirmationEmail(
      recipientEmail: email,
      orderId: orderId,
      amount: amount,
      itemsSummary: itemsSummary,
    );

    // 3. Send Push Notification (FCM)
    if (fcmToken != null) {
      await _pushService.sendNotification(
        title: 'Order Confirmed!',
        body: 'Your order #$orderId has been received.',
        toToken: fcmToken,
      );
    }
  }

  /// Refresh FCM token (call after login)
  Future<void> refreshToken() async {
    await _pushService.updateToken();
  }
}
