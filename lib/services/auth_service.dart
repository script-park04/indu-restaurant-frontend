import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../config/supabase_config.dart';
import '../models/user_profile.dart';
import 'notifications/notification_service.dart';





class AuthService {
  final SupabaseClient _supabase = SupabaseConfig.client;
  // Check if current user is admin
Future<bool> isAdmin() async {
  try {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    final response = await _supabase
        .from('profiles')
        .select('role')
        .eq('id', user.id)
        .single();

    return response['role'] == 'admin';
  } catch (_) {
    return false;
  }
}
  // Get current user
  User? get currentUser => _supabase.auth.currentUser;
  
  // Get auth state stream
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Sign up with email and password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    String? referralCode,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'referred_by': referralCode,
        },
      );

      if (response.user != null) {
        // Profile is automatically created via database trigger
        // Update with full name if needed
        await _supabase.from('profiles').update({
          'full_name': fullName,
          if (referralCode != null) 'referred_by': referralCode,
        }).eq('id', response.user!.id);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      // Refresh FCM token after sign in
      await NotificationService().refreshToken();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: ['email'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Refresh FCM token after sign in
      await NotificationService().refreshToken();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Facebook
  Future<AuthResponse> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status != LoginStatus.success) {
        throw Exception('Facebook login failed: ${result.message}');
      }

      final String? accessToken = result.accessToken?.token;
      if (accessToken == null) {
        throw Exception('No access token found');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.facebook,
        idToken: accessToken,
      );

      // Refresh FCM token after sign in
      await NotificationService().refreshToken();

      return response;
    } catch (e) {
      rethrow;
    }
  }

  // Phone verification methods removed - requires Firebase setup
  // To enable: uncomment Firebase dependencies and configure Firebase

  // Get any user profile (Admin/Internal use)
  Future<UserProfile?> getProfileById(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Get user profile
  Future<UserProfile?> getUserProfile() async {
    try {
      if (currentUser == null) return null;

      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', currentUser!.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      await _supabase
          .from('profiles')
          .update(updates)
          .eq('id', currentUser!.id);
    } catch (e) {
      rethrow;
    }
  }

  // Check if phone is verified
  Future<bool> isPhoneVerified() async {
    try {
      // Bypassing phone verification as per user request
      return true;
    } catch (e) {
      return true;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      
      // Also sign out from Google and Facebook if needed
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      
      try {
        await FacebookAuth.instance.logOut();
      } catch (_) {}
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }
}
