import 'package:flutter/material.dart';
import 'package:glaze/styles/color_pallete.dart';

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
);
