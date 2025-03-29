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
    surface: ColorPallete.backgroundColor,
    onSurface: ColorPallete.whiteSmoke,
  ),
  iconTheme: const IconThemeData(size: 40, color: Colors.limeAccent),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    bodyMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    bodySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    titleLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    titleMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    titleSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    labelLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    labelMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    labelSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    displayLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    displayMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    displaySmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    headlineLarge: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    headlineMedium: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
    headlineSmall: TextStyle(
      color: ColorPallete.whiteSmoke,
      fontFamily: 'Roboto Regular',
    ),
  ),
);
