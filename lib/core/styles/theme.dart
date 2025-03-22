import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

ThemeData theme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPallete.blackPearl,
    onPrimary: ColorPallete.slateViolet,
    secondary: ColorPallete.parlourRed,
    onSecondary: ColorPallete.strawberryGlaze,
    error: ColorPallete.parlourRed,
    onError: ColorPallete.parlourRed,
    surface: ColorPallete.black,
    onSurface: ColorPallete.whiteSmoke,
  ),
  iconTheme: const IconThemeData(size: 40, color: Colors.limeAccent),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: ColorPallete.whiteSmoke),
    bodyMedium: TextStyle(color: ColorPallete.whiteSmoke),
    bodySmall: TextStyle(color: ColorPallete.whiteSmoke),
    titleLarge: TextStyle(color: ColorPallete.whiteSmoke),
    titleMedium: TextStyle(color: ColorPallete.whiteSmoke),
    titleSmall: TextStyle(color: ColorPallete.whiteSmoke),
    labelLarge: TextStyle(color: ColorPallete.whiteSmoke),
    labelMedium: TextStyle(color: ColorPallete.whiteSmoke),
    labelSmall: TextStyle(color: ColorPallete.whiteSmoke),
    displayLarge: TextStyle(color: ColorPallete.whiteSmoke),
    displayMedium: TextStyle(color: ColorPallete.whiteSmoke),
    displaySmall: TextStyle(color: ColorPallete.whiteSmoke),
    headlineLarge: TextStyle(color: ColorPallete.whiteSmoke),
    headlineMedium: TextStyle(color: ColorPallete.whiteSmoke),
    headlineSmall: TextStyle(color: ColorPallete.whiteSmoke),
  ),
);
