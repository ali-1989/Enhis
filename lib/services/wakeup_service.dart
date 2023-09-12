import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:workmanager/workmanager.dart';

import 'package:app/system/constants.dart';
import 'package:app/main.dart';
import 'package:app/services/native_call_service.dart';

@pragma('vm:entry-point')
Future<bool> _callbackWorkManager(task, inputData) async {
  WidgetsFlutterBinding.ensureInitialized();
  await prepareDirectoriesAndLogger();
  NativeCallService.init();

  var isAppRun = false;

  try {
    isAppRun = (await NativeCallService.assistanceBridge!.invokeMethod('isAppRun')).$1;
  }
  catch (e) {/**/}

  if (isAppRun) {
    return true;
  }

  try {
    /*switch (task) {
      case Workmanager.iOSBackgroundTask:
        break;
    }*/

    /*int count = 0;
    Timer? t;
    Completer c = Completer();

    t = Timer.periodic(Duration(seconds: 20), (timer) {
      if(count < 5){
        count++;
        LogTools.logger.logToAll('@@@@@@@@@: wakeup (20sec): $count'); //todo.
      }
      else {
        t!.cancel();
        c.complete(null);
      }
    });

    await c.future;

    await FireBaseService.initializeApp();
    await FireBaseService.start();*/

    return true;
  }
  catch (e) {
    return false;
  }
}

@pragma('vm:entry-point')
void callbackWorkManager() {
  Workmanager().executeTask(_callbackWorkManager);
}
///============================================================================================
class WakeupService {
  WakeupService._();

  static void init() {
    if(kIsWeb){
      return;
    }

    Workmanager().initialize(
      callbackWorkManager,
      isInDebugMode: false,
    );

    Workmanager().registerPeriodicTask(
      'WorkManager-task-${Constants.appName}',
      'periodic-${Constants.appName}',
      frequency: const Duration(hours: 1),
      initialDelay: const Duration(milliseconds: 30),
      backoffPolicyDelay: const Duration(minutes: 5),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.linear,
      constraints: Constraints(
        networkType: NetworkType.not_required,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
    );
  }
}