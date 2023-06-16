import 'package:flutter/material.dart';

import 'package:app/tools/app/appThemes.dart';

class AppDecoration {
  AppDecoration._();

  static Color mainColor = const Color(0xff444893);
  static Color secondColor = const Color(0xffd9dcff);
  static Color differentColor = const Color(0xFF65422d);

  static Color get dropDownBackground {
    return AppThemes.instance.currentTheme.accentColor;
  }

  static Color get cardSectionsColor {
    return Colors.grey.shade300;
  }

  static InputDecoration get inputDecor {
    return const InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      disabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
    );
  }
}
