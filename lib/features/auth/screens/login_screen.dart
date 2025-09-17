import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../widgets/responsive_auth_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/auth/auth_service_factory.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  String? _errorMessage;
  bool _isLoading = false;

  void _handleLogin() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = AuthServiceFactory.createAuthService();

      final result = await authService.signInWithEmailAndPassword(
        email: values['email'],
        password: values['password'],
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success && mounted) {
        if (result.status == AuthenticationStatus.authenticated) {
          context.go('/');
        } else if (result.status == AuthenticationStatus.emailNotVerified) {
          // Navigate to email verification screen
          context.go('/email-verification');
        }
      } else if (mounted) {
        setState(() {
          _errorMessage = result.errorMessage;
        });
      }
    }
  }

  void _handleGoogleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authService = AuthServiceFactory.createAuthService();
    final result = await authService.signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result.success && mounted) {
      context.go('/');
    } else if (mounted) {
      setState(() {
        _errorMessage = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return ResponsiveAuthLayout(
      title: localizations?.translate('welcomeBack') ?? 'مرحباً بعودتك',
      subtitle: localizations?.translate('loginToYourAccount') ?? 'سجل دخولك إلى حسابك',
      form: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: localizations?.translate('email') ?? 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: localizations?.translate('emailRequired') ?? 'البريد الإلكتروني مطلوب'),
                FormBuilderValidators.email(errorText: localizations?.translate('enterValidEmail') ?? 'أدخل بريد إلكتروني صحيح'),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'password',
              decoration: InputDecoration(
                labelText: localizations?.translate('password') ?? 'كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
                ),
              ),
              obscureText: _obscurePassword,
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: localizations?.translate('passwordRequired') ?? 'كلمة المرور مطلوبة'),
                FormBuilderValidators.minLength(6, errorText: localizations?.translate('passwordMinLength') ?? 'كلمة المرور يجب أن تكون 6 أحرف على الأقل'),
              ]),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: () {
                  context.go('/forgot-password');
                },
                child: Text(
                  localizations?.translate('forgotPassword') ?? 'نسيت كلمة المرور؟',
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        localizations?.translate('login') ?? 'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    localizations?.translate('or') ?? 'أو',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 50,
              child: OutlinedButton(
                onPressed: _isLoading ? null : _handleGoogleLogin,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 20,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.g_mobiledata, size: 24);
                      },
                    ),
                    const SizedBox(width: 12),
                    Text(
                      localizations?.translate('continueWithGoogle') ?? 'المتابعة مع جوجل',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    localizations?.translate('dontHaveAccount') ?? 'ليس لديك حساب؟',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      localizations?.translate('register') ?? 'إنشاء حساب',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}