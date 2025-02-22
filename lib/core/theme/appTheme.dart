import 'package:flutter/material.dart';
import 'package:shakti/core/theme/kConstants.dart';

class Apptheme {
  static final ThemeData lightAppTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.themeColor,
      brightness: Brightness.light,
    ),
  );
  static final ThemeData darkAppTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.themeColor,
      brightness: Brightness.dark,
    ),
  );
}
