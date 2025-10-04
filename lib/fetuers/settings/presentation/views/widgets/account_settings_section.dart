import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/sign_up_view.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/sign_in_view.dart';

class AccountSettingsSection extends StatefulWidget {
  const AccountSettingsSection({super.key});

  @override
  State<AccountSettingsSection> createState() => _AccountSettingsSectionState();
}

class _AccountSettingsSectionState extends State<AccountSettingsSection> {
  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserState();
  }

  Future<void> _loadUserState() async {
    final isLoggedIn = await SupabaseAuthService.isLoggedIn();
    final userEmail = await SupabaseAuthService.getUserEmail();
    final userName = await SupabaseAuthService.getUserName();

    setState(() {
      _isLoggedIn = isLoggedIn;
      _userEmail = userEmail;
      _userName = userName;
    });
  }

  Future<void> _handleSignOut() async {
    final colorScheme = Theme.of(context).colorScheme;

    // Show confirmation dialog
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).tr('auth.signOutTitle')),
          content: Text(AppLocalizations.of(context).tr('auth.signOutMessage')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context).tr('settings.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: Text(AppLocalizations.of(context).tr('auth.signOut')),
            ),
          ],
        );
      },
    );

    if (shouldSignOut == true) {
      await SupabaseAuthService.signOut();
      await _loadUserState();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).tr('auth.signOutSuccess'),
            ),
          ),
        );
      }
    }
  }

  void _navigateToSignIn() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignInView()))
        .then((_) {
          _loadUserState(); // Refresh state when returning
        });
  }

  void _navigateToSignUp() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const SignUpView()))
        .then((_) {
          _loadUserState(); // Refresh state when returning
        });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsSection(
      title: AppLocalizations.of(context).tr('settings.account'),
      children: [
        if (_isLoggedIn) ...[
          // Show user info and sign out option when logged in
          if (_userName != null || _userEmail != null)
            ListTile(
              leading: Icon(Icons.person, color: colorScheme.primary),
              title: Text(
                _userName ?? _userEmail ?? '',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              subtitle: _userName != null && _userEmail != null
                  ? Text(
                      _userEmail!,
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                      ),
                    )
                  : null,
            ),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              AppLocalizations.of(context).tr('auth.signOut'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signOutSubtitle'),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            onTap: _handleSignOut,
          ),
        ] else ...[
          // Show sign in and sign up options when not logged in
          ListTile(
            leading: Icon(Icons.login, color: colorScheme.primary),
            title: Text(
              AppLocalizations.of(context).tr('auth.signIn'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signInSubtitle'),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            onTap: _navigateToSignIn,
          ),
          ListTile(
            leading: Icon(Icons.person_add, color: colorScheme.primary),
            title: Text(
              AppLocalizations.of(context).tr('auth.signUp'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signUpSubtitle'),
              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
            ),
            onTap: _navigateToSignUp,
          ),
        ],
      ],
    );
  }
}
