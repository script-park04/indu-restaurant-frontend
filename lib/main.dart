import 'package:flutter/material.dart';
import 'config/supabase_config.dart';
import 'config/router.dart';
import 'theme/app_theme.dart';
import 'widgets/liquid_background.dart';
import 'services/notifications/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); 
  // Initialize Supabase
  await SupabaseConfig.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Initialize Notification Service
  await NotificationService().initialize();

  runApp(const InduRestaurantApp());
} 

class InduRestaurantApp extends StatelessWidget {
  const InduRestaurantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Indu Multicuisine Restaurant',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        // Wrap all routes with a liquid glass background
        return LiquidBackground(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
