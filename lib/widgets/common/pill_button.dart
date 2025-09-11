import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class PillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;

  const PillButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isSelected = false,
    this.selectedColor,
    this.unselectedColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? (selectedColor ?? AppColors.primaryColor)
        : (unselectedColor ?? AppColors.cardBackground);
    
    final textColor = isSelected
        ? (selectedTextColor ?? AppColors.white)
        : (unselectedTextColor ?? AppColors.primaryText);

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
        border: isSelected ? null : Border.all(
          color: AppColors.inputBackground,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              text,
              style: AppTextStyles.pill.copyWith(color: textColor),
            ),
          ),
        ),
      ),
    );
  }
}