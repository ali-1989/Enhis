import 'package:flutter/material.dart';

import 'package:iris_tools/dateSection/calendarTools.dart';

import 'package:app/managers/font_manager.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/dateTools.dart';

class SettingsModel {
  static const defaultHttpAddress = 'http://vosatezehn.com:7436';
  static const Locale defaultAppLocale = Locale('fa', 'IR');
  static const CalendarType defaultCalendarType = CalendarType.solarHijri;
  static final defaultDateFormat = DateFormat.yyyyMmDd.format();

  String? lastUserId;
  Locale appLocale = defaultAppLocale;
  CalendarType calendarType = defaultCalendarType;
  String dateFormat = defaultDateFormat;
  String? colorTheme;
  String? lastToBackgroundTs;
  String httpAddress = defaultHttpAddress;
  Orientation? appRotationState; // null: free
  int? currentVersion;
  bool askSndSmsEveryTime = true;
  bool unLockByBiometric = false;
  bool unLockByNumber = false;
  int? defaultSimSlot;
  String? appNumberLock;

  SettingsModel();

  SettingsModel.fromMap(Map map){
    final localeMap = map['app_locale'];

    if(localeMap != null){
      appLocale = Locale(localeMap[Keys.languageIso], localeMap[Keys.countryIso]);
    }

    lastUserId = map['last_user_id'];
    calendarType = CalendarTypeHelper.calendarTypeFrom(map['calendar_type_name']);
    dateFormat = map['date_format']?? defaultDateFormat;
    colorTheme = map[Keys.setting$colorThemeName];
    httpAddress = map['http_address']?? defaultHttpAddress;
    currentVersion = map[Keys.setting$currentVersion];
    {///-- SMS
      askSndSmsEveryTime = map[Keys.setting$askSendSmsEveryTime] ?? true;
      defaultSimSlot = map[Keys.setting$defaultSimSlot];
    }
    {///-- Lock
      //lockApp = map[Keys.setting$lockApp] ?? false;
      unLockByBiometric = map[Keys.setting$unLockByBiometric] ?? false;
      unLockByNumber = map[Keys.setting$unLockByNumber] ?? false;
      appNumberLock = map[Keys.setting$numberLock];
      lastToBackgroundTs = map[Keys.setting$toBackgroundTs];
    }

    _prepareSettings();
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    map['last_user_id'] = lastUserId;
    map['app_locale'] = {Keys.languageIso: appLocale.languageCode, Keys.countryIso: appLocale.countryCode};
    map['calendar_type_name'] = calendarType.name;
    map['date_format'] = dateFormat;
    map[Keys.setting$colorThemeName] = colorTheme;
    map[Keys.setting$currentVersion] = currentVersion;
    map['http_address'] = httpAddress;
    {///-- SMS
      map[Keys.setting$defaultSimSlot] = defaultSimSlot;
      map[Keys.setting$askSendSmsEveryTime] = askSndSmsEveryTime;
    }
    {///-- lock
      map[Keys.setting$unLockByBiometric] = unLockByBiometric;
      map[Keys.setting$unLockByNumber] = unLockByNumber;
      map[Keys.setting$numberLock] = appNumberLock;
      map[Keys.setting$toBackgroundTs] = lastToBackgroundTs;
    }

    return map;
  }

  void matchBy(SettingsModel other){
    lastUserId = other.lastUserId;
    appLocale = other.appLocale;
    calendarType = other.calendarType;
    dateFormat = other.dateFormat;
    colorTheme = other.colorTheme;
    httpAddress = other.httpAddress;
    {///--SMS
      askSndSmsEveryTime = other.askSndSmsEveryTime;
      defaultSimSlot = other.defaultSimSlot;
    }
    {///--lock
      unLockByBiometric = other.unLockByBiometric;
      unLockByNumber = other.unLockByNumber;
      appNumberLock = other.appNumberLock;
      lastToBackgroundTs = other.lastToBackgroundTs;
    }
  }

  void _prepareSettings() {
    colorTheme ??= AppThemes.instance.currentTheme.themeName;

    FontManager.fetchFontThemeData(appLocale.languageCode);

    if(AppThemes.instance.currentTheme.themeName != colorTheme) {
      for (var t in AppThemes.instance.themeList.entries) {
        if (t.key == colorTheme) {
          AppThemes.applyTheme(t.value);
          break;
        }
      }
    }
  }

  @override
  String toString(){
    return toMap().toString();
  }
}
