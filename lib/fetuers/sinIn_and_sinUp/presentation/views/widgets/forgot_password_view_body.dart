import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/widgets/modern_auth_text_field.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/widgets/modern_auth_button.dart';

class ForgotPasswordViewBody extends StatefulWidget {
  const ForgotPasswordViewBody({super.key});

  @override
  State<ForgotPasswordViewBody> createState() => _ForgotPasswordViewBodyState();
}

class _ForgotPasswordViewBodyState extends State<ForgotPasswordViewBody> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handlePasswordReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await SupabaseAuthService.resetPassword(_emailController.text.trim());
      
      if (mounted) {
        setState(() {
          _emailSent = true;
        });
        
        _showSnackBar(
          AppLocalizations.of(context).tr('auth.resetEmailSent'),
          isSuccess: true,
        );
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = SupabaseAuthService.getErrorMessage(e);
        _showSnackBar('Password reset failed: $errorMessage');
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

  void _navigateBackToSignIn() {
    Navigator.of(context).pop();
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
              
              // Header Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context).tr('auth.resetPassword'),
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
                    _emailSent 
                      ? AppLocalizations.of(context).tr('auth.resetEmailSentDescription')
                      : AppLocalizations.of(context).tr('auth.resetPasswordSubtitle'),
                    style: textTheme.bodyLarge!.copyWith(
                      fontSize: AppTheme.getResponsiveFontSize(
                        context,
                        fontSize: 16,
                      ),
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              if (!_emailSent) ...[
                // Reset Password Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      ModernAuthTextField(
                        label: AppLocalizations.of(context).tr('auth.emailAddress'),
                        hint: AppLocalizations.of(context).tr('auth.enterEmailForReset'),
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                        enabled: !_isLoading,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Send Reset Link Button
                      ModernAuthButton(
                        text: AppLocalizations.of(context).tr('auth.sendResetLink'),
                        onPressed: _handlePasswordReset,
                        isLoading: _isLoading,
                        icon: Icons.send_outlined,
                      ),
                    ],
                  ),
                ),
              ] else ...[
                // Success State
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.mark_email_read_outlined,
                        size: 64,
                        color: Colors.green.shade600,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).tr('auth.checkYourEmail'),
                        style: textTheme.titleLarge!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).tr('auth.resetLinkSentTo'),
                        style: textTheme.bodyMedium!.copyWith(
                          color: Colors.green.shade700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _emailController.text,
                        style: textTheme.bodyMedium!.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade800,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Resend Button
                ModernAuthButton(
                  text: AppLocalizations.of(context).tr('auth.resendResetLink'),
                  onPressed: () {
                    setState(() {
                      _emailSent = false;
                    });
                  },
                  isSecondary: true,
                  icon: Icons.refresh_outlined,
                ),
              ],

              const SizedBox(height: 32),

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
                      'or',
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

              const SizedBox(height: 32),

              // Back to Sign In Button
              ModernAuthButton(
                text: AppLocalizations.of(context).tr('auth.backToSignIn'),
                onPressed: _navigateBackToSignIn,
                isSecondary: true,
                icon: Icons.arrow_back_outlined,
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
