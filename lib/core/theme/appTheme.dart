import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shakti/core/theme/kConstants.dart';

class Apptheme {
  static final ThemeData lightAppTheme = ThemeData(
    useMaterial3: false,
    scaffoldBackgroundColor: const Color(0xffF2F2F2),
    fontFamily: "Lato",
    appBarTheme: AppBarTheme(
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
      backgroundColor: Colors.white,
      titleTextStyle: TextStyle(
        fontFamily: "Lato",
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      surface: Colors.white,
      seedColor: KConstants.themeColor,
      brightness: Brightness.light,
    ),
  );
  static final ThemeData darkAppTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
