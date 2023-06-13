import 'package:flutter/material.dart';

import 'package:app/pages/home_page.dart';

class RouteDispatcher {
  RouteDispatcher._();

  static Widget dispatch(){

    return HomePage();
  }
}
