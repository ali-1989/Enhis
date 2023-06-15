import 'package:app/tools/app/appThemes.dart';
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static Color mainColor = const Color(0xff444893);
  static Color secondColor = const Color(0xffd9dcff);
  static Color differentColor = const Color(0xFF65422d);

  static Color get dropDownBackground {
    return AppThemes.instance.currentTheme.accentColor;
  }
}