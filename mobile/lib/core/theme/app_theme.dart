import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_styles.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // Cores principais
    primaryColor: AppColors.primaryTerracota,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryTerracota,
      secondary: AppColors.lightTerracota,
      surface: AppColors.surfaceSand,
      error: AppColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: AppColors.textDark,
    ),
    
    // Fundo da tela
    scaffoldBackgroundColor: AppColors.backgroundSand,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: AppColors.primaryTerracota,
      foregroundColor: Colors.white,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    
    // Cards
    cardTheme: CardThemeData(
      color: AppColors.cardSand,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    
    // Inputs
    inputDecorationTheme: AppStyles.inputDecoration,
    
    // Botões
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppStyles.primaryButtonStyle,
    ),
    
    // Botões de texto
    textButtonTheme: TextButtonThemeData(
      style: AppStyles.textButtonStyle,
    ),
    
    // Divisores
    dividerTheme: DividerThemeData(
      color: AppColors.borderSand,
      thickness: 1,
    ),
    
    // SnackBar
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: AppColors.primaryTerracota,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    
    // Icones
    iconTheme: const IconThemeData(
      color: AppColors.primaryTerracota,
    ),
    
    // Dialog
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceSand,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    
    // Progress Indicator
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryTerracota,
    ),
  );
}