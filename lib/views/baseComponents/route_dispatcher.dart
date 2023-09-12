import 'package:flutter/material.dart';

import 'package:app/views/pages/home_page.dart';
import 'package:app/services/lock_service.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:showcaseview/showcaseview.dart';

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

    return ShowCaseWidget(
      builder: Builder(
          builder : (context) => const HomePage()
      ),
    );
  }
}
