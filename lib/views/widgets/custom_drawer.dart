import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/constants/app_color.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/sign_in_view.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/sign_up_view.dart';
import 'package:weekly_dash_board/views/widgets/list_view_drawer_item.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int index, DrawerPage page)? onItemSelected;

  const CustomDrawer({super.key, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Divider(
              color: Theme.of(context).colorScheme.surface,
              height: 1,
              thickness: 1,
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 120,
              color: Theme.of(context).colorScheme.primary, // Primary color
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.dashboard,
                      size: 50,
                      color: AppColors.textOnPrimary,
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        AppLocalizations.of(context).tr('navigation.weekly'),
                        style: const TextStyle(
                          color: AppColors.surface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Divider(
              color: Theme.of(context).colorScheme.surface,
              height: 1,
              thickness: 1,
            ),
          ),
          ListViewDrawerItem(onItemSelected: onItemSelected),

          const SliverFillRemaining(
            hasScrollBody: false,
            child: Column(
              children: [
                Expanded(child: SizedBox()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: AccountSettingsSectionDrawer(),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSettingsSectionDrawer extends StatefulWidget {
  const AccountSettingsSectionDrawer({super.key});

  @override
  State<AccountSettingsSectionDrawer> createState() =>
      _AccountSettingsSectionDrawerState();
}

class _AccountSettingsSectionDrawerState
    extends State<AccountSettingsSectionDrawer> {
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
      color: AppColors.transparent,
      title: AppLocalizations.of(context).tr('settings.account'),
      textColor: AppColors.textOnPrimary,
      children: [
        if (_isLoggedIn) ...[
          // Show user info and sign out option when logged in
          if (_userName != null || _userEmail != null)
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.textOnPrimary),
              title: Text(
                _userName ?? _userEmail ?? '',
                style: const TextStyle(color: AppColors.textOnPrimary),
              ),
              subtitle: _userName != null && _userEmail != null
                  ? Text(
                      _userEmail!,
                      style: TextStyle(
                        color: AppColors.textOnPrimary.withOpacity(0.7),
                      ),
                    )
                  : null,
            ),
          ListTile(
            leading: Icon(Icons.logout, color: colorScheme.error),
            title: Text(
              AppLocalizations.of(context).tr('auth.signOut'),
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signOutSubtitle'),
              style: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
            ),
            onTap: _handleSignOut,
          ),
        ] else ...[
          // Show sign in and sign up options when not logged in
          ListTile(
            leading: const Icon(Icons.login, color: AppColors.textOnPrimary),
            title: Text(
              AppLocalizations.of(context).tr('auth.signIn'),
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signInSubtitle'),
              style: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
            ),
            onTap: _navigateToSignIn,
          ),
          ListTile(
            leading: const Icon(
              Icons.person_add,
              color: AppColors.textOnPrimary,
            ),
            title: Text(
              AppLocalizations.of(context).tr('auth.signUp'),
              style: const TextStyle(color: AppColors.textOnPrimary),
            ),
            subtitle: Text(
              AppLocalizations.of(context).tr('auth.signUpSubtitle'),
              style: TextStyle(color: AppColors.textOnPrimary.withOpacity(0.7)),
            ),
            onTap: _navigateToSignUp,
          ),
        ],
      ],
    );
  }
}
