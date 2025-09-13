import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary colors based on the design specification
  static const Color primaryBackground = Color(0xFFF8F9FA); // #F8F9FA
  static const Color cardBackground = Color(0xFFFFFFFF); // #FFFFFF
  static const Color primaryColor = Color(0xFF6A5AE0); // #6A5AE0
  static const Color primaryText = Color(0xFF1A1A1A); // #1A1A1A
  static const Color secondaryText = Color(0xFF858585); // #858585
  static const Color inputBackground = Color(0xFFF0F0F0); // #F0F0F0
  
  // Additional colors for better UI
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Shadow color
  static const Color shadowColor = Color(0x0D000000); // rgba(0,0,0,0.05)
}

class AppTextStyles {
  // Font family - using Tajawal as specified in the design guide
  static const String fontFamily = 'Tajawal';
  
  // Main heading (H1) - 24px, Bold
  static TextStyle get h1 => GoogleFonts.tajawal(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );
  
  // Sub heading (H2) - 20px, Bold
  static TextStyle get h2 => GoogleFonts.tajawal(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  // Sub heading (H3) - 18px, Bold
  static TextStyle get h3 => GoogleFonts.tajawal(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );
  
  // Card title - 16px, Semi-bold
  static TextStyle get cardTitle => GoogleFonts.tajawal(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );
  
  // Body text - 14px, Regular
  static TextStyle get body => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
  );
  
  // Secondary body text
  static TextStyle get bodySecondary => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );
  
  // Small text - 12px, Regular
  static TextStyle get small => GoogleFonts.tajawal(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );
  
  // Button text
  static TextStyle get button => GoogleFonts.tajawal(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  
  // Pill button text
  static TextStyle get pill => GoogleFonts.tajawal(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

class AppTheme {
  // Backward compatibility with old theme system
  static Color get primaryColor => AppColors.primaryColor;
  static Color get secondaryColor => AppColors.primaryColor; // Using primary as secondary for now
  static Color get backgroundColor => AppColors.primaryBackground;
  static Color get errorColor => AppColors.error;
  static Color get successColor => AppColors.success;
  static Color get warningColor => AppColors.warning;
  static Color get infoColor => AppColors.info;
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppTextStyles.fontFamily,
      
      // Color scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryColor,
        brightness: Brightness.light,
        primary: AppColors.primaryColor,
        surface: AppColors.cardBackground,
        background: AppColors.primaryBackground,
      ),
      
      // Scaffold background
      scaffoldBackgroundColor: AppColors.primaryBackground,
      
      // Text theme
      textTheme: GoogleFonts.tajawalTextTheme(),
      
      // App bar theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.primaryText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.h2,
      ),
      
      // Card theme
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shadowColor: AppColors.shadowColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.white,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 0,
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        fillColor: AppColors.inputBackground,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: AppTextStyles.bodySecondary,
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primaryColor,
        unselectedItemColor: AppColors.secondaryText,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
  
  // Light theme only - dark theme removed as per requirements
  static ThemeData get theme => lightTheme;
}