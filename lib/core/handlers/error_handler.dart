import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../exceptions/app_exceptions.dart';
import '../utils/logger.dart';

/// Centralized error handling service
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();

  /// Global error handling for the application
  static void handleError(dynamic error, {StackTrace? stackTrace, String? context}) {
    Logger.error('Error occurred${context != null ? ' in $context' : ''}: $error');

    if (stackTrace != null) {
      Logger.error('Stack trace: $stackTrace');
    }

    // Log to crash reporting service in production
    if (kReleaseMode) {
      _reportToCrashlytics(error, stackTrace, context);
    }
  }

  /// Handle API errors and convert them to user-friendly messages
  static String handleApiError(dynamic error) {
    if (error is NetworkException) {
      return _getNetworkErrorMessage(error);
    } else if (error is AuthException) {
      return _getAuthErrorMessage(error);
    } else if (error is ValidationException) {
      return _getValidationErrorMessage(error);
    } else if (error is BusinessLogicException) {
      return error.message;
    } else if (error is TimeoutException) {
      return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
    } else {
      Logger.error('Unhandled error type: ${error.runtimeType}');
      return 'حدث خطأ غير متوقع، يرجى المحاولة مرة أخرى';
    }
  }

  /// Show error dialog to user
  static void showErrorDialog(
    BuildContext context,
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'خطأ'),
        content: Text(message),
        actions: [
          if (onRetry != null)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              child: const Text('إعادة المحاولة'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  /// Show error snackbar to user
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red[700],
        action: onRetry != null
            ? SnackBarAction(
                label: 'إعادة المحاولة',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  /// Convert exception to user-friendly error message
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return handleApiError(error);
    } else if (error is FormatException) {
      return 'تنسيق البيانات غير صحيح';
    } else if (error is TypeError) {
      return 'خطأ في نوع البيانات';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }

  /// Wrap async operations with error handling
  static Future<T?> safeAsyncCall<T>(
    Future<T> Function() operation, {
    String? context,
    T? fallbackValue,
    bool showError = true,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace, context: context);
      return fallbackValue;
    }
  }

  /// Network error messages
  static String _getNetworkErrorMessage(NetworkException error) {
    switch (error.code) {
      case 'no_internet':
        return 'لا يوجد اتصال بالإنترنت، يرجى التحقق من الاتصال';
      case 'server_error':
        return 'خطأ في الخادم، يرجى المحاولة لاحقاً';
      case 'timeout':
        return 'انتهت مهلة الاتصال، يرجى المحاولة مرة أخرى';
      case 'dns_error':
        return 'خطأ في الاتصال بالخادم';
      default:
        return error.message.isNotEmpty
            ? error.message
            : 'خطأ في الشبكة، يرجى المحاولة مرة أخرى';
    }
  }

  /// Authentication error messages
  static String _getAuthErrorMessage(AuthException error) {
    switch (error.code) {
      case 'invalid_credentials':
        return 'بيانات الدخول غير صحيحة';
      case 'user_not_found':
        return 'المستخدم غير موجود';
      case 'email_already_exists':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'weak_password':
        return 'كلمة المرور ضعيفة جداً';
      case 'session_expired':
        return 'انتهت صلاحية جلسة العمل، يرجى تسجيل الدخول مرة أخرى';
      case 'account_disabled':
        return 'تم تعطيل الحساب، يرجى التواصل مع الدعم';
      default:
        return error.message.isNotEmpty
            ? error.message
            : 'خطأ في المصادقة';
    }
  }

  /// Validation error messages
  static String _getValidationErrorMessage(ValidationException error) {
    if (error.fieldErrors != null && error.fieldErrors!.isNotEmpty) {
      final firstError = error.fieldErrors!.values.first;
      if (firstError.isNotEmpty) {
        return firstError.first;
      }
    }

    return error.message.isNotEmpty
        ? error.message
        : 'خطأ في البيانات المدخلة';
  }

  /// Report to crash reporting service (placeholder)
  static void _reportToCrashlytics(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
  ) {
    // TODO: Implement crash reporting service integration
    // Example: FirebaseCrashlytics.instance.recordError(error, stackTrace);
    Logger.error('Would report to crashlytics: $error');
  }

  /// Handle specific error types with custom handling
  static void handleSpecificError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onNetworkError,
    VoidCallback? onAuthError,
    VoidCallback? onValidationError,
    VoidCallback? onGenericError,
  }) {
    if (error is NetworkException) {
      onNetworkError?.call();
    } else if (error is AuthException) {
      onAuthError?.call();
    } else if (error is ValidationException) {
      onValidationError?.call();
    } else {
      onGenericError?.call();
    }
  }
}