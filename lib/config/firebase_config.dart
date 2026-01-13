import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static FirebaseApp? _app;

  static Future<void> initialize() async {
    try {
      // Check if Firebase is already initialized
      if (Firebase.apps.isNotEmpty) {
        _app = Firebase.app();
      } else {
        _app = await Firebase.initializeApp(
          // Default options should be configured via flutterfire configure
          // options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      
      // Request permission for push notifications
      final messaging = FirebaseMessaging.instance;
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (kDebugMode) {
        print('User granted permission: ${settings.authorizationStatus}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Firebase initialization error: $e');
      }
    }
  }

  static bool get isInitialized => _app != null;
}
