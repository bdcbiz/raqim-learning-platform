import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../widgets/responsive_auth_layout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../services/auth/auth_interface.dart';
import '../../../services/auth/auth_service_factory.dart';
import '../../../services/validation/email_validation_service.dart';
import '../../../services/database/database_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _errorMessage;
  bool _isLoading = false;
  bool _isValidatingEmail = false;
  String? _emailValidationMessage;
  String? _emailSuggestion;
  final EmailValidationService _emailValidator = EmailValidationService();
  final DatabaseService _databaseService = DatabaseService();

  Future<void> _validateEmailField(String email) async {
    if (email.isEmpty) {
      setState(() {
        _emailValidationMessage = null;
        _emailSuggestion = null;
        _isValidatingEmail = false;
      });
      return;
    }

    setState(() {
      _isValidatingEmail = true;
    });

    try {
      EmailValidationResult result = await _emailValidator.validateEmail(email);

      setState(() {
        _isValidatingEmail = false;
        if (result.isValid) {
          _emailValidationMessage = null;
          _emailSuggestion = null;
        } else {
          _emailValidationMessage = result.reason;
          _emailSuggestion = result.suggestion;
        }
      });
    } catch (e) {
      setState(() {
        _isValidatingEmail = false;
        _emailValidationMessage = 'فشل في التحقق من البريد الإلكتروني';
        _emailSuggestion = null;
      });
    }
  }

  void _applySuggestedEmail() {
    if (_emailSuggestion != null) {
      _formKey.currentState?.fields['email']?.didChange(_emailSuggestion);
      setState(() {
        _emailValidationMessage = null;
        _emailSuggestion = null;
      });
    }
  }

  void _handleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate('mustAgreeToTerms') ?? 'يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.saveAndValidate()) {
      final values = _formKey.currentState!.value;

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final authService = AuthServiceFactory.createAuthService();

      final result = await authService.registerWithEmailAndPassword(
        name: values['name'],
        email: values['email'],
        password: values['password'],
      );

      setState(() {
        _isLoading = false;
      });

      if (result.success && mounted) {
        // Create user in database after successful Firebase registration
        if (result.user != null) {
          try {
            await _databaseService.createUser(result.user!);
            print('DEBUG: User created in database successfully');
          } catch (e) {
            print('ERROR: Failed to create user in database: $e');
            // Continue anyway - user is already registered in Firebase
          }
        }

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

  void _handleGoogleRegister() async {
    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)?.translate('mustAgreeToTerms') ?? 'يجب الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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
      title: localizations?.translate('createNewAccount') ?? 'إنشاء حساب جديد',
      subtitle: localizations?.translate('getStarted') ?? 'ابدأ رحلتك',
      form: FormBuilder(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormBuilderTextField(
              name: 'name',
              decoration: InputDecoration(
                labelText: localizations?.translate('fullName') ?? 'الاسم الكامل',
                prefixIcon: const Icon(Icons.person_outline),
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
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: localizations?.translate('nameRequired') ?? 'الاسم مطلوب'),
                FormBuilderValidators.minLength(3, errorText: localizations?.translate('nameMinLength') ?? 'الاسم يجب أن يكون 3 أحرف على الأقل'),
              ]),
            ),
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'email',
              decoration: InputDecoration(
                labelText: localizations?.translate('email') ?? 'البريد الإلكتروني',
                prefixIcon: const Icon(Icons.email_outlined),
                suffixIcon: _isValidatingEmail
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _emailValidationMessage == null
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.error, color: Colors.red),
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
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) {
                if (value != null && value.isNotEmpty) {
                  // Debounce email validation
                  Future.delayed(const Duration(milliseconds: 800), () {
                    if (_formKey.currentState?.fields['email']?.value == value) {
                      _validateEmailField(value);
                    }
                  });
                }
              },
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: localizations?.translate('emailRequired') ?? 'البريد الإلكتروني مطلوب'),
                FormBuilderValidators.email(errorText: localizations?.translate('enterValidEmail') ?? 'أدخل بريد إلكتروني صحيح'),
                (value) {
                  if (_emailValidationMessage != null) {
                    return _emailValidationMessage;
                  }
                  return null;
                },
              ]),
            ),
            // Email suggestion widget
            if (_emailSuggestion != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'هل تقصد:',
                            style: TextStyle(color: Colors.blue[800], fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: _applySuggestedEmail,
                            child: Text(
                              _emailSuggestion!,
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        setState(() {
                          _emailSuggestion = null;
                          _emailValidationMessage = null;
                        });
                      },
                    ),
                  ],
                ),
              )
            else
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
            const SizedBox(height: 16),
            FormBuilderTextField(
              name: 'confirmPassword',
              decoration: InputDecoration(
                labelText: localizations?.translate('confirmPassword') ?? 'تأكيد كلمة المرور',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
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
              obscureText: _obscureConfirmPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.translate('confirmPasswordRequired') ?? 'تأكيد كلمة المرور مطلوب';
                }
                if (_formKey.currentState?.fields['password']?.value != value) {
                  return localizations?.translate('passwordMismatch') ?? 'كلمتا المرور غير متطابقتين';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              title: Wrap(
                children: [
                  Text(localizations?.translate('agreeToTermsAndConditions') ?? 'أوافق على '),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      localizations?.translate('termsAndConditions') ?? 'الشروط والأحكام',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Text(localizations?.translate('and') ?? ' و'),
                  GestureDetector(
                    onTap: () {},
                    child: Text(
                      localizations?.translate('privacyPolicy') ?? 'سياسة الخصوصية',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              activeColor: AppColors.primaryColor,
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
                onPressed: _isLoading ? null : _handleRegister,
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
                        localizations?.translate('createAccount') ?? 'إنشاء حساب',
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
                onPressed: _isLoading ? null : _handleGoogleRegister,
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
                      localizations?.translate('registerWithGoogle') ?? 'التسجيل بواسطة Google',
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
                    localizations?.translate('alreadyHaveAccount') ?? 'لديك حساب بالفعل؟',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                Flexible(
                  child: TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      localizations?.translate('login') ?? 'تسجيل الدخول',
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