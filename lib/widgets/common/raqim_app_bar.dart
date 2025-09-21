import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';

class RaqimAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool centerTitle;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final bool showLogo;

  const RaqimAppBar({
    super.key,
    this.title,
    this.actions,
    this.centerTitle = true,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.showLogo = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.primaryText,
              ),
              overflow: TextOverflow.ellipsis,
            )
          : null,
      centerTitle: true,
      actions: actions,
      leading: leading ?? (showLogo
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: SvgPicture.asset(
                'assets/images/raqimLogo.svg',
                height: 32,
                fit: BoxFit.contain,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            )
          : null),
      elevation: elevation,
      backgroundColor: backgroundColor ?? AppColors.white,
      surfaceTintColor: AppColors.white,
      shadowColor: Colors.black.withOpacity(0.1),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}