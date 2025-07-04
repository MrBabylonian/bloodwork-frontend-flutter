import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Represents the available theme brightness modes in our application
enum AppThemeMode { light, dark }

/// Application theme class that provides consistent styling throughout the app.
///
/// This theme provider integrates our custom colors, text styles, and
/// dimensions into a cohesive system that follows Apple's Human Interface
/// Guidelines with a professional medical aesthetic.
class AppTheme extends ChangeNotifier {
  /// Current theme mode
  AppThemeMode _themeMode = AppThemeMode.light;

  /// Get current theme mode
  AppThemeMode get themeMode => _themeMode;

  /// Check if dark mode is active
  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  /// Toggle between light and dark theme modes
  void toggleThemeMode() {
    _themeMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    notifyListeners();
  }

  /// Set specific theme mode
  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Create light mode theme data
  ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.backgroundWhite,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryBlue,
      ).copyWith(
        primary: AppColors.primaryBlue,
        secondary: AppColors.primaryBlue,
        error: AppColors.destructiveRed,
        background: AppColors.backgroundWhite,
      ),
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.largeTitle,
        titleLarge: AppTextStyles.title2,
        titleMedium: AppTextStyles.title3,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.buttonPrimary,
      ),
      useMaterial3: true,
    );
  }

  /// Create dark mode theme data (placeholder - mirrors light for now)
  ThemeData get darkTheme => lightTheme.copyWith(brightness: Brightness.dark);

  /// Get current theme based on mode
  ThemeData get currentTheme => isDarkMode ? darkTheme : lightTheme;

  /// Static method to access theme from context
  static AppTheme of(BuildContext context) {
    return Provider.of<AppTheme>(context, listen: false);
  }

  /// Static method to access colors from context (currently static)
  static AppColors colors(BuildContext context) {
    // Currently returning static colors; could be mode-dependent in future
    return AppColors();
  }

  /// Static method to get standard page padding
  static EdgeInsets get pagePadding =>
      const EdgeInsets.all(AppDimensions.pagePadding);

  /// Static method to get standard content padding
  static EdgeInsets get contentPadding =>
      const EdgeInsets.all(AppDimensions.contentPadding);
}
