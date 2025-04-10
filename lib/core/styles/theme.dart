import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

import '../../gen/fonts.gen.dart';

ThemeData theme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPallete.primaryColor,
    onPrimary: ColorPallete.slateViolet,
    secondary: ColorPallete.secondaryColor,
    onSecondary: ColorPallete.strawberryGlaze,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.parlourRed,
    surface: ColorPallete.backgroundColor,
    onSurface: ColorPallete.whiteSmoke,
  ),
  iconTheme: const IconThemeData(size: 40, color: Colors.limeAccent),
  fontFamily: FontFamily.robotoRegular,
  fontFamilyFallback: const [FontFamily.robotoRegular, FontFamily.hitAndRun],
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodyMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displaySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{},
  ),
);

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPallete.primaryColor,
    onPrimary: ColorPallete.slateViolet,
    secondary: ColorPallete.secondaryColor,
    onSecondary: ColorPallete.strawberryGlaze,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.parlourRed,
    surface: ColorPallete.backgroundColor,
    onSurface: ColorPallete.whiteSmoke,
  ),
  iconTheme: const IconThemeData(size: 40, color: Colors.limeAccent),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodyMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    displaySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: FontFamily.robotoRegular,
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{},
  ),
);

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: ColorPallete.primaryColor,
    onPrimary: ColorPallete.slateViolet,
    secondary: ColorPallete.secondaryColor,
    onSecondary: ColorPallete.strawberryGlaze,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.parlourRed,
    surface: ColorPallete.whiteSmoke,
    onSurface: ColorPallete.backgroundColor,
  ),
  iconTheme: const IconThemeData(size: 40, color: Colors.black),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodyMedium: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    bodySmall: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleLarge: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleMedium: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    titleSmall: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelLarge: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelMedium: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    labelSmall: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayLarge: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    displayMedium: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    displaySmall: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineLarge: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineMedium: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
    headlineSmall: TextStyle(
      color: ColorPallete.backgroundColor,
      fontFamily: FontFamily.robotoRegular,
    ),
  ),
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{},
  ),
);
