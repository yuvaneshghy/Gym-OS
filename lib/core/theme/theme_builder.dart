import 'package:flutter/material.dart';

import 'app_tokens.dart';

/// Builds the master ThemeData for the application based on tenant configuration.
ThemeData buildGymKitTheme({
  required Color seedColor,
  required double cornerRadius,
  required Brightness brightness,
  required String font,
  required String inputStyle, // 'outlined' or 'filled'
}) {
  final tokens = AppTokens(
    successColor: const Color(0xFF2E7D32),
    warningColor: const Color(0xFFED6C02),
    dangerColor: const Color(0xFFD32F2F),
    infoColor: const Color(0xFF0288D1),
    cornerRadius: cornerRadius,
  );

  final shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cornerRadius),
  );

  final inputBorder = inputStyle == 'outlined'
      ? OutlineInputBorder(borderRadius: BorderRadius.circular(cornerRadius))
      : UnderlineInputBorder(borderRadius: BorderRadius.circular(cornerRadius));

  return ThemeData(
    colorSchemeSeed: seedColor,
    brightness: brightness,
    useMaterial3: true,
    scaffoldBackgroundColor: brightness == Brightness.light ? const Color(0xFFF4F7FA) : null,
    fontFamily: font.isEmpty ? null : font,
    extensions: [tokens],
    cardTheme: CardThemeData(
      shape: shape,
      color: brightness == Brightness.light ? Colors.white : null,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: EdgeInsets.zero,
    ),
    dialogTheme: DialogThemeData(shape: shape),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(cornerRadius)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: shape,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: inputBorder,
      filled: inputStyle == 'filled',
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: shape,
      showCloseIcon: true,
    ),
  );
}
