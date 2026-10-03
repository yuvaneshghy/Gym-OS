import 'package:flutter/material.dart';

/// Extension holding custom white-label tokens outside the standard Material color scheme.
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.successColor,
    required this.warningColor,
    required this.dangerColor,
    required this.infoColor,
    required this.cornerRadius,
  });

  final Color successColor;
  final Color warningColor;
  final Color dangerColor;
  final Color infoColor;
  final double cornerRadius;

  @override
  ThemeExtension<AppTokens> copyWith({
    Color? successColor,
    Color? warningColor,
    Color? dangerColor,
    Color? infoColor,
    double? cornerRadius,
  }) {
    return AppTokens(
      successColor: successColor ?? this.successColor,
      warningColor: warningColor ?? this.warningColor,
      dangerColor: dangerColor ?? this.dangerColor,
      infoColor: infoColor ?? this.infoColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
    );
  }

  @override
  ThemeExtension<AppTokens> lerp(ThemeExtension<AppTokens>? other, double t) {
    if (other is! AppTokens) {
      return this;
    }
    return AppTokens(
      successColor: Color.lerp(successColor, other.successColor, t) ?? successColor,
      warningColor: Color.lerp(warningColor, other.warningColor, t) ?? warningColor,
      dangerColor: Color.lerp(dangerColor, other.dangerColor, t) ?? dangerColor,
      infoColor: Color.lerp(infoColor, other.infoColor, t) ?? infoColor,
      cornerRadius: cornerRadius + (other.cornerRadius - cornerRadius) * t,
    );
  }
}

/// Helper extension to easily access tokens via `context.tokens`
extension AppTokensExtension on BuildContext {
  AppTokens get tokens => Theme.of(this).extension<AppTokens>()!;
}
