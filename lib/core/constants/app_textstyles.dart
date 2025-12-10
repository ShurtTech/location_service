import 'package:flutter/material.dart';
import 'package:location_tracking/core/constants/app_colours.dart';

class AppTextStyles {
  // Font Family - Change this to your preferred font
  static const String fontFamily = 'Roboto'; // or 'Poppins', 'Inter', etc.
  
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
    letterSpacing: -0.5,
  );
  
  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
    letterSpacing: -0.3,
  );
  
  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
    letterSpacing: -0.2,
  );
  
  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
    letterSpacing: -0.1,
  );
  
  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Body Text Styles
  static const TextStyle bodyBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodySemiBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle bodyRegular = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Body Variants
  static const TextStyle body2Bold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body2SemiBold = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body2Regular = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body3Bold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle body3Regular = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  // Caption & Small Text
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle captionBold = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle small = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle smallBold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Button Text Styles
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColours.whiteColour,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColours.whiteColour,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColours.whiteColour,
    fontFamily: fontFamily,
    letterSpacing: 0.3,
  );
  
  // Link & Underline Text
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColours.primaryColor,
    fontFamily: fontFamily,
    decoration: TextDecoration.underline,
  );
  
  static const TextStyle linkBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColours.primaryColor,
    fontFamily: fontFamily,
    decoration: TextDecoration.underline,
  );
  
  // Label Styles
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  // Input/Form Text Styles
  static const TextStyle inputText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColours.textPrimary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
  );
  
  static const TextStyle inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColours.textHint,
    fontFamily: fontFamily,
  );
  
  static const TextStyle inputError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColours.error,
    fontFamily: fontFamily,
  );
  
  // Overline Text
  static const TextStyle overline = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColours.textSecondary,
    fontFamily: fontFamily,
    letterSpacing: 1.5,
  );
  
  // Special Text Styles
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColours.primaryColor,
    fontFamily: fontFamily,
  );
  
  static const TextStyle badge = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.bold,
    color: AppColours.whiteColour,
    fontFamily: fontFamily,
    letterSpacing: 0.5,
  );
  
  // Helper Methods
  static TextStyle customStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14,
      fontWeight: fontWeight ?? FontWeight.normal,
      color: color ?? AppColours.textPrimary,
      fontFamily: fontFamily,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
    );
  }
}
