import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/widgets/modern_auth_text_field.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/widgets/modern_auth_button.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/sign_up_view.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/forgot_password_view.dart';

class ModernSignInViewBody extends StatefulWidget {
  const ModernSignInViewBody({super.key});

  @override
  State<ModernSignInViewBody> createState() => _ModernSignInViewBodyState();
}

class _ModernSignInViewBodyState extends State<ModernSignInViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).tr('auth.emailRequired');
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return AppLocalizations.of(context).tr('auth.invalidEmailFormat');
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppLocalizations.of(context).tr('auth.passwordRequired');
    }
    if (value.length < 6) {
      return AppLocalizations.of(context).tr('auth.passwordTooShort');
    }
    return null;
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseAuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null && mounted) {
        _showSnackBar(
          AppLocalizations.of(context).tr('auth.signInSuccess'),
          isSuccess: true,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = SupabaseAuthService.getErrorMessage(e);
        _showSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isSuccess
            ? Colors.green.shade600
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _navigateToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const SignUpView()));
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      final response = await SupabaseAuthService.signInWithGoogle();

      if (response.user != null && mounted) {
        _showSnackBar(
          AppLocalizations.of(context).tr('auth.signInSuccess'),
          isSuccess: true,
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = SupabaseAuthService.getErrorMessage(e);
        _showSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 32,
          vertical: 16,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: screenHeight - MediaQuery.of(context).padding.top - 100,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              // Welcome Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).tr('auth.welcomeBack'),
                    style: textTheme.displayMedium!.copyWith(
                      fontSize: AppTheme.getResponsiveFontSize(
                        context,
                        fontSize: 32,
                      ),
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context).tr('auth.signInSubtitle'),
                    style: textTheme.bodyLarge!.copyWith(
                      fontSize: AppTheme.getResponsiveFontSize(
                        context,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Sign In Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ModernAuthTextField(
                      label: AppLocalizations.of(
                        context,
                      ).tr('auth.emailAddress'),
                      hint: AppLocalizations.of(context).tr('auth.enterEmail'),
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      enabled: !_isLoading,
                    ),

                    const SizedBox(height: 24),

                    ModernAuthTextField(
                      label: AppLocalizations.of(context).tr('auth.password'),
                      hint: AppLocalizations.of(
                        context,
                      ).tr('auth.enterPassword'),
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      obscureText: true,
                      validator: _validatePassword,
                      enabled: !_isLoading,
                    ),

                    const SizedBox(height: 16),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPasswordView(),
                                  ),
                                );
                              },
                        child: Text(
                          AppLocalizations.of(
                            context,
                          ).tr('auth.forgotPassword'),
                          style: textTheme.bodyMedium!.copyWith(
                            fontSize: AppTheme.getResponsiveFontSize(
                              context,
                              fontSize: 14,
                            ),
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Sign In Button
                    ModernAuthButton(
                      text: AppLocalizations.of(context).tr('auth.signIn'),
                      onPressed: (_isLoading || _isGoogleLoading)
                          ? null
                          : _handleSignIn,
                      isLoading: _isLoading,
                      icon: Icons.login,
                    ),
                  ],
                ),
              ),

              // const SizedBox(height: 32),

              // // Google Sign-In Button
              // GoogleSignInButton(
              //   onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleSignIn,
              //   isLoading: _isGoogleLoading,
              // ),
              const SizedBox(height: 24),

              // Divider
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      AppLocalizations.of(context).tr('auth.or'),
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                        fontSize: AppTheme.getResponsiveFontSize(
                          context,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: colorScheme.outline.withOpacity(0.3),
                      thickness: 1,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Sign Up Link
              ModernAuthButton(
                text: AppLocalizations.of(context).tr('auth.createNewAccount'),
                onPressed: (_isLoading || _isGoogleLoading)
                    ? null
                    : _navigateToSignUp,
                isSecondary: true,
                icon: Icons.person_add_outlined,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
