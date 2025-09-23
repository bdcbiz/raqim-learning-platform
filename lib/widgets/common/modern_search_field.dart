import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../services/analytics/analytics_service_factory.dart';

class ModernSearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool enabled;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final TextStyle? textStyle;

  const ModernSearchField({
    super.key,
    this.hintText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTap: onTap,
        enabled: enabled,
        style: textStyle ?? AppTextStyles.body.copyWith(fontSize: 14),
        decoration: InputDecoration(
          hintText: hintText ?? 'ماذا تود أن تتعلم اليوم؟',
          hintStyle: AppTextStyles.bodySecondary.copyWith(fontSize: 14),
          prefixIcon: Icon(
            prefixIcon ?? Icons.search,
            color: AppColors.secondaryText,
          ),
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixIconTap,
                  icon: Icon(
                    suffixIcon,
                    color: AppColors.secondaryText,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}