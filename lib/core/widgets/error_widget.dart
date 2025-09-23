import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Error display widgets for different use cases
class ErrorDisplayWidget extends StatelessWidget {
  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final IconData? icon;
  final Color? iconColor;

  const ErrorDisplayWidget({
    Key? key,
    required this.message,
    this.title,
    this.onRetry,
    this.icon,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: iconColor ?? Colors.red[400],
            ),
            const SizedBox(height: 16),
            if (title != null) ...[
              Text(
                title!,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Network error widget
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const NetworkErrorWidget({
    Key? key,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'مشكلة في الاتصال',
      message: customMessage ?? 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
      icon: Icons.wifi_off,
      iconColor: Colors.orange[400],
      onRetry: onRetry,
    );
  }
}

/// No data found widget
class NoDataWidget extends StatelessWidget {
  final String message;
  final String? title;
  final IconData? icon;
  final VoidCallback? onRetry;

  const NoDataWidget({
    Key? key,
    required this.message,
    this.title,
    this.icon,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: title ?? 'لا توجد بيانات',
      message: message,
      icon: icon ?? Icons.inbox_outlined,
      iconColor: Colors.grey[400],
      onRetry: onRetry,
    );
  }
}

/// Server error widget
class ServerErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const ServerErrorWidget({
    Key? key,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'خطأ في الخادم',
      message: customMessage ?? 'حدث خطأ في الخادم، يرجى المحاولة لاحقاً',
      icon: Icons.dns_outlined,
      iconColor: Colors.red[400],
      onRetry: onRetry,
    );
  }
}

/// Authentication error widget
class AuthErrorWidget extends StatelessWidget {
  final VoidCallback? onLogin;
  final String? customMessage;

  const AuthErrorWidget({
    Key? key,
    this.onLogin,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline,
              size: 64,
              color: Colors.amber[600],
            ),
            const SizedBox(height: 16),
            Text(
              'تسجيل الدخول مطلوب',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.amber[700],
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              customMessage ?? 'يجب تسجيل الدخول للوصول لهذا المحتوى',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onLogin != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onLogin,
                icon: const Icon(Icons.login),
                label: const Text('تسجيل الدخول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Permission denied error widget
class PermissionErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final String? customMessage;

  const PermissionErrorWidget({
    Key? key,
    this.onRetry,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ErrorDisplayWidget(
      title: 'ليس لديك صلاحية',
      message: customMessage ?? 'ليس لديك صلاحية للوصول لهذا المحتوى',
      icon: Icons.block,
      iconColor: Colors.red[400],
      onRetry: onRetry,
    );
  }
}

/// Inline error widget for forms
class InlineErrorWidget extends StatelessWidget {
  final String message;
  final EdgeInsets? padding;

  const InlineErrorWidget({
    Key? key,
    required this.message,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[600],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Error snackbar helper
class ErrorSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
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
}

/// Success snackbar helper
class SuccessSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

/// Warning snackbar helper
class WarningSnackBar {
  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange[700],
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}