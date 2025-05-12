import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';
import '../../gen/fonts.gen.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: ColorPallete.primaryColor,
  scaffoldBackgroundColor: ColorPallete.backgroundColor,
  colorScheme: const ColorScheme.dark(
    primary: ColorPallete.primaryColor,
    onPrimary: ColorPallete.white,
    secondary: ColorPallete.secondaryColor,
    onSecondary: ColorPallete.white,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.white,
    surface: ColorPallete.lightBackgroundColor,
    inversePrimary: ColorPallete.whiteSmoke,
    onSurface: ColorPallete.whiteSmoke,
    surfaceContainerHighest: ColorPallete.inputFilledColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorPallete.inputFilledColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.parlourRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.parlourRed),
    ),
    hintStyle: const TextStyle(color: ColorPallete.hintTextColor),
    labelStyle: const TextStyle(color: ColorPallete.whiteSmoke),
    floatingLabelStyle: const TextStyle(color: ColorPallete.primaryColor),
    errorStyle: const TextStyle(color: ColorPallete.parlourRed),
  ),
  iconTheme: const IconThemeData(size: 20, color: ColorPallete.primaryColor),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    displayMedium: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    displaySmall: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    headlineLarge: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    headlineMedium: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    headlineSmall: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    titleLarge: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    titleMedium: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    titleSmall: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    bodyLarge: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    bodyMedium: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    bodySmall: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    labelLarge: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    labelMedium: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
    labelSmall: TextStyle(color: ColorPallete.whiteSmoke, fontFamily: FontFamily.robotoRegular),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorPallete.backgroundColor,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: FontFamily.robotoRegular,
    ),
    iconTheme: IconThemeData(color: ColorPallete.primaryColor),
  ),
  cardTheme: CardTheme(
    color: ColorPallete.lightBackgroundColor,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: ColorPallete.secondaryColor,
    thickness: 1,
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: ColorPallete.primaryColor,
  scaffoldBackgroundColor: ColorPallete.whiteSmoke,
  colorScheme: const ColorScheme.light(
    primary: ColorPallete.primaryColor,
    onPrimary: ColorPallete.white,
    secondary: ColorPallete.secondaryColor,
    onSecondary: ColorPallete.white,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.white,
    surface: ColorPallete.white,
    inverseSurface: ColorPallete.borderColor,
    onSurface: ColorPallete.black,
    surfaceContainerHighest: ColorPallete.white,
    surfaceContainerLowest: ColorPallete.whiteSmoke,
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: ColorPallete.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.borderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.borderColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.primaryColor),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.parlourRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16.0),
      borderSide: const BorderSide(color: ColorPallete.parlourRed),
    ),
    hintStyle: const TextStyle(color: ColorPallete.hintTextColor),
    labelStyle: const TextStyle(color: ColorPallete.black),
    floatingLabelStyle: const TextStyle(color: ColorPallete.primaryColor),
    errorStyle: const TextStyle(color: ColorPallete.parlourRed),
  ),
  iconTheme: const IconThemeData(size: 20, color: ColorPallete.primaryColor),
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    displayMedium: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    displaySmall: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    headlineLarge: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    headlineMedium: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    headlineSmall: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    titleLarge: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    titleMedium: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    titleSmall: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    bodyLarge: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    bodyMedium: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    bodySmall: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    labelLarge: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    labelMedium: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
    labelSmall: TextStyle(color: ColorPallete.black, fontFamily: FontFamily.robotoRegular),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: ColorPallete.whiteSmoke,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: ColorPallete.black,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: FontFamily.robotoRegular,
    ),
    iconTheme: IconThemeData(color: ColorPallete.primaryColor),
  ),
  cardTheme: CardTheme(
    color: ColorPallete.white,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  dividerTheme: const DividerThemeData(
    color: ColorPallete.borderColor,
    thickness: 1,
  ),
);
