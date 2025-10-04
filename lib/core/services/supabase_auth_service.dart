import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:weekly_dash_board/core/services/data_migration_service.dart';
import 'dart:async';

class SupabaseAuthService {
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _otpResendCooldownKey = 'otp_resend_cooldown';

  // Google Sign-In instance
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Use the Web Client ID from Google Cloud Console
    serverClientId: 'YOUR_GOOGLE_OAUTH_WEB_CLIENT_ID.apps.googleusercontent.com',
  );

  // Get Supabase client
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Check if user is currently logged in
  static Future<bool> isLoggedIn() async {
    // Check both Supabase session and SharedPreferences
    final session = _supabase.auth.currentSession;
    final prefs = await SharedPreferences.getInstance();
    final localIsLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

    // If we have a valid session, ensure local storage is updated
    if (session != null && session.user != null) {
      if (!localIsLoggedIn) {
        await _saveUserDataLocally(session.user);
      }
      return true;
    }

    // If no session but local storage says logged in, clear local storage
    if (session == null && localIsLoggedIn) {
      await _clearUserDataLocally();
      return false;
    }

    return localIsLoggedIn;
  }

  /// Get current user
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// Get user email
  static Future<String?> getUserEmail() async {
    final user = getCurrentUser();
    if (user != null) {
      return user.email;
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Get user ID
  static Future<String?> getUserId() async {
    final user = getCurrentUser();
    if (user != null) {
      return user.id;
    }

    // Fallback to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Get user display name
  static Future<String?> getUserName() async {
    final user = getCurrentUser();
    if (user != null) {
      // Try to get name from user metadata or email
      final metadata = user.userMetadata;
      if (metadata != null && metadata['full_name'] != null) {
        return metadata['full_name'] as String;
      }
      if (metadata != null && metadata['name'] != null) {
        return metadata['name'] as String;
      }
      // Fallback to email username
      if (user.email != null) {
        return user.email!.split('@').first;
      }
    }
    return null;
  }

  /// Validate Gmail address
  static bool isValidGmailAddress(String email) {
    return email.toLowerCase().endsWith('@gmail.com');
  }

  /// Sign up with Gmail only - immediate activation without email verification
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      // Validate Gmail address
      if (!isValidGmailAddress(email)) {
        throw const AuthException(
          'Only Gmail addresses (@gmail.com) are allowed for registration.',
        );
      }

      // Create the user without triggering email verification flow
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      // If sign up did not return an active session, sign in immediately
      AuthResponse finalResponse = response;
      if (response.user == null || _supabase.auth.currentSession == null) {
        finalResponse = await _supabase.auth.signInWithPassword(email: email, password: password);
      }

      if (finalResponse.user != null) {
        await _saveUserDataLocally(finalResponse.user!);
        _handlePostLoginDataSync();
      }

      return finalResponse;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(email: email, password: password);

      if (response.user != null) {
        await _saveUserDataLocally(response.user!);

        // Trigger data migration/sync after successful login
        _handlePostLoginDataSync();
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out
  static Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await signOutFromGoogle(); // Also sign out from Google
      await _clearUserDataLocally();
    } catch (e) {
      // Even if Supabase signOut fails, clear local data
      await signOutFromGoogle();
      await _clearUserDataLocally();
      rethrow;
    }
  }

  /// Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.weeklydashboard://reset-password/',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Resend email confirmation
  static Future<void> resendEmailConfirmation(String email) async {
    try {
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.weeklydashboard://login-callback/',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Verify OTP for email confirmation
  static Future<AuthResponse> verifyOTP({required String email, required String token}) async {
    try {
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: token,
        email: email,
      );

      if (response.user != null) {
        await _saveUserDataLocally(response.user!);
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// Check if user can resend OTP (cooldown management)
  static Future<bool> canResendOTP() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResendTime = prefs.getInt(_otpResendCooldownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const cooldownDuration = 60000; // 60 seconds

    return (currentTime - lastResendTime) >= cooldownDuration;
  }

  /// Get remaining cooldown time in seconds
  static Future<int> getRemainingCooldownTime() async {
    final prefs = await SharedPreferences.getInstance();
    final lastResendTime = prefs.getInt(_otpResendCooldownKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    const cooldownDuration = 60000; // 60 seconds

    final remainingTime = cooldownDuration - (currentTime - lastResendTime);
    return remainingTime > 0 ? (remainingTime / 1000).ceil() : 0;
  }

  /// Set OTP resend cooldown
  static Future<void> setOTPResendCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_otpResendCooldownKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Sign in with Google using Google Sign-In package
  static Future<AuthResponse> signInWithGoogle() async {
    try {
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw const AuthException('Google Sign-In was cancelled');
      }

      // Get Google authentication
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw const AuthException('Failed to get Google ID token');
      }

      // Sign in to Supabase with Google credentials
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: googleAuth.idToken!,
        accessToken: googleAuth.accessToken,
      );

      if (response.user != null) {
        await _saveUserDataLocally(response.user!);
      }

      return response;
    } catch (e) {
      // Sign out from Google if there's an error
      await _googleSignIn.signOut();
      rethrow;
    }
  }

  /// Sign out from Google
  static Future<void> signOutFromGoogle() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      // Ignore Google sign out errors
    }
  }

  /// Save user data to SharedPreferences
  static Future<void> _saveUserDataLocally(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_userIdKey, user.id);
    if (user.email != null) {
      await prefs.setString(_userEmailKey, user.email!);
    }
  }

  /// Clear user data from SharedPreferences
  static Future<void> _clearUserDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userEmailKey);
  }

  /// Listen to auth state changes
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  /// Handle deep link for email confirmation
  static Future<bool> handleEmailConfirmation(String url) async {
    try {
      final uri = Uri.parse(url);
      final accessToken = uri.queryParameters['access_token'];
      final refreshToken = uri.queryParameters['refresh_token'];

      if (accessToken != null && refreshToken != null) {
        final response = await _supabase.auth.setSession(accessToken);
        if (response.user != null) {
          await _saveUserDataLocally(response.user!);

          // Trigger data migration/sync after OAuth callback
          _handlePostLoginDataSync();
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Handle OAuth callback
  static Future<bool> handleOAuthCallback(String url) async {
    try {
      final uri = Uri.parse(url);

      // Handle the OAuth callback
      if (uri.fragment.isNotEmpty) {
        final fragment = uri.fragment;
        final params = Uri.splitQueryString(fragment);

        final accessToken = params['access_token'];
        final refreshToken = params['refresh_token'];

        if (accessToken != null && refreshToken != null) {
          final response = await _supabase.auth.setSession(accessToken);
          if (response.user != null) {
            await _saveUserDataLocally(response.user!);

            // Trigger data migration/sync after email confirmation
            _handlePostLoginDataSync();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Update user's password after reset flow. Returns true if successful.
  static Future<bool> updatePassword(String newPassword) async {
    try {
      final response = await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return response.user != null;
    } catch (e) {
      rethrow;
    }
  }

  /// Extract access_token or other params from a reset-password deep link
  static String? extractResetToken(String url) {
    try {
      final uri = Uri.parse(url);
      // Supabase may include 'access_token' in fragment or query
      if (uri.queryParameters.containsKey('access_token')) {
        return uri.queryParameters['access_token'];
      }
      if (uri.fragment.isNotEmpty) {
        final fragParams = Uri.splitQueryString(uri.fragment);
        return fragParams['access_token'] ?? fragParams['access-token'] ?? fragParams['token'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Initialize auth state on app start
  static Future<void> initializeAuthState() async {
    final session = _supabase.auth.currentSession;
    if (session != null && session.user != null) {
      await _saveUserDataLocally(session.user);

      // Check if data migration/sync is needed for existing session
      _handlePostLoginDataSync();
    } else {
      await _clearUserDataLocally();
    }
  }

  /// Handle data migration and sync after successful login
  static void _handlePostLoginDataSync() {
    // Run data migration/sync in background to avoid blocking UI
    Future.microtask(() async {
      try {
        // Check if migration is needed
        final migrationNeeded = await DataMigrationService.isMigrationNeeded();

        if (migrationNeeded) {
          print('SupabaseAuth: Starting data migration for user');
          final migrationResult = await DataMigrationService.migrateUserData();

          if (migrationResult.success) {
            print('SupabaseAuth: Data migration completed successfully');
            print(
              'SupabaseAuth: Migrated ${migrationResult.tasksCount} tasks, ${migrationResult.categoriesCount} categories',
            );
          } else {
            print('SupabaseAuth: Data migration failed: ${migrationResult.error}');
          }
        } else {
          print('SupabaseAuth: No data migration needed, loading user data from Supabase');
          final userDataResult = await DataMigrationService.loadUserDataFromSupabase();

          if (userDataResult.success) {
            print('SupabaseAuth: User data loaded successfully from Supabase');
            print(
              'SupabaseAuth: Loaded ${userDataResult.tasks.length} tasks, ${userDataResult.categories.length} categories',
            );
          } else {
            print('SupabaseAuth: Failed to load user data: ${userDataResult.error}');
          }
        }
      } catch (e) {
        print('SupabaseAuth: Error in post-login data sync: $e');
      }
    });
  }

  /// Get error message from AuthException
  static String getErrorMessage(dynamic error) {
    if (error is AuthException) {
      switch (error.message) {
        case 'Invalid login credentials':
          return 'Invalid email or password. Please try again.';
        case 'Email not confirmed':
          return 'Unable to sign in. Please try again.';
        case 'User already registered':
          return 'An account with this email already exists.';
        case 'Password should be at least 6 characters':
          return 'Password must be at least 6 characters long.';
        case 'Unable to validate email address: invalid format':
          return 'Please enter a valid email address.';
        case 'Only Gmail addresses (@gmail.com) are allowed for registration.':
          return 'Only Gmail addresses (@gmail.com) are allowed for registration.';
        case 'Google Sign-In was cancelled':
        case 'Google Sign-In failed or was cancelled':
        case 'Google Sign-In timeout':
        case 'Failed to get Google ID token':
          return 'Google Sign-In was cancelled or failed. Please try again.';
        case 'Token has expired or is invalid':
          return 'Verification code has expired. Please request a new one.';
        case 'Invalid token':
          return 'Invalid verification code. Please try again.';
        case 'Email link is invalid or has expired':
        case 'otp_expired':
          return 'Email confirmation link has expired. Please request a new one.';
        case 'access_denied':
          return 'Access denied. Please check your email and try again.';
        default:
          return error.message;
      }
    }
    return error.toString();
  }
}
