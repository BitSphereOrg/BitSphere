import 'package:flutter/material.dart';
import 'colors.dart';

ThemeData buildTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentYellow,
      background: AppColors.primaryBackground,
      surface: AppColors.secondaryBackground,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.primaryText),
      bodyMedium: TextStyle(color: AppColors.secondaryText),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryBackground,
      foregroundColor: AppColors.primaryText,
    ),
    scaffoldBackgroundColor: AppColors.primaryBackground,
  );
}
