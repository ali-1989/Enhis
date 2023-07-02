import 'package:flutter/material.dart';

import 'package:app/tools/app/appThemes.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

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

  static TextStyle infoHeadLineTextStyle() {
    return AppThemes.instance.themeData.textTheme.headlineSmall!.copyWith(
      color: AppThemes.instance.themeData.textTheme.headlineSmall!.color!.withAlpha(150),
    );
  }

  static TextStyle infoTextStyle() {
    return AppThemes.instance.themeData.textTheme.headlineSmall!.copyWith(
      color: AppThemes.instance.themeData.textTheme.headlineSmall!.color!.withAlpha(150),
      fontSize: AppThemes.instance.themeData.textTheme.headlineSmall!.fontSize! -2,
      height: 1.5,
    );
    //return currentTheme.baseTextStyle.copyWith(color: currentTheme.infoTextColor);
  }

  static ButtonThemeData buttonTheme() {
    return AppThemes.instance.themeData.buttonTheme;
  }

  static TextStyle? buttonTextStyle() {
    return AppThemes.instance.themeData.textTheme.labelLarge;
    //return themeData.elevatedButtonTheme.style!.textStyle!.resolve({MaterialState.focused});
  }

  static Color? buttonTextColor() {
    return buttonTextStyle()?.color;
  }

  static Color? textButtonColor() {
    return AppThemes.instance.themeData.textButtonTheme.style!.foregroundColor!.resolve({MaterialState.selected});
  }

  static ThemeData dropdownTheme(BuildContext context, {Color? color}) {
    return AppThemes.instance.themeData.copyWith(
      canvasColor: color?? ColorHelper.changeHue(AppThemes.instance.currentTheme.accentColor),
    );
  }

  static TextStyle relativeSheetTextStyle() {
    final app = AppThemes.instance.themeData.appBarTheme.toolbarTextStyle!;
    final color = ColorHelper.getUnNearColor(/*app.color!*/Colors.white, AppThemes.instance.currentTheme.primaryColor, Colors.white);

    return app.copyWith(color: color, fontSize: 14);//currentTheme.appBarItemColor
  }

  static Text sheetText(String text) {
    return Text(
      text,
      style: relativeSheetTextStyle(),
    );
  }
  ///------------------------------------------------------------------
  static Color chipColor() {
    return checkPrimaryByWB(AppThemes.instance.currentTheme.primaryColor, AppThemes.instance.currentTheme.buttonBackColor);
  }

  static Color chipTextColor() {
    return ColorHelper.getUnNearColor(Colors.white, chipColor(), Colors.black);
  }

  static BoxDecoration dropdownDecoration({Color? color, double radius = 5}) {
    return BoxDecoration(
      color: color?? ColorHelper.changeHue(AppThemes.instance.currentTheme.accentColor),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static Color cardColorOnCard() {
    return ColorHelper.changeHSLByRelativeDarkLight(AppThemes.instance.currentTheme.cardColor, 2, 0.0, 0.04);
  }

  static TextStyle relativeFabTextStyle() {
    final app = AppThemes.instance.themeData.appBarTheme.toolbarTextStyle!;

    return app.copyWith(fontSize: app.fontSize! - 3, color: AppThemes.instance.currentTheme.fabItemColor);
  }

  static Color relativeBorderColor$outButton({bool onColored = false}) {
    if(ColorHelper.isNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[300]!])) {
      return AppThemes.instance.currentTheme.appBarItemColor;
    } else {
      return onColored? Colors.white : AppThemes.instance.currentTheme.primaryColor;
    }
  }

  static BorderSide relativeBorderSide$outButton({bool onColored = false}) {
    return BorderSide(width: 1.0, color: relativeBorderColor$outButton(onColored: onColored).withAlpha(140));
  }

  static InputDecoration textFieldInputDecoration({int alpha = 255}) {
    final border = OutlineInputBorder(
        borderSide: BorderSide(color: AppThemes.instance.currentTheme.textColor.withAlpha(alpha))
    );

    return InputDecoration(
      border: border,
      disabledBorder: border,
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
    );
  }

  static bool isDarkPrimary(){
    return ColorHelper.isNearColor(AppThemes.instance.currentTheme.primaryColor, Colors.grey[900]!);
  }

  static bool isLightPrimary(){
    return ColorHelper.isNearColor(AppThemes.instance.currentTheme.primaryColor, Colors.grey[200]!);
  }

  static Color checkPrimaryByWB(Color ifNotNear, Color ifNear){
    return ColorHelper.ifNearColors(AppThemes.instance.currentTheme.primaryColor, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
            ()=> ifNear, ()=> ifNotNear);
  }
}


/*


	static Color checkColorByWB(Color base, Color ifNotNear, Color ifNear){
		return ColorHelper.ifNearColors(base, [Colors.grey[900]!, Colors.grey[600]!, Colors.white],
				()=> ifNear, ()=> ifNotNear);
	}

 */