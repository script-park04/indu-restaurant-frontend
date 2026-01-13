import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/signin_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/auth/phone_verification_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/location/location_selection_screen.dart';
import '../screens/location/add_edit_address_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../services/auth_service.dart';
import '../models/address.dart';
import '../config/supabase_config.dart';
import '../screens/item/food_detail_screen.dart';
import '../screens/admin/admin_home_screen.dart';

class AppRouter {
  static final _authService = AuthService();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final isLoggedIn = _authService.currentUser != null;
      final isOnSplash = state.matchedLocation == '/';
      final isOnAuthPage = state.matchedLocation == '/signin' || 
                          state.matchedLocation == '/signup';
      
      // Let splash screen complete its logic
      if (isOnSplash) {
        return null;
      }
      
      // If not logged in and not on auth page, redirect to signin
      if (!isLoggedIn && !isOnAuthPage) {
        return '/signin';
      }
      
      // If logged in and on auth page, redirect to home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/signin',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/phone-verification',
        builder: (context, state) => const PhoneVerificationScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/menu',
        builder: (context, state) {
          final categoryId = state.uri.queryParameters['category'];
          return MenuScreen(categoryId: categoryId);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          // TODO: Create ItemDetailScreen
          return Scaffold(
            appBar: AppBar(title: const Text('Item Details')),
            body: Center(child: Text('Item ID: $id')),
          );
        },
      ),
      GoRoute(
        path: '/location-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final isSelectionMode = extra?['isSelectionMode'] ?? false;
          return LocationSelectionScreen(isSelectionMode: isSelectionMode);
        },
      ),
      GoRoute(
        path: '/location/add',
        builder: (context, state) => const AddEditAddressScreen(),
      ),
      GoRoute(
        path: '/location/edit',
        builder: (context, state) {
           final address = state.extra as Address;
           return AddEditAddressScreen(address: address);
        },
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) {
          final extras = state.extra as Map<String, dynamic>;
          final address = extras['address'] as Address;
          final orderPreview = extras['orderPreview'] as Map<String, dynamic>;
          
          return CheckoutScreen(
            address: address,
            orderPreview: orderPreview,
          );
        },
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/item/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FoodDetailScreen(itemId: id);
        },
      ),
      GoRoute(
        path: '/admin',
        redirect: (context, state) async {
          final authService = AuthService();
          final user = SupabaseConfig.client.auth.currentUser;

          if (user == null) return '/signin';

          final isAdmin = await authService.isAdmin();
          if (!isAdmin) return '/';

          return null;
        },
        builder: (context, state) => const AdminHomeScreen(),
      ),

    ],
  );
}
