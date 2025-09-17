import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_theme.dart';
import '../utils/responsive_text.dart';

class ResponsiveAppTextStyles {
  static TextStyle h1(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h1(context),
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle h2(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h2(context),
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle h3(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h3(context),
    fontWeight: FontWeight.bold,
    color: AppColors.primaryText,
  );

  static TextStyle h4(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h4(context),
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle h5(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h5(context),
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle title(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h4(context),
    fontWeight: FontWeight.w600,
    color: AppColors.primaryText,
  );

  static TextStyle subtitle(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.h5(context),
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
  );

  static TextStyle body(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.body(context),
    fontWeight: FontWeight.normal,
    color: AppColors.primaryText,
    height: 1.6,
  );

  static TextStyle bodySmall(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.small(context),
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
    height: 1.5,
  );

  static TextStyle caption(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.caption(context),
    fontWeight: FontWeight.normal,
    color: AppColors.secondaryText,
  );

  static TextStyle button(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.body(context),
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static TextStyle label(BuildContext context) => GoogleFonts.tajawal(
    fontSize: ResponsiveText.small(context),
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );
}