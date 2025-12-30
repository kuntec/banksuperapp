import 'dart:convert';
import 'package:flutter/material.dart';

Map<String, dynamic> asStringKeyedMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;

  if (value is Map) {
    return value.map((k, v) {
      // Convert keys to String + normalize nested maps
      if (v is Map) {
        return MapEntry(k.toString(), asStringKeyedMap(v));
      }
      if (v is List) {
        return MapEntry(k.toString(),
            v.map((e) => e is Map ? asStringKeyedMap(e) : e).toList());
      }
      return MapEntry(k.toString(), v);
    });
  }

  return <String, dynamic>{};
}

Color _hexToColor(String hex) {
  final clean = hex.replaceAll('#', '');
  final value = int.parse(clean.length == 6 ? 'FF$clean' : clean, radix: 16);
  return Color(value);
}

class ThemeConfig {
  final int version;
  final Map<String, dynamic> light;
  final Map<String, dynamic> dark;

  ThemeConfig({required this.version, required this.light, required this.dark});

  factory ThemeConfig.fromJson(Map<String, dynamic> json) {
    return ThemeConfig(
      version: (json['version'] ?? 1) as int,
      light: asStringKeyedMap(json['light']),
      dark: asStringKeyedMap(json['dark']),
    );
  }

  static ThemeConfig fromRaw(String raw) {
    final decoded = jsonDecode(raw);
    return ThemeConfig.fromJson(asStringKeyedMap(decoded));
  }
}

ThemeData buildThemeFromConfig(dynamic rawCfg, {required bool isDark}) {
  // ✅ normalize at entry point
  final cfg = asStringKeyedMap(rawCfg);

  final colors = asStringKeyedMap(cfg['colors']);
  final typography = asStringKeyedMap(cfg['typography']);
  final shape = asStringKeyedMap(cfg['shape']);
  final components = asStringKeyedMap(cfg['components']);

  final radius = (shape['radius'] ?? 12).toDouble();
  final primary =
      _hexToColor(colors['primary'] ?? (isDark ? '#60A5FA' : '#2563EB'));
  final background =
      _hexToColor(colors['background'] ?? (isDark ? '#0B1220' : '#FFFFFF'));
  final surface =
      _hexToColor(colors['surface'] ?? (isDark ? '#111827' : '#FFFFFF'));
  final text = _hexToColor(colors['text'] ?? (isDark ? '#E5E7EB' : '#0F172A'));
  final error = _hexToColor(colors['error'] ?? '#EF4444');
  final border = _hexToColor(colors['border'] ?? '#E2E8F0');

  final titleSize = (typography['title_size'] ?? 20).toDouble();
  final bodySize = (typography['body_size'] ?? 14).toDouble();
  final fontFamily = (typography['font_family'] ?? 'Roboto').toString();

  final button = asStringKeyedMap(components['button']);
  final btnHeight = (button['height'] ?? 48).toDouble();
  final btnPaddingH = (button['padding_h'] ?? 16).toDouble();
  final btnElevation = (button['elevation'] ?? 0).toDouble();

  final input = asStringKeyedMap(components['input']);
  final inputHeight = (input['height'] ?? 48).toDouble();
  final inputBorderWidth = (input['border_width'] ?? 1).toDouble();

  final scheme = ColorScheme(
    brightness: isDark ? Brightness.dark : Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary:
        _hexToColor(colors['secondary'] ?? (isDark ? '#34D399' : '#10B981')),
    onSecondary: Colors.white,
    error: error,
    onError: Colors.white,
    surface: surface,
    onSurface: text,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: scheme.brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: background,
    fontFamily: fontFamily,
    textTheme: TextTheme(
      titleLarge: TextStyle(
          fontSize: titleSize, fontWeight: FontWeight.w700, color: text),
      bodyMedium: TextStyle(fontSize: bodySize, color: text),
    ),
  );

  return base.copyWith(
    dividerColor: border,
    inputDecorationTheme: InputDecorationTheme(
      constraints: BoxConstraints(minHeight: inputHeight),
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: border, width: inputBorderWidth),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: border, width: inputBorderWidth),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: primary, width: inputBorderWidth + 0.5),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: Size.fromHeight(btnHeight),
        padding: EdgeInsets.symmetric(horizontal: btnPaddingH),
        elevation: btnElevation,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    ),
  );
}
