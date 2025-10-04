import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/services/auth_service.dart';

/// A simple test widget to demonstrate and test the authentication functionality
/// This widget can be temporarily added to any screen for testing purposes
class AuthTestWidget extends StatefulWidget {
  const AuthTestWidget({super.key});

  @override
  State<AuthTestWidget> createState() => _AuthTestWidgetState();
}

class _AuthTestWidgetState extends State<AuthTestWidget> {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _userToken;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final userEmail = await AuthService.getUserEmail();
    final userName = await AuthService.getUserName();
    final userToken = await AuthService.getUserToken();
    
    setState(() {
      _isLoggedIn = isLoggedIn;
      _userEmail = userEmail;
      _userName = userName;
      _userToken = userToken;
    });
  }

  Future<void> _simulateLogin() async {
    await AuthService.saveUserData(
      token: 'test_token_${DateTime.now().millisecondsSinceEpoch}',
      email: 'test@example.com',
      name: 'Test User',
    );
    await _loadAuthState();
  }

  Future<void> _simulateLogout() async {
    await AuthService.logout();
    await _loadAuthState();
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
              'Auth Test Widget',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Logged In: $_isLoggedIn'),
            if (_userEmail != null) Text('Email: $_userEmail'),
            if (_userName != null) Text('Name: $_userName'),
            if (_userToken != null) Text('Token: ${_userToken!.substring(0, 20)}...'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _simulateLogin,
                  child: const Text('Simulate Login'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _simulateLogout,
                  child: const Text('Logout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
