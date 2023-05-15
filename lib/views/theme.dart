import 'package:bassliner/views/bordered_button.dart';
import 'package:flutter/material.dart';

class BasslinerTheme {
  final Color whiteKeyColor;
  final Color blackKeyColor;
  final Color disabledWhiteKeyColor;
  final Color disabledBlackKeyColor;
  final Color backgroundColor;
  final Color selectionColor;
  final Color disabledSelectionColor;
  final List<Color> keyColors;
  final List<Color> disabledKeyColors;
  final BorderedButtonTheme borderedButtonTheme;
  final ToggleButtonTheme toggleButtonTheme;

  const BasslinerTheme({
    this.whiteKeyColor = const Color(0xFF999999),
    this.blackKeyColor = const Color(0xFF666666),
    this.disabledWhiteKeyColor = const Color(0xFF444444),
    this.disabledBlackKeyColor = const Color(0xFF333333),
    this.backgroundColor = const Color(0xFF333333),
    this.selectionColor = Colors.black,
    this.disabledSelectionColor = Colors.grey,
    this.keyColors = const [
      Color(0xFF999999),
      Color(0xFF666666),
      Color(0xFF999999),
      Color(0xFF666666),
      Color(0xFF999999),
      Color(0xFF999999),
      Color(0xFF666666),
      Color(0xFF999999),
      Color(0xFF666666),
      Color(0xFF999999),
      Color(0xFF666666),
      Color(0xFF999999),
    ],
    this.disabledKeyColors = const [
      Color(0xFF444444),
      Color(0xFF333333),
      Color(0xFF444444),
      Color(0xFF333333),
      Color(0xFF444444),
      Color(0xFF444444),
      Color(0xFF333333),
      Color(0xFF444444),
      Color(0xFF333333),
      Color(0xFF444444),
      Color(0xFF333333),
      Color(0xFF444444),
    ],
    this.borderedButtonTheme = const BorderedButtonTheme(
      textColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0x66666666),
    ),
    this.toggleButtonTheme = const ToggleButtonTheme(
      textColor: Color(0xFFFFFFFF),
      backgroundColor: Color(0x66666666),
      selectedTextColor: Color(0x66666666),
      selectedBackgroundColor: Color(0xFFFFFFFF),
    ),
  });

  static BasslinerTheme generateTheme(Color mainColor) {
    final hslColor = HSLColor.fromColor(mainColor);
    final selectionColor = hslColor.lightness >= 0.7 ? Colors.black : Colors.white;
    final disabledSelectionColor = selectionColor.withAlpha(20);
    //debugPrint('lightness ${hslColor.lightness}');

    final textColor = hslColor.withLightness(0.2).toColor();
    final borderColor = hslColor.withLightness(0.5).toColor();
    final whiteColor = hslColor.withLightness(0.5).toColor();
    final blackColor = hslColor.withLightness(0.4).toColor();
    final disabledWhiteColor = hslColor.withLightness(0.3).toColor();
    final disabledBlackColor = hslColor.withLightness(0.2).toColor();
    final backgroundColor = hslColor.withLightness(0.1).toColor();

    return BasslinerTheme(
      whiteKeyColor: whiteColor,
      blackKeyColor: blackColor,
      disabledWhiteKeyColor: disabledWhiteColor,
      disabledBlackKeyColor: disabledBlackColor,
      backgroundColor: backgroundColor,
      selectionColor: selectionColor,
      disabledSelectionColor: disabledSelectionColor,
      keyColors: [
        whiteColor,
        blackColor,
        whiteColor,
        blackColor,
        whiteColor,
        whiteColor,
        blackColor,
        whiteColor,
        blackColor,
        whiteColor,
        blackColor,
        whiteColor
      ],
      disabledKeyColors: [
        disabledWhiteColor,
        disabledBlackColor,
        disabledWhiteColor,
        disabledBlackColor,
        disabledWhiteColor,
        disabledWhiteColor,
        disabledBlackColor,
        disabledWhiteColor,
        disabledBlackColor,
        disabledWhiteColor,
        disabledBlackColor,
        disabledWhiteColor
      ],
      borderedButtonTheme: BorderedButtonTheme(
        textColor: textColor,
        backgroundColor: borderColor,
      ),
      toggleButtonTheme: ToggleButtonTheme(
        textColor: textColor,
        backgroundColor: borderColor,
        selectedTextColor: backgroundColor,
        selectedBackgroundColor: selectionColor,
      ),
    );
  }

  static BasslinerTheme currentTheme = BasslinerTheme.generateTheme(Colors.red);
}

extension ThemeExtension on ThemeData {
  BasslinerTheme get basslinerTheme => BasslinerTheme.currentTheme;

  set basslinerTheme(BasslinerTheme value) {
    BasslinerTheme.currentTheme = value;
  }
}
