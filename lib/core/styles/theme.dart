import 'package:flutter/material.dart';
import 'package:glaze/core/styles/color_pallete.dart';

ThemeData theme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPallete.magenta,
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
    bodyLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    bodyMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    bodySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    titleLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    titleMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    titleSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    labelLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    labelMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    labelSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    displayLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    displayMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    displaySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    headlineLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    headlineMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
    headlineSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Hit and Run',
    ),
  ),
);
