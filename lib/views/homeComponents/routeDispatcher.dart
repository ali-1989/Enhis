import 'package:app/services/lock_service.dart';
import 'package:app/tools/app/appCache.dart';
import 'package:flutter/material.dart';

import 'package:app/pages/home_page.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){
    if(LockService.mustShowLockScreen()){
      if(AppCache.timeoutCache.addTimeout('lock', const Duration(seconds: 10))) {
        WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
          LockService.showLockScreen();
        });
      }
    }

    return const HomePage();
  }
}
