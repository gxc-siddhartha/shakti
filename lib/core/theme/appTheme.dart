import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shakti/core/theme/kConstants.dart';

class Apptheme {
  static final ThemeData lightAppTheme = ThemeData(
    appBarTheme: AppBarTheme(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark, // This will make icons dark
      ),
    ),
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.themeColor,
      brightness: Brightness.light,
    ),
  );
  static final ThemeData darkAppTheme = ThemeData(
    appBarTheme: AppBarTheme(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light, // This will make icons dark
      ),
    ),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: KConstants.themeColor,
      brightness: Brightness.dark,
    ),
  );
}
