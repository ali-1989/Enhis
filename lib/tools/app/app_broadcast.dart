import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:app/tools/app/app_themes.dart';

class AppBroadcast {
  AppBroadcast._();

  static final StreamController<bool> viewUpdaterStream = StreamController<bool>();

  //---------------------- keys
  static LocalKey materialAppKey = UniqueKey();
  static final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static final rootNavigatorKey = GlobalKey<NavigatorState>();

  //---------------------- status
  static bool isNetConnected = true;
  static bool isWsConnected = false;


  /// this call build() method of all widgets
  /// this is effect on First Widgets tree, not rebuild Pushed pages
  static void reBuildAppBySetTheme() {
    AppThemes.applyTheme(AppThemes.instance.currentTheme);
    reBuildApp();
  }

  static void reBuildApp() {
    if(kIsWeb){
      materialAppKey = UniqueKey();
    }

    viewUpdaterStream.sink.add(true);
  }
}
