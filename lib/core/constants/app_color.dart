import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Indigo/Blue
  static const Color primary = Color(0xFF3F51B5); // Indigo
  static const Color primaryLight = Color(0xFF6573C3); // Lighter indigo
  static const Color primaryDark = Color(0xFF2C387E); // Darker indigo

  // Accent Colors - Amber/Orange
  static const Color accent = Color(0xFFFFA000); // Amber
  static const Color accentLight = Color(0xFFFFB74D); // Light amber
  static const Color accentDark = Color(0xFFEF6C00); // Dark orange

  // Light Theme Background Colors
  static const Color background = Color(0xFFFDFDFD); // Off-white
  static const Color backgroundSecondary = Color(0xFFF2F2F2); // Soft gray
  static const Color surface = Color(0xFFFFFFFF); // White for cards/surfaces

  // Light Theme Text Colors - WCAG Compliant
  static const Color textPrimary = Color(0xFF212121); // Almost black
  static const Color textSecondary = Color(0xFF616161); // Medium gray
  static const Color textTertiary = Color(0xFF9E9E9E); // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color textOnAccent = Color(0xFF000000); // Black on accent

  // Dark Theme Background Colors
  static const Color darkBackground = Color(0xFF0F0F0F); // Near black
  static const Color darkBackgroundSecondary = Color(0xFF1A1A1A); // Dark gray
  static const Color darkSurface = Color(0xFF1E1E1E); // Card dark surface
  static const Color darkSurfaceVariant = Color(0xFF2A2A2A); // Variant dark

  // Dark Theme Text Colors - WCAG Compliant
  static const Color darkTextPrimary = Color(0xFFECECEC); // Light gray
  static const Color darkTextSecondary = Color(0xFFB0B0B0); // Mid gray
  static const Color darkTextTertiary = Color(0xFF8C8C8C); // Dim gray
  static const Color darkTextOnPrimary = Color(0xFFFFFFFF); // White on primary
  static const Color darkTextOnSurface = Color(0xFFECECEC); // Light on surface

  // Status Colors (work for both themes)
  static const Color success = Color(0xFF43A047); // Green
  static const Color warning = Color(0xFFFFA726); // Orange
  static const Color error = Color(0xFFE53935); // Red
  static const Color info = Color(0xFF1E88E5); // Blue

  // Dark Theme Status Colors (enhanced contrast)
  static const Color darkSuccess = Color(0xFF66BB6A); // Lighter green
  static const Color darkWarning = Color(0xFFFFB74D); // Lighter orange
  static const Color darkError = Color(0xFFEF5350); // Lighter red
  static const Color darkInfo = Color(0xFF42A5F5); // Lighter blue

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);

  // Light Theme Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, accentLight],
  );

  // Dark Theme Gradient Colors
  static const LinearGradient darkPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  static const LinearGradient darkAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentDark, accent],
  );

  static const LinearGradient darkSurfaceGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkSurfaceVariant],
  );
}

// class AppColors {
//   // Primary Colors - Deep Slate/Blue
//   static const Color primary = Color(0xFF2C3E50); // Deep slate blue
//   static const Color primaryLight = Color(0xFF34495E); // Lighter slate
//   static const Color primaryDark = Color(0xFF1A252F); // Darker slate

//   // Accent Colors - Teal
//   static const Color accent = Color(0xFF16A085); // Teal
//   static const Color accentLight = Color(0xFF1ABC9C); // Light teal
//   static const Color accentDark = Color(0xFF138D75); // Dark teal

//   // Light Theme Background Colors
//   static const Color background = Color(0xFFF8F9FA); // Light gray/off-white
//   static const Color backgroundSecondary = Color(
//     0xFFE9ECEF,
//   ); // Slightly darker gray
//   static const Color surface = Color(
//     0xFFFFFFFF,
//   ); // Pure white for cards/surfaces

//   // Light Theme Text Colors - WCAG Compliant
//   static const Color textPrimary = Color(
//     0xFF2C3E50,
//   ); // Dark slate for primary text
//   static const Color textSecondary = Color(
//     0xFF6C757D,
//   ); // Medium gray for secondary text
//   static const Color textTertiary = Color(
//     0xFFADB5BD,
//   ); // Light gray for tertiary text
//   static const Color textOnPrimary = Color(
//     0xFFFFFFFF,
//   ); // White text on primary background
//   static const Color textOnAccent = Color(
//     0xFFFFFFFF,
//   ); // White text on accent background

//   // Dark Theme Background Colors
//   static const Color darkBackground = Color(
//     0xFF121212,
//   ); // Material Design dark background
//   static const Color darkBackgroundSecondary = Color(
//     0xFF1E1E1E,
//   ); // Slightly lighter dark
//   static const Color darkSurface = Color(0xFF1F1F1F); // Dark surface for cards
//   static const Color darkSurfaceVariant = Color(
//     0xFF2D2D2D,
//   ); // Variant dark surface

//   // Dark Theme Text Colors - WCAG Compliant
//   static const Color darkTextPrimary = Color(
//     0xFFE1E1E1,
//   ); // Light gray for primary text
//   static const Color darkTextSecondary = Color(
//     0xFFB3B3B3,
//   ); // Medium gray for secondary text
//   static const Color darkTextTertiary = Color(
//     0xFF8A8A8A,
//   ); // Darker gray for tertiary text
//   static const Color darkTextOnPrimary = Color(
//     0xFFFFFFFF,
//   ); // White text on primary background
//   static const Color darkTextOnSurface = Color(
//     0xFFE1E1E1,
//   ); // Light text on dark surface

