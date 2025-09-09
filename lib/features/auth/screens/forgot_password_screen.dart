import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/widgets/adaptive_logo.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  void _handleForgotPassword() async {
    if (_formKey.currentState!.saveAndValidate()) {
      final email = _formKey.currentState!.value['email'];
      
      setState(() {
        _isLoading = true;
      });
      
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        context.go('/forgot-password/verify', extra: email);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width <= 600;
    final isTablet = size.width > 600 && size.width <= 900;
    final isWideScreen = size.width > 900;

    // Mobile layout
    if (isMobile) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppTheme.primaryColor),
            onPressed: () => context.go('/login'),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Illustration
                Center(
                  child: Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.secondaryColor.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.lock_reset,
                          size: 60,
                          color: AppTheme.primaryColor,
                        ),
                        Positioned(
                          right: 20,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.secondaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.email,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                Text(
                  AppLocalizations.of(context)?.translate('forgotPassword') ?? 'Forgot Password?',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Subtitle
                Text(
                  AppLocalizations.of(context)?.translate('forgotPasswordDescription') ?? "Don't worry! Enter your email and we'll send you a verification code to reset your password",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 15,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Form
                FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FormBuilderTextField(
                        name: 'email',
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)?.translate('email') ?? 'Email',
                          hintText: 'example@email.com',
                          prefixIcon: Icon(Icons.email_outlined, color: AppTheme.primaryColor),
                          filled: true,
                          fillColor: Colors.grey[50],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(errorText: AppLocalizations.of(context)?.translate('emailRequired') ?? 'Email is required'),
                          FormBuilderValidators.email(errorText: AppLocalizations.of(context)?.translate('enterValidEmail') ?? 'Enter a valid email'),
                        ]),
                      ),
                      const SizedBox(height: 32),
                      // Error message
                      if (authProvider.error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authProvider.error!,
                                  style: const TextStyle(color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Submit button
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  AppLocalizations.of(context)?.translate('sendCode') ?? 'Send Code',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Back to login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.translate('rememberedPassword') ?? 'Remembered password?',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 15,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: Text(
                              AppLocalizations.of(context)?.translate('login') ?? 'Login',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Tablet and Desktop layout
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: isWideScreen ? 5 : 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isWideScreen ? 48 : 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.mail_lock,
                            size: 80,
                            color: Colors.white,
                          ),
                          Positioned(
                            right: 25,
                            top: 25,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.key,
                                size: 24,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isWideScreen ? 32 : 24),
                    Text(
                      AppLocalizations.of(context)?.translate('passwordRecovery') ?? 'Password Recovery',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isWideScreen ? 36 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: Text(
                        AppLocalizations.of(context)?.translate('passwordRecoveryHelp') ?? 'We will help you recover your account with simple and secure steps',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isWideScreen ? 18 : 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: isWideScreen ? 3 : 3,
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isWideScreen ? 48 : 32),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: FormBuilder(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AppLocalizations.of(context)?.translate('forgotPassword') ?? 'Forgot Password?',
                            style: TextStyle(
                              fontSize: isWideScreen ? 32 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppLocalizations.of(context)?.translate('enterRegisteredEmail') ?? 'Enter your registered email and we will send you a verification code',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 40),
                          FormBuilderTextField(
                            name: 'email',
                            decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)?.translate('email') ?? 'Email',
                              hintText: 'example@email.com',
                              prefixIcon: const Icon(Icons.email_outlined),
                              filled: true,
                              fillColor: Colors.grey[50],
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
                                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: FormBuilderValidators.compose([
                              FormBuilderValidators.required(errorText: 'البريد الإلكتروني مطلوب'),
                              FormBuilderValidators.email(errorText: 'أدخل بريد إلكتروني صحيح'),
                            ]),
                          ),
                          const SizedBox(height: 32),
                          if (authProvider.error != null)
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
                                      authProvider.error!,
                                      style: const TextStyle(color: Colors.red, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleForgotPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
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
                                      AppLocalizations.of(context)?.translate('sendCode') ?? 'Send Code',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  AppLocalizations.of(context)?.translate('rememberedPassword') ?? 'Remembered password?',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    AppLocalizations.of(context)?.translate('login') ?? 'Login',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}