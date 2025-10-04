import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/fetuers/sinIn_and_sinUp/presentation/views/widgets/modern_auth_button.dart';

class EmailVerificationViewBody extends StatefulWidget {
  final String email;
  
  const EmailVerificationViewBody({
    super.key,
    required this.email,
  });

  @override
  State<EmailVerificationViewBody> createState() => _EmailVerificationViewBodyState();
}

class _EmailVerificationViewBodyState extends State<EmailVerificationViewBody> {
  final List<TextEditingController> _otpControllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  Timer? _cooldownTimer;
  int _cooldownSeconds = 0;

  @override
  void initState() {
    super.initState();
    _checkInitialCooldown();
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialCooldown() async {
    final remainingTime = await SupabaseAuthService.getRemainingCooldownTime();
    if (remainingTime > 0) {
      setState(() {
        _cooldownSeconds = remainingTime;
      });
      _startCooldownTimer();
    }
  }

  void _startCooldownTimer() {
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _cooldownSeconds--;
      });
      if (_cooldownSeconds <= 0) {
        timer.cancel();
      }
    });
  }

  String get _otpCode {
    return _otpControllers.map((controller) => controller.text).join();
  }

  bool get _isOtpComplete {
    return _otpCode.length == 6;
  }

  void _onOtpChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Auto-verify when all digits are entered
    if (_isOtpComplete) {
      _handleVerifyOTP();
    }
  }

  Future<void> _handleVerifyOTP() async {
    if (!_isOtpComplete) {
      _showSnackBar(AppLocalizations.of(context).tr('auth.enterCompleteOTP'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await SupabaseAuthService.verifyOTP(
        email: widget.email,
        token: _otpCode,
      );

      if (response.user != null && mounted) {
        _showSnackBar(
          AppLocalizations.of(context).tr('auth.emailVerifiedSuccess'),
          isSuccess: true,
        );
        
        // Navigate back to sign in or main app
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = SupabaseAuthService.getErrorMessage(e);
        _showSnackBar(errorMessage);
        _clearOTP();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendOTP() async {
    final canResend = await SupabaseAuthService.canResendOTP();
    if (!canResend) {
      _showSnackBar(AppLocalizations.of(context).tr('auth.waitBeforeResend'));
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      await SupabaseAuthService.resendEmailConfirmation(widget.email);
      await SupabaseAuthService.setOTPResendCooldown();
      
      if (mounted) {
        _showSnackBar(
          AppLocalizations.of(context).tr('auth.otpResent'),
          isSuccess: true,
        );
        
        setState(() {
          _cooldownSeconds = 60;
        });
        _startCooldownTimer();
        _clearOTP();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = SupabaseAuthService.getErrorMessage(e);
        _showSnackBar(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  void _clearOTP() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 24 : 32,
          vertical: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 32),
            
            // Email verification icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_read_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              AppLocalizations.of(context).tr('auth.verifyEmail'),
              style: textTheme.displayMedium!.copyWith(
                fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 28),
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 16),
            
            // Subtitle
            Text(
              AppLocalizations.of(context).tr('auth.verifyEmailSubtitle'),
              style: textTheme.bodyLarge!.copyWith(
                fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 8),
            
            // Email display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.email,
                style: textTheme.bodyMedium!.copyWith(
                  fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // OTP Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  height: 60,
                  child: TextFormField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    enabled: !_isLoading,
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: (value) => _onOtpChanged(value, index),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 32),
            
            // Verify Button
            ModernAuthButton(
              text: AppLocalizations.of(context).tr('auth.verifyCode'),
              onPressed: _isOtpComplete && !_isLoading ? _handleVerifyOTP : null,
              isLoading: _isLoading,
              icon: Icons.verified_user,
            ),
            
            const SizedBox(height: 24),
            
            // Resend OTP
            if (_cooldownSeconds > 0)
              Text(
                AppLocalizations.of(context).tr('auth.resendIn').replaceAll('{seconds}', _cooldownSeconds.toString()),
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                ),
                textAlign: TextAlign.center,
              )
            else
              TextButton(
                onPressed: _isResending ? null : _handleResendOTP,
                child: _isResending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                    )
                  : Text(
                      AppLocalizations.of(context).tr('auth.resendCode'),
                      style: textTheme.bodyMedium!.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                      ),
                    ),
              ),
            
            const SizedBox(height: 32),
            
            // Back to Sign In
            TextButton(
              onPressed: _isLoading ? null : () {
                Navigator.of(context).pop();
              },
              child: Text(
                AppLocalizations.of(context).tr('auth.backToSignIn'),
                style: textTheme.bodyMedium!.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.7),
                  fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
