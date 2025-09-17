import 'package:flutter/material.dart';

class ResponsiveText {
  static double getResponsiveFontSize(BuildContext context, {
    required double desktop,
    required double tablet,
    required double mobile,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1200) {
      return desktop;
    } else if (screenWidth > 768) {
      return tablet;
    } else {
      return mobile;
    }
  }

  static double h1(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 32,
      tablet: 28,
      mobile: 24,
    );
  }

  static double h2(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 28,
      tablet: 24,
      mobile: 20,
    );
  }

  static double h3(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 24,
      tablet: 20,
      mobile: 18,
    );
  }

  static double h4(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 20,
      tablet: 18,
      mobile: 16,
    );
  }

  static double h5(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 18,
      tablet: 16,
      mobile: 14,
    );
  }

  static double body(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 16,
      tablet: 15,
      mobile: 14,
    );
  }

  static double small(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 14,
      tablet: 13,
      mobile: 12,
    );
  }

  static double caption(BuildContext context) {
    return getResponsiveFontSize(
      context,
      desktop: 12,
      tablet: 11,
      mobile: 10,
    );
  }
}