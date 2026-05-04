import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // ==================== ESPAÇAMENTOS ====================
  static const EdgeInsets pagePadding = EdgeInsets.all(20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets formPadding = EdgeInsets.all(20);
  
  static const SizedBox spaceH4 = SizedBox(height: 4);
  static const SizedBox spaceH8 = SizedBox(height: 8);
  static const SizedBox spaceH12 = SizedBox(height: 12);
  static const SizedBox spaceH16 = SizedBox(height: 16);
  static const SizedBox spaceH20 = SizedBox(height: 20);
  static const SizedBox spaceH24 = SizedBox(height: 24);
  static const SizedBox spaceH32 = SizedBox(height: 32);
  
  static const SizedBox spaceW8 = SizedBox(width: 8);
  static const SizedBox spaceW12 = SizedBox(width: 12);
  static const SizedBox spaceW16 = SizedBox(width: 16);
  
  // ==================== TEXTOS ====================
  static const TextStyle headline1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle headline4 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textMedium,
  );
  
  static const TextStyle moneyPositive = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.success,
  );
  
  static const TextStyle moneyNegative = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  );
  
  static const TextStyle moneyNeutral = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  // ==================== BOTÕES ====================
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primaryTerracota,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 52),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ),
  );
  
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.lightTerracota,
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 48),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
    textStyle: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );
  
  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primaryTerracota,
  );
  
  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primaryTerracota,
    side: const BorderSide(color: AppColors.primaryTerracota),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
  
  // ==================== DECORAÇÕES ====================
  static BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.cardSand,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.shadow.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  static BoxDecoration infoContainerDecoration = BoxDecoration(
    color: AppColors.highlight,
    borderRadius: BorderRadius.circular(15),
    border: Border.all(color: AppColors.lightTerracota.withOpacity(0.3)),
  );
  
  static BoxDecoration errorContainerDecoration = BoxDecoration(
    color: AppColors.error.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.error.withOpacity(0.3)),
  );
  
  static BoxDecoration successContainerDecoration = BoxDecoration(
    color: AppColors.success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.success.withOpacity(0.3)),
  );
  
  // ==================== INPUTS ====================
  static InputDecorationTheme inputDecoration = InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surfaceSand,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderSand),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borderSand),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primaryTerracota, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    labelStyle: const TextStyle(color: AppColors.textMedium),
    hintStyle: TextStyle(color: AppColors.textLight),
    prefixIconColor: AppColors.primaryTerracota,
    suffixIconColor: AppColors.primaryTerracota,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}