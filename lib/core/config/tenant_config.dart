import 'package:flutter/material.dart';

class TenantConfig {
  const TenantConfig({
    this.seedColor = Colors.blue,
    this.cornerRadius = 12.0,
    this.inputStyle = 'outlined',
    this.fontFamily = '',
  });

  final Color seedColor;
  final double cornerRadius;
  final String inputStyle;
  final String fontFamily;

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
    );
  }

  Map<String, dynamic> toJson() => {
        'seed_color': '#${(seedColor.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
        'corner_radius': cornerRadius,
        'input_style': inputStyle,
        'font_family': fontFamily,
      };
}