//   // Status Colors (work for both themes)
//   static const Color success = Color(0xFF4CAF50); // Material Green
//   static const Color warning = Color(0xFFFF9800); // Material Orange
//   static const Color error = Color(0xFFF44336); // Material Red
//   static const Color info = Color(0xFF2196F3); // Material Blue

//   // Dark Theme Status Colors (enhanced contrast)
//   static const Color darkSuccess = Color(
//     0xFF66BB6A,
//   ); // Lighter green for dark theme
//   static const Color darkWarning = Color(
//     0xFFFFB74D,
//   ); // Lighter orange for dark theme
//   static const Color darkError = Color(
//     0xFFEF5350,
//   ); // Lighter red for dark theme
//   static const Color darkInfo = Color(
//     0xFF42A5F5,
//   ); // Lighter blue for dark theme

//   // Neutral Colors
//   static const Color black = Color(0xFF000000);
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color transparent = Color(0x00000000);

//   // Light Theme Gradient Colors
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primary, primaryLight],
//   );

//   static const LinearGradient accentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [accent, accentLight],
//   );

//   // Dark Theme Gradient Colors
//   static const LinearGradient darkPrimaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primaryDark, primary],
//   );

//   static const LinearGradient darkAccentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [accentDark, accent],
//   );

//   static const LinearGradient darkSurfaceGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [darkSurface, darkSurfaceVariant],
//   );
// }

// class AppColors {
//   // Primary Colors - Sky Blue
//   static const Color primary = Color(0xFF0288D1); // Sky blue
//   static const Color primaryLight = Color(0xFF4FC3F7); // Light sky blue
//   static const Color primaryDark = Color(0xFF01579B); // Dark navy blue

//   // Accent Colors - Mint Green
//   static const Color accent = Color(0xFF26A69A); // Mint green
//   static const Color accentLight = Color(0xFF80CBC4); // Light mint
//   static const Color accentDark = Color(0xFF00897B); // Dark teal green

//   // Light Theme Background Colors
//   static const Color background = Color(0xFFF9FAFB); // Almost white
//   static const Color backgroundSecondary = Color(0xFFEFF1F3); // Soft gray
//   static const Color surface = Color(0xFFFFFFFF); // White for cards/surfaces

//   // Light Theme Text Colors - WCAG Compliant
//   static const Color textPrimary = Color(0xFF1E293B); // Dark navy-gray
//   static const Color textSecondary = Color(0xFF475569); // Muted gray
//   static const Color textTertiary = Color(0xFF94A3B8); // Light gray
//   static const Color textOnPrimary = Color(0xFFFFFFFF); // White on primary
//   static const Color textOnAccent = Color(0xFFFFFFFF); // White on accent

//   // Dark Theme Background Colors
//   static const Color darkBackground = Color(0xFF0D1117); // Github dark style
//   static const Color darkBackgroundSecondary = Color(0xFF161B22); // Darker gray
//   static const Color darkSurface = Color(0xFF1E242C); // Dark card surface
//   static const Color darkSurfaceVariant = Color(0xFF2C3440); // Variant dark

//   // Dark Theme Text Colors - WCAG Compliant
//   static const Color darkTextPrimary = Color(0xFFE6EDF3); // Light gray
//   static const Color darkTextSecondary = Color(0xFF9BA9B4); // Muted gray
//   static const Color darkTextTertiary = Color(0xFF6E7B87); // Dim gray
//   static const Color darkTextOnPrimary = Color(0xFFFFFFFF); // White on primary
//   static const Color darkTextOnSurface = Color(0xFFE6EDF3); // Light on surface

//   // Status Colors (work for both themes)
//   static const Color success = Color(0xFF2E7D32); // Green
//   static const Color warning = Color(0xFFF57C00); // Orange
//   static const Color error = Color(0xFFD32F2F); // Red
//   static const Color info = Color(0xFF1976D2); // Blue

//   // Dark Theme Status Colors (enhanced contrast)
//   static const Color darkSuccess = Color(0xFF4CAF50); // Lighter green
//   static const Color darkWarning = Color(0xFFFFA726); // Lighter orange
//   static const Color darkError = Color(0xFFEF5350); // Lighter red
//   static const Color darkInfo = Color(0xFF42A5F5); // Lighter blue

//   // Neutral Colors
//   static const Color black = Color(0xFF000000);
//   static const Color white = Color(0xFFFFFFFF);
//   static const Color transparent = Color(0x00000000);

//   // Light Theme Gradient Colors
//   static const LinearGradient primaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primary, primaryLight],
//   );

//   static const LinearGradient accentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [accent, accentLight],
//   );

//   // Dark Theme Gradient Colors
//   static const LinearGradient darkPrimaryGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [primaryDark, primary],
//   );

//   static const LinearGradient darkAccentGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [accentDark, accent],
//   );

//   static const LinearGradient darkSurfaceGradient = LinearGradient(
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//     colors: [darkSurface, darkSurfaceVariant],
//   );
// }
