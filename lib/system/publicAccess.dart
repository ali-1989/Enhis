import 'dart:async';

import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:flutter/material.dart';

import 'package:dio/dio.dart';
import 'package:iris_db/iris_db.dart';
import 'package:iris_tools/api/helpers/jsonHelper.dart';
import 'package:iris_tools/api/logger/logger.dart';
import 'package:iris_tools/api/logger/reporter.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/models/twoStateReturn.dart';

import 'package:app/constants.dart';
import 'package:app/managers/settingsManager.dart';
import 'package:app/services/session_service.dart';
import 'package:app/structures/middleWares/requester.dart';
import 'package:app/structures/mixins/dateFieldMixin.dart';
import 'package:app/structures/models/userModel.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/deviceInfoTools.dart';
import 'package:app/tools/routeTools.dart';

class PublicAccess {
  PublicAccess._();

  static late Logger logger;
  static late Reporter reporter;
  static String graphApi = '${SettingsManager.settingsModel.httpAddress}/graph-v1';
  static List<PlaceModel> places = [];

  static Future fetchPlaces(){
    final list = AppDB.db.query(AppDB.tbPlaces, Conditions());

    if(list.isNotEmpty) {
      places.clear();

      for (final row in list) {
        final itm = PlaceModel.fromMap(row);
        places.add(itm);
      }
    }

    return Future.value();
  }

  static Future savePickedPlace(String placeId){
    return AppDB.setReplaceKv(Keys.selectedPlaceId, placeId);
  }

  static PlaceModel? pickPlace(String? placeId){
    return places.firstWhereSafe((p) => p.id == placeId);
  }

  static PlaceModel? pickSavedPlace(){
    return pickPlace(AppDB.fetchKv(Keys.selectedPlaceId));
  }

  static Map addLanguageIso(Map src, [BuildContext? ctx]) {
    src[Keys.languageIso] = System.getLocalizationsLanguageCode(ctx ?? RouteTools.getTopContext()!);

    return src;
  }

  static Map addAppInfo(Map src, {UserModel? curUser}) {
    final token = curUser?.token ?? SessionService.getLastLoginUser()?.token;

    src.addAll(getAppInfo());

    if (token?.token != null) {
      src[Keys.token] = token?.token;
    }

    return src;
  }

  static Map<String, dynamic> getAppInfo() {
    final res = <String, dynamic>{};
    res[Keys.deviceId] = DeviceInfoTools.deviceId;
    res[Keys.appName] = Constants.appName;
    res['app_version_code'] = Constants.appVersionCode;
    res['app_version_name'] = Constants.appVersionName;

    return res;
  }

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static Future<TwoStateReturn<Map, Response>> publicApiCaller(String url, MethodType methodType, Map<String, dynamic>? body){
    Requester requester = Requester();
    Completer<TwoStateReturn<Map, Response>> res = Completer();

    requester.httpRequestEvents.onFailState = (req, response) async {
      res.complete(TwoStateReturn(r2: response));
    };

    requester.httpRequestEvents.onStatusOk = (req, data) async {
      final js = JsonHelper.jsonToMap(data)!;

      res.complete(TwoStateReturn(r1: js));
    };

    if(body != null){
      requester.bodyJson = body;
    }

    requester.prepareUrl(pathUrl: url);
    requester.methodType = methodType;

    requester.request(null, false);
    return res.future;
  }
  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  static Map<String, dynamic> getHeartMap() {
    final heart = <String, dynamic>{};
    heart['heart'] = 'heart';
    heart['app_name'] = Constants.appName;
    heart['app_version_code'] = Constants.appVersionCode;
    heart['app_version_name'] = Constants.appVersionName;
    heart[Keys.deviceId] = DeviceInfoTools.deviceId;

    if(RouteTools.materialContext != null) {
      heart[Keys.languageIso] = System.getLocalizationsLanguageCode(RouteTools.getTopContext()!);
    }
    else {
      heart[Keys.languageIso] = SettingsManager.settingsModel.appLocale.languageCode;
    }

    final users = [];

    for(var um in SessionService.currentLoginList) {
      users.add(um.userId);
    }

    heart['users'] = users;

    return heart;
  }
}

