import 'package:flutter/material.dart';

class TenantConfig {
  const TenantConfig({
    this.seedColor = Colors.blue,
    this.cornerRadius = 12.0,
    this.inputStyle = 'outlined',
    this.fontFamily = '',
    this.gymName = '',
    this.gymPhone = '',
    this.gymEmail = '',
    this.gymAddress = '',
    this.logoUrl = '',
    this.currency = '₹', // Default to Indian Rupee as requested
  });

  factory TenantConfig.fromJson(Map<String, dynamic> json) {
    Color parseColor(String hex) {
      if (hex.isEmpty) return Colors.blue;
      hex = hex.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.tryParse(hex, radix: 16) ?? 0xFF2196F3);
    }

    return TenantConfig(
      seedColor: parseColor(json['seed_color'] as String? ?? ''),
      cornerRadius: (json['corner_radius'] as num?)?.toDouble() ?? 12.0,
      inputStyle: json['input_style'] as String? ?? 'outlined',
      fontFamily: json['font_family'] as String? ?? '',
      gymName: json['gym_name'] as String? ?? '',
      gymPhone: json['gym_phone'] as String? ?? '',
      gymEmail: json['gym_email'] as String? ?? '',
      gymAddress: json['gym_address'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      currency: json['currency'] as String? ?? '₹',
    );
  }

  TenantConfig copyWith({
    Color? seedColor,
    double? cornerRadius,
    String? inputStyle,
    String? fontFamily,
    String? gymName,
    String? gymPhone,
    String? gymEmail,
    String? gymAddress,
    String? logoUrl,
    String? currency,
  }) {
    return TenantConfig(
      seedColor: seedColor ?? this.seedColor,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      inputStyle: inputStyle ?? this.inputStyle,
      fontFamily: fontFamily ?? this.fontFamily,
      gymName: gymName ?? this.gymName,
      gymPhone: gymPhone ?? this.gymPhone,
      gymEmail: gymEmail ?? this.gymEmail,
      gymAddress: gymAddress ?? this.gymAddress,
      logoUrl: logoUrl ?? this.logoUrl,
      currency: currency ?? this.currency,
    );
  }

  final Color seedColor;
  final double cornerRadius;
  final String inputStyle;
  final String fontFamily;
  final String gymName;
  final String gymPhone;
  final String gymEmail;
  final String gymAddress;
  final String logoUrl;
  final String currency;

  Map<String, dynamic> toJson() => {
        'seed_color': '#${(seedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        'corner_radius': cornerRadius,
        'input_style': inputStyle,
        'font_family': fontFamily,
        'gym_name': gymName,
        'gym_phone': gymPhone,
        'gym_email': gymEmail,
        'gym_address': gymAddress,
        'logo_url': logoUrl,
        'currency': currency,
      };
}
