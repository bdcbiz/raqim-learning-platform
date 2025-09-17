import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/responsive_auth_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/auth/auth_service_factory.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool _isCheckingVerification = false;
  bool _isResendingEmail = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    // Auto send verification email on page load
    _sendInitialVerificationEmail();
    // Auto check verification status every 3 seconds
    _startVerificationCheck();
  }

  void _sendInitialVerificationEmail() async {
    final authService = AuthServiceFactory.createAuthService();
    await authService.sendEmailVerification();
  }

  void _startVerificationCheck() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _checkEmailVerification();
      }
    });
  }

  void _checkEmailVerification() async {
    if (_isCheckingVerification) return;

    setState(() {
      _isCheckingVerification = true;
      _message = null;
    });

    final authService = AuthServiceFactory.createAuthService();
    final isVerified = await authService.reloadUser();

    setState(() {
      _isCheckingVerification = false;
    });

    if (isVerified && mounted) {
      setState(() {
        _message = AppLocalizations.of(context)?.translate('emailVerified') ?? 'تم تأكيد البريد الإلكتروني بنجاح!';
        _isSuccess = true;
      });

      // Navigate to home after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.go('/');
        }
      });
    } else {
      // Continue checking every 3 seconds
      _startVerificationCheck();
    }
  }

  void _resendVerificationEmail() async {
    if (_isResendingEmail) return;

    setState(() {
      _isResendingEmail = true;
      _message = null;
    });

    final authService = AuthServiceFactory.createAuthService();
    final success = await authService.sendEmailVerification();

    setState(() {
      _isResendingEmail = false;
      if (success) {
        _message = AppLocalizations.of(context)?.translate('verificationEmailSent') ?? 'تم إرسال رسالة التحقق مرة أخرى';
        _isSuccess = true;
      } else {
        _message = AppLocalizations.of(context)?.translate('failedToSendVerification') ?? 'فشل في إرسال رسالة التحقق';
        _isSuccess = false;
      }
    });

    // Clear message after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _message = null;
        });
      }
    });
  }

  void _signOut() async {
    final authService = AuthServiceFactory.createAuthService();
    await authService.signOut();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authService = AuthServiceFactory.createAuthService();

    return ResponsiveAuthLayout(
      title: localizations?.translate('verifyEmail') ?? 'تحقق من بريدك الإلكتروني',
      subtitle: localizations?.translate('verificationEmailSent') ?? 'تم إرسال رسالة التحقق إلى بريدك الإلكتروني',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 64,
                  color: Colors.blue[600],
                ),
                const SizedBox(height: 16),
                Text(
                  authService.currentUser?.email ?? '',
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  localizations?.translate('checkEmailForVerification') ??
                  'تحقق من صندوق الوارد أو مجلد الرسائل غير المرغوبة وانقر على رابط التحقق',
                  style: AppTextStyles.body,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          if (_message != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isSuccess ? Colors.green[50] : Colors.red[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _isSuccess ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                    color: _isSuccess ? Colors.green : Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _message!,
                      style: TextStyle(
                        color: _isSuccess ? Colors.green : Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isCheckingVerification ? null : _checkEmailVerification,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: _isCheckingVerification
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      localizations?.translate('checkVerification') ?? 'تحقق من التأكيد',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _isResendingEmail ? null : _resendVerificationEmail,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: AppColors.primaryColor),
              ),
              child: _isResendingEmail
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    )
                  : Text(
                      localizations?.translate('resendVerification') ?? 'إعادة إرسال رسالة التحقق',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 24),

          TextButton(
            onPressed: _signOut,
            child: Text(
              localizations?.translate('useAnotherAccount') ?? 'استخدام حساب آخر',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}