import 'package:flutter/material.dart';

class AppColorSettings {
  const AppColorSettings({
    required this.scaffoldBackground,
    required this.surface,
    required this.primaryText,
    required this.secondaryText,
    required this.accent,
    required this.border,
    required this.error,
    required this.success,
  });

  final Color scaffoldBackground;
  final Color surface;
  final Color primaryText;
  final Color secondaryText;
  final Color accent;
  final Color border;
  final Color error;
  final Color success;

  static const defaults = AppColorSettings(
    scaffoldBackground: Color(0xFF0A192F),
    surface: Color(0xFF112240),
    primaryText: Color(0xFFCCD6F6),
    secondaryText: Color(0xFF8892B0),
    accent: Color(0xFF64FFDA),
    border: Color(0xFF233554),
    error: Color(0xFFFF6B81),
    success: Color(0xFF64FFDA),
  );

  AppColorSettings copyWith({
    Color? scaffoldBackground,
    Color? surface,
    Color? primaryText,
    Color? secondaryText,
    Color? accent,
    Color? border,
    Color? error,
    Color? success,
  }) {
    return AppColorSettings(
      scaffoldBackground: scaffoldBackground ?? this.scaffoldBackground,
      surface: surface ?? this.surface,
      primaryText: primaryText ?? this.primaryText,
      secondaryText: secondaryText ?? this.secondaryText,
      accent: accent ?? this.accent,
      border: border ?? this.border,
      error: error ?? this.error,
      success: success ?? this.success,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'scaffoldBackground': _toHex(scaffoldBackground),
    'surface': _toHex(surface),
    'primaryText': _toHex(primaryText),
    'secondaryText': _toHex(secondaryText),
    'accent': _toHex(accent),
    'border': _toHex(border),
    'error': _toHex(error),
    'success': _toHex(success),
  };

  factory AppColorSettings.fromFirestore(Map<String, dynamic> data) {
    Color read(String key, Color fallback) {
      final value = data[key];
      if (value is! String) return fallback;
      return _fromHex(value) ?? fallback;
    }

    return AppColorSettings(
      scaffoldBackground: read(
        'scaffoldBackground',
        defaults.scaffoldBackground,
      ),
      surface: read('surface', defaults.surface),
      primaryText: read('primaryText', defaults.primaryText),
      secondaryText: read('secondaryText', defaults.secondaryText),
      accent: read('accent', defaults.accent),
      border: read('border', defaults.border),
      error: read('error', defaults.error),
      success: read('success', defaults.success),
    );
  }

  static String _toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  static Color? _fromHex(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;

    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;

    return normalized.length == 6 ? Color(0xFF000000 | parsed) : Color(parsed);
  }
}
