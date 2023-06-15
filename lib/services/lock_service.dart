import 'dart:async';

import 'package:app/managers/settings_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/number_lock_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_auth_invisible/auth_strings.dart';
import 'package:flutter_local_auth_invisible/flutter_local_auth_invisible.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

///*** Limit: some function need android SDK 23 (6)

enum LockException {
  others(1),
  notAvailable(2), // not set any secure (Pin, pattern, password,..)
  authInProgress(3), // two times requested auth
  notEnrolled(4); // if Biometric not set (finger not add)

  final int _number;

  const LockException(this._number);

  int getNumber(){
    return _number;
  }
}
///-----------------------------------------------------------------------------
class LockService {
  LockService._();

  static void init(){
    if(isLockActive()){
      EventNotifierService.addListener(AppEvents.appPause, _onPause);
      EventNotifierService.addListener(AppEvents.appDeAttach, _onDetach);
      EventNotifierService.addListener(AppEvents.appResume, _onResume);
    }
  }

  /// android SDK 23 (6)
  static Future<bool> hasBiometrics() async {
    return await LocalAuthentication.canCheckBiometrics; // hardware exist
  }

  static Future<bool> hasAnySecureLock() async {
    return await LocalAuthentication.isDeviceSupported(); // Exist any secure (Pin, pattern,...)
  }

  /// BiometricType.face
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    return LocalAuthentication.getAvailableBiometrics();
  }

  static Future<bool> isSetFinger() async {
    final res = Completer<bool>();

    LocalAuthentication.authenticate(
        localizedReason: ' ',
        biometricOnly: true,
      useErrorDialogs: false,
      sensitiveTransaction: false,
    ).catchError((e){
      if(!res.isCompleted) {
        res.complete(false);
      }

      return false;
    });

    Future.delayed(const Duration(milliseconds: 200), (){
      if(System.isAndroid()){
        stopAuthenticationAndroid().then((value){
          if(!res.isCompleted) {
            res.complete(true);
          }
        });
      }
      else {
        if(!res.isCompleted) {
          res.complete(true);
        }
      }
    });

    return res.future;
  }

  static Future<(bool, LockException?)> authenticate() async {
    LockException? exception;

    const android = AndroidAuthMessages(
      //biometricHint: '',
      //biometricNotRecognized: '',
      //biometricRequiredTitle: '',
      //biometricSuccess: '',
      //deviceCredentialsRequiredTitle: '',
      //deviceCredentialsSetupDescription: '',
      //signInTitle: ''
      goToSettingsButton: 'تنظیمات',
      cancelButton: 'لفو',
      goToSettingsDescription: 'وارد تنظیمات شوید و قفل بیومتریک را فعال کنید',
    );

    final x = await LocalAuthentication.authenticate(
        localizedReason: ' ',
        biometricOnly: true,
      useErrorDialogs: false,
      sensitiveTransaction: false,
      androidAuthStrings: android,

    ).catchError((e){
      if(e is PlatformException) {
        if(e.code == 'NotAvailable'){
          exception = LockException.notAvailable;
        }

        if(e.code == 'NotEnrolled'){
          exception = LockException.notEnrolled;
        }

        if(e.code == 'auth_in_progress'){
          exception = LockException.authInProgress;
        }
      }

      return false;
    });

    return (x, exception);
  }

  static Future<bool> stopAuthenticationAndroid() async {
    return await LocalAuthentication.stopAuthentication();
  }

  static void _onPause({data}) async {
    SettingsManager.localSettings.lastToBackgroundTs = DateHelper.getNowTimestamp();
    await SettingsManager.saveSettings();
  }

  static void _onDetach({data}) async {
    SettingsManager.localSettings.lastToBackgroundTs = DateHelper.getNowTimestamp();
    await SettingsManager.saveSettings();
  }

  static void _onResume({data}) async {
    if (mustShowLockScreen()) {
      showLockScreen();
    }
  }

  static bool isLockActive(){
    return SettingsManager.localSettings.unLockByNumber || SettingsManager.localSettings.unLockByBiometric;
  }

  static bool mustShowLockScreen(){
    if(!isLockActive()){
      return false;
    }

    final lastForegroundTs = SettingsManager.localSettings.lastToBackgroundTs;

    if (lastForegroundTs != null) {
      var lastForeground = DateHelper.tsToSystemDate(lastForegroundTs)!;
      lastForeground = lastForeground.add(const Duration(seconds: 30));

      if (lastForeground.isBefore(DateTime.now())) {
        return true;
      }
    }

    return false;
  }

  static void showLockScreen(){
    SettingsManager.localSettings.lastToBackgroundTs = null;
    SettingsManager.saveSettings();

    if(SettingsManager.localSettings.unLockByBiometric){
      authenticate().then((value) {
        RouteTools.popTopView();
      });
    }

    final page = NumberLockScreen(
      canBack: false,
      showAppBar: false,
      showFingerPrint: SettingsManager.localSettings.unLockByBiometric,
      correctPassword: SettingsManager.localSettings.appNumberLock,
      enterCodeDescription: 'لطفا رمز ورود را وارد کنید',
      onCorrectPassword: (p){
        RouteTools.popTopView();
      },
    );

    RouteTools.pushPage(RouteTools.getTopContext()!, page);
  }
}