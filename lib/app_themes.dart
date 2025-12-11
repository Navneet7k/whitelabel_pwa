import 'package:flutter/material.dart';

class AppThemes {
  static final light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
  );

  static final green = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    useMaterial3: true,
  );

  static final orange = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    useMaterial3: true,
  );

  static final grey = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
    useMaterial3: true,
  );

  static final white = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
    useMaterial3: true,
  );

  static final all = [light, green, orange, grey,white];

  static ThemeData fromHex(String hexColor) {
    final color = _hexToColor(hexColor);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: color),
      useMaterial3: true,
    );
  }

  static Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex'; // add full opacity if not specified
    return Color(int.parse(hex, radix: 16));
  }

  static Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
