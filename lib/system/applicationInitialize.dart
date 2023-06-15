import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/net/netManager.dart';
import 'package:iris_tools/net/trustSsl.dart';

import 'package:app/constants.dart';
import 'package:app/system/applicationLifeCycle.dart';
import 'package:app/system/tools.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appLocale.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/netListenerTools.dart';
import 'package:app/tools/routeTools.dart';

class ApplicationInitial {
  ApplicationInitial._();

  static bool _importantInit = false;
  static bool _callInSplashInit = false;
  static bool _isInitialOk = false;
  static bool _callLazyInit = false;
  static String errorInInit = '';

  static bool isInit() {
    return _isInitialOk;
  }

  static Future<bool> prepareDirectoriesAndLogger() async {
    if (_importantInit) {
      return true;
    }

    try {
      _importantInit = true;

      if (!kIsWeb) {
        await AppDirectories.prepareStoragePaths(Constants.appName);
        Tools.reporter = Reporter(AppDirectories.getAppFolderInExternalStorage(), 'report');
      }

      Tools.logger = Logger('${AppDirectories.getExternalTempDir()}/logs');

      return true;
    }
    catch (e){
      _importantInit = false;
      errorInInit = '$e\n\n${StackTrace.current}';
      log('$e\n\n${StackTrace.current}');
      return false;
    }
  }

  static Future<void> inSplashInit() async {
    if (_callInSplashInit) {
      return;
    }

    try {
      _callInSplashInit = true;

      await AppDB.init();
      AppThemes.initial();
      TrustSsl.acceptBadCertificate();
      await AppLocale.localeDelegate().getLocalization().setFallbackByLocale(const Locale('en', 'EE'));
      await DeviceInfoTools.prepareDeviceInfo();
      await DeviceInfoTools.prepareDeviceId();
      //AudioPlayerService.init();

      if (!kIsWeb) {
      }

      _isInitialOk = true;
    }
    catch (e){
      Tools.logger.logToAll('error in inSplashInit >> $e');
    }

    return;
  }

  static Future<void> inSplashInitWithContext(BuildContext context) async {
    RouteTools.prepareWebRoute();
    AppCache.screenBack = const AssetImage(AppImages.logoSplash);
    await precacheImage(AppCache.screenBack!, context);
  }

  static Future<void> appLazyInit() {
    final c = Completer<void>();

    if (!_callLazyInit) {
      Timer.periodic(const Duration(milliseconds: 50), (Timer timer) async {
        if (_isInitialOk) {
          timer.cancel();
          await _lazyInitCommands();
          c.complete();
        }
      });
    }
    else {
      c.complete();
    }

    return c.future;
  }

  static Future<void> _lazyInitCommands() async {
    if (_callLazyInit) {
      return;
    }

    try {
      _callLazyInit = true;

      /// net & websocket
      NetManager.addChangeListener(NetListenerTools.onNetListener);

      /// life cycle
      ApplicationLifeCycle.init();


      /// login & logoff
      //EventNotifierService.addListener(AppEvents.userLogin, LoginService.onLoginObservable);
      //EventNotifierService.addListener(AppEvents.userLogoff, LoginService.onLogoffObservable);

      /*if (System.isWeb()) {
        void onSizeCheng(oldW, oldH, newW, newH) {
          AppDialogIris.prepareDialogDecoration();
        }

        AppSizes.instance.addMetricListener(onSizeCheng);
      }*/

      //SystemParameterManager.requestParameters();

      if(RouteTools.materialContext != null) {
        //VersionManager.checkAppHasNewVersion(RouteTools.getBaseContext()!);
      }

    }
    catch (e){
      _callLazyInit = false;
      Tools.logger.logToAll('error in lazyInitCommands >> $e');
    }
  }
}
