import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Font family - using Tajawal as specified in the design guide
  static const String fontFamily = 'Tajawal';
  
  // Main heading (H1) - 24px, Bold
  static const TextStyle h1 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
  );
  
  // Sub heading (H2) - 20px, Bold
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
  );
  
  // Card title - 16px, Semi-bold
  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
  );
  
  // Body text - 14px, Regular
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
    fontFamily: fontFamily,
  );
  
  // Secondary body text
  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
  );
  
  // Small text - 12px, Regular
  static const TextStyle small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
    fontFamily: fontFamily,
  );
  
  // Button text
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    fontFamily: fontFamily,
  );
  
  // Pill button text
  static const TextStyle pill = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    fontFamily: fontFamily,
  );
}