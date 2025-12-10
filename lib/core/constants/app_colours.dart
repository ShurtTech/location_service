import 'package:flutter/material.dart';

class AppColours {
  // Primary Colors
  static const Color primaryColor = Color(0xFF2196F3); // Blue
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFF64B5F6);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFFFF9800); // Orange
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFB74D);
  
  // Accent Colors
  static const Color accentColor = Color(0xFF4CAF50); // Green
  static const Color accentDark = Color(0xFF388E3C);
  static const Color accentLight = Color(0xFF81C784);
  
  // Basic Colors
  static const Color whiteColour = Color(0xFFFFFFFF);
  static const Color blackColour = Color(0xFF000000);
  
  // Grey Shades
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);
  static const Color greyBackground = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFF5F5F5);
  
  // Border Colors
  static const Color borderColor = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color borderDark = Color(0xFFBDBDBD);
  
  // Card Colors
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color cardShadow = Color(0x1F000000);
  
  // Transparent Colors
  static const Color transparent = Colors.transparent;
  
  // Custom App Colors
  static const Color attendance = Color(0xFF4CAF50);
  static const Color leave = Color(0xFFFF9800);
  static const Color absent = Color(0xFFF44336);
  static const Color holiday = Color(0xFF9C27B0);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondaryColor, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentColor, accentDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Additional Utility Colors
  static const Color divider = Color(0xFFBDBDBD);
  static const Color disabled = Color(0xFFE0E0E0);
  static const Color disabledText = Color(0xFF9E9E9E);
  
  // Dark Theme Colors (Optional)
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2C2C2C);
  
  // Helper method to get color with opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  // Helper method to convert hex to Color
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
