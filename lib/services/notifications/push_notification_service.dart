import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../../config/firebase_config.dart';

class PushNotificationService {
  FirebaseMessaging? _fcm;
  final AuthService _authService = AuthService();
  final _supabase = SupabaseConfig.client;

  FirebaseMessaging? get _messaging {
    if (!FirebaseConfig.isInitialized) {
      return null;
    }
    try {
      _fcm ??= FirebaseMessaging.instance;
      return _fcm;
    } catch (e) {
      if (kDebugMode) {
        print('Firebase Messaging not available: $e');
      }
      return null;
    }
  }

  Future<void> initialize() async {
    try {
      final messaging = _messaging;
      if (messaging == null) {
        if (kDebugMode) {
          print('Firebase not initialized, skipping push notifications');
        }
        return;
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('Got a message whilst in the foreground!');
          print('Message data: ${message.data}');
        }

        if (message.notification != null) {
          if (kDebugMode) {
            print('Message also contained a notification: ${message.notification}');
          }
          // TODO: Show a local notification if needed
        }
      });

      // Handle background/terminated messages when user clicks on notification
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        if (kDebugMode) {
          print('A new onMessageOpenedApp event was published!');
        }
        // TODO: Handle navigation based on message data
      });

      // Save/Update token for the current user
      await updateToken();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing push notifications: $e');
      }
    }
  }

  /// Get the current FCM token and save it to Supabase profile
  Future<void> updateToken() async {
    try {
      final messaging = _messaging;
      if (messaging == null) return;

      final token = await messaging.getToken();
      if (token != null) {
        final userId = _authService.currentUser?.id;
        if (userId != null) {
          await _supabase
              .from('profiles')
              .update({'fcm_token': token})
              .eq('id', userId);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating FCM token: $e');
      }
    }
  }

  /// Send a push notification (usually triggered from backend, but kept here for completeness)
  /// Note: Real push notifications should be sent from a server-side environment
  Future<void> sendNotification({
    required String title,
    required String body,
    required String toToken,
  }) async {
    // This is just a conceptual implementation. 
    // Sending FCM messages directly from the app is generally discouraged for security reasons.
    if (kDebugMode) {
      print('Push Notification triggered: $title - $body to $toToken');
    }
  }
}
