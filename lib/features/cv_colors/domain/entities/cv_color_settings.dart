import 'package:flutter/material.dart';

class CvColorSettings {
  const CvColorSettings({
    required this.background,
    required this.white,
    required this.black,
    required this.dark2020,
    required this.dark2222,
    required this.dark2424,
    required this.dark2525,
    required this.dark3030,
    required this.dark3333,
    required this.gray5555,
    required this.gray6666,
    required this.gray7777,
    required this.accent,
  });

  final Color background;
  final Color white;
  final Color black;
  final Color dark2020;
  final Color dark2222;
  final Color dark2424;
  final Color dark2525;
  final Color dark3030;
  final Color dark3333;
  final Color gray5555;
  final Color gray6666;
  final Color gray7777;
  final Color accent;

  static const defaults = CvColorSettings(
    background: Color(0xFFF3F3F3),
    white: Color(0xFFFFFFFF),
    black: Color(0xFF000000),
    dark2020: Color(0xFF202020),
    dark2222: Color(0xFF222222),
    dark2424: Color(0xFF242424),
    dark2525: Color(0xFF252525),
    dark3030: Color(0xFF303030),
    dark3333: Color(0xFF333333),
    gray5555: Color(0xFF555555),
    gray6666: Color(0xFF666666),
    gray7777: Color(0xFF777777),
    accent: Color(0xFF165D9A),
  );

  CvColorSettings copyWith({
    Color? background,
    Color? white,
    Color? black,
    Color? dark2020,
    Color? dark2222,
    Color? dark2424,
    Color? dark2525,
    Color? dark3030,
    Color? dark3333,
    Color? gray5555,
    Color? gray6666,
    Color? gray7777,
    Color? accent,
  }) {
    return CvColorSettings(
      background: background ?? this.background,
      white: white ?? this.white,
      black: black ?? this.black,
      dark2020: dark2020 ?? this.dark2020,
      dark2222: dark2222 ?? this.dark2222,
      dark2424: dark2424 ?? this.dark2424,
      dark2525: dark2525 ?? this.dark2525,
      dark3030: dark3030 ?? this.dark3030,
      dark3333: dark3333 ?? this.dark3333,
      gray5555: gray5555 ?? this.gray5555,
      gray6666: gray6666 ?? this.gray6666,
      gray7777: gray7777 ?? this.gray7777,
      accent: accent ?? this.accent,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'background': _toHex(background),
        'white': _toHex(white),
        'black': _toHex(black),
        'dark2020': _toHex(dark2020),
        'dark2222': _toHex(dark2222),
        'dark2424': _toHex(dark2424),
        'dark2525': _toHex(dark2525),
        'dark3030': _toHex(dark3030),
        'dark3333': _toHex(dark3333),
        'gray5555': _toHex(gray5555),
        'gray6666': _toHex(gray6666),
        'gray7777': _toHex(gray7777),
        'accent': _toHex(accent),
      };

  factory CvColorSettings.fromFirestore(Map<String, dynamic> data) {
    Color read(String key, Color fallback) {
      final value = data[key];
      if (value is! String) return fallback;
      return _fromHex(value) ?? fallback;
    }

    return CvColorSettings(
      background: read('background', defaults.background),
      white: read('white', defaults.white),
      black: read('black', defaults.black),
      dark2020: read('dark2020', defaults.dark2020),
      dark2222: read('dark2222', defaults.dark2222),
      dark2424: read('dark2424', defaults.dark2424),
      dark2525: read('dark2525', defaults.dark2525),
      dark3030: read('dark3030', defaults.dark3030),
      dark3333: read('dark3333', defaults.dark3333),
      gray5555: read('gray5555', defaults.gray5555),
      gray6666: read('gray6666', defaults.gray6666),
      gray7777: read('gray7777', defaults.gray7777),
      accent: read('accent', defaults.accent),
    );
  }

  static String _toHex(Color color) =>
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  static Color? _fromHex(String value) {
    final normalized = value.trim().replaceFirst('#', '');
    if (normalized.length != 6 && normalized.length != 8) return null;
    final parsed = int.tryParse(normalized, radix: 16);
    if (parsed == null) return null;
    return normalized.length == 6 ? Color(0xFF000000 | parsed) : Color(parsed);
  }
}

class CvColorsScope extends InheritedWidget {
  const CvColorsScope({required this.colors, required super.child, super.key});

  final CvColorSettings colors;

  static CvColorSettings of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CvColorsScope>()!.colors;

  @override
  bool updateShouldNotify(CvColorsScope oldWidget) => colors != oldWidget.colors;
}
