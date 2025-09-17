import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// مكون AppBar مخصص مع شعار رقيم أفقي
class RaqimAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final Color? logoColor;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;

  const RaqimAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
    this.logoColor,
    this.centerTitle = true,
    this.elevation = 0,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      elevation: elevation,
      centerTitle: centerTitle,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: titleColor ?? Colors.white,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // شعار رقيم
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: (logoColor ?? Colors.white).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: (logoColor ?? Colors.white).withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Text(
              AppConstants.appName, // 'رقيم'
              style: TextStyle(
                color: logoColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // فاصل
          Container(
            width: 1,
            height: 24,
            color: (titleColor ?? Colors.white).withValues(alpha: 0.3),
          ),
          const SizedBox(width: 12),
          // العنوان
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                color: titleColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'Cairo',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

/// AppBar بسيط مع شعار رقيم فقط
class SimpleRaqimAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? logoColor;
  final double elevation;

  const SimpleRaqimAppBar({
    super.key,
    this.actions,
    this.showBackButton = true,
    this.onBackPressed,
    this.backgroundColor,
    this.logoColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppColors.primaryColor,
      elevation: elevation,
      centerTitle: true,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: logoColor ?? Colors.white,
              ),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : null,
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: (logoColor ?? Colors.white).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (logoColor ?? Colors.white).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          AppConstants.appName, // 'رقيم'
          style: TextStyle(
            color: logoColor ?? Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Cairo',
          ),
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}