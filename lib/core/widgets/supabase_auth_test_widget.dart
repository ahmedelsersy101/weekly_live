import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A test widget to demonstrate and test Supabase authentication functionality
/// This widget can be temporarily added to any screen for testing purposes
class SupabaseAuthTestWidget extends StatefulWidget {
  const SupabaseAuthTestWidget({super.key});

  @override
  State<SupabaseAuthTestWidget> createState() => _SupabaseAuthTestWidgetState();
}

class _SupabaseAuthTestWidgetState extends State<SupabaseAuthTestWidget> {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _userId;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final isLoggedIn = await SupabaseAuthService.isLoggedIn();
    final userEmail = await SupabaseAuthService.getUserEmail();
    final userName = await SupabaseAuthService.getUserName();
    final userId = await SupabaseAuthService.getUserId();
    final currentUser = SupabaseAuthService.getCurrentUser();
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userEmail = userEmail;
      _userName = userName;
      _userId = userId;
      _currentUser = currentUser;
    });
  }

  Future<void> _testSignUp() async {
    try {
      final response = await SupabaseAuthService.signUp(
        email: 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        password: 'testpassword123',
        fullName: 'Test User',
      );
      
      if (response.user != null) {
        _showSnackBar('Sign up successful!', isSuccess: true);
        await _loadAuthState();
      }
    } catch (e) {
      final errorMessage = SupabaseAuthService.getErrorMessage(e);
      _showSnackBar('Sign up failed: $errorMessage');
    }
  }

  Future<void> _testSignIn() async {
    try {
      final response = await SupabaseAuthService.signIn(
        email: 'test@example.com',
        password: 'testpassword123',
      );
      
      if (response.user != null) {
        _showSnackBar('Sign in successful!', isSuccess: true);
        await _loadAuthState();
      }
    } catch (e) {
      final errorMessage = SupabaseAuthService.getErrorMessage(e);
      _showSnackBar('Sign in failed: $errorMessage');
    }
  }

  Future<void> _testSignOut() async {
    try {
      await SupabaseAuthService.signOut();
      _showSnackBar('Sign out successful!', isSuccess: true);
      await _loadAuthState();
    } catch (e) {
      final errorMessage = SupabaseAuthService.getErrorMessage(e);
      _showSnackBar('Sign out failed: $errorMessage');
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess 
          ? Colors.green 
          : Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Supabase Auth Test Widget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Logged In: $_isLoggedIn'),
            if (_userEmail != null) Text('Email: $_userEmail'),
            if (_userName != null) Text('Name: $_userName'),
            if (_userId != null) Text('User ID: ${_userId!.substring(0, 8)}...'),
            if (_currentUser != null) 
              Text('Session Valid: ${_currentUser!.emailConfirmedAt != null}'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: _testSignUp,
                  child: const Text('Test Sign Up'),
                ),
                ElevatedButton(
                  onPressed: _testSignIn,
                  child: const Text('Test Sign In'),
                ),
                ElevatedButton(
                  onPressed: _testSignOut,
                  child: const Text('Sign Out'),
                ),
                ElevatedButton(
                  onPressed: _loadAuthState,
                  child: const Text('Refresh State'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
