import 'dart:async';
import 'package:flutter/services.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';

class DeepLinkService {
  static const MethodChannel _channel = MethodChannel('deep_link_channel');
  static StreamController<String>? _linkStreamController;

  /// Optional callback setter used by app to receive link strings
  static void Function(String link)? onLinkReceived;

  /// Initialize deep link handling
  static Future<void> initialize() async {
    _linkStreamController = StreamController<String>.broadcast();

    // Listen for incoming links when app is already running
    _channel.setMethodCallHandler(_handleMethodCall);

    // Check for initial link when app is launched
    try {
      final String? initialLink = await _channel.invokeMethod('getInitialLink');
      if (initialLink != null) {
        _handleIncomingLink(initialLink);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  /// Handle method calls from native platforms
  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onNewLink':
        final String link = call.arguments;
        _handleIncomingLink(link);
        break;
    }
  }

  /// Process incoming deep links
  static void _handleIncomingLink(String link) {
    _linkStreamController?.add(link);
    _processLink(link);
    // notify app-level callback if set
    if (onLinkReceived != null) {
      try {
        onLinkReceived!(link);
      } catch (_) {}
    }
  }

  /// Process and route deep links
  static Future<void> _processLink(String link) async {
    final uri = Uri.parse(link);

    // Handle different types of deep links
    if (uri.scheme == 'io.supabase.weeklydashboard') {
      switch (uri.host) {
        case 'login-callback':
          await _handleAuthCallback(link);
          break;
        case 'reset-password':
          await _handlePasswordReset(link);
          break;
        default:
          // Handle other deep links
          break;
      }
    }
  }

  /// Handle authentication callbacks (email confirmation, OAuth)
  static Future<void> _handleAuthCallback(String url) async {
    try {
      final uri = Uri.parse(url);

      // Check if it's an email confirmation
      if (uri.queryParameters.containsKey('access_token') ||
          uri.fragment.contains('access_token')) {
        bool success = false;

        // Try OAuth callback first
        if (uri.fragment.isNotEmpty) {
          success = await SupabaseAuthService.handleOAuthCallback(url);
        }

        // If not OAuth, try email confirmation
        if (!success) {
          success = await SupabaseAuthService.handleEmailConfirmation(url);
        }

        if (success) {
          // Navigate to main app or show success message
          _notifyAuthSuccess();
        } else {
          _notifyAuthError('Authentication failed');
        }
      }
    } catch (e) {
      _notifyAuthError('Failed to process authentication: ${e.toString()}');
    }
  }

  /// Handle password reset callbacks
  static Future<void> _handlePasswordReset(String url) async {
    try {
      // Handle password reset deep link
      // This would typically navigate to a password reset screen
      _notifyPasswordReset(url);
    } catch (e) {
      _notifyAuthError('Failed to process password reset: ${e.toString()}');
    }
  }

  /// Notify successful authentication
  static void _notifyAuthSuccess() {
    // This could trigger a navigation event or state update
    // For now, we'll just log it
    print('Authentication successful via deep link');
  }

  /// Notify authentication error
  static void _notifyAuthError(String error) {
    // This could show an error dialog or notification
    print('Authentication error: $error');
  }

  /// Notify password reset
  static void _notifyPasswordReset(String url) {
    // This could navigate to password reset screen
    print('Password reset requested: $url');
  }

  /// Get the stream of incoming links
  static Stream<String>? get linkStream => _linkStreamController?.stream;

  /// Dispose resources
  static void dispose() {
    _linkStreamController?.close();
    _linkStreamController = null;
  }
}
