import 'dart:async';

import 'package:app/structures/enums/appEvents.dart';
import 'package:iris_db/iris_db.dart';

import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:iris_notifier/iris_notifier.dart';

class PlaceManager {
  PlaceManager._();
  static List<PlaceModel> places = [];

  static Future<void> fetchPlaces(){
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

  static Future saveFavoritePlace(String placeId){
    return AppDB.setReplaceKv(Keys.selectedPlaceId, placeId);
  }

  static PlaceModel? fetchFavoritePlace(){
    var x = pickPlace(AppDB.fetchKv(Keys.selectedPlaceId));

    if(x == null && places.isNotEmpty){
      x = places.first;
    }

    return x;
  }

  static PlaceModel? pickPlace(String? placeId){
    return places.firstWhereSafe((p) => p.id == placeId);
  }

  static Future<int> updatePlaceToDb(PlaceModel place, {bool notify = true}){
    final res = AppDB.db.update(
        AppDB.tbPlaces,
        place.toMap(),
        Conditions().add(Condition()..key = 'id'..value = place.id)
    );

    if(notify){
      EventNotifierService.notify(AppEvents.placeDataChanged);
    }

    return res;
  }

  static Future<int> deletePlaceFromDb(PlaceModel place, {bool notify = true}){
    final res = AppDB.db.delete(
        AppDB.tbPlaces,
        Conditions().add(Condition()..key = 'id'..value = place.id)
    );

    if(notify){
      EventNotifierService.notify(AppEvents.placeDataChanged);
    }

    return res;
  }

  static void notifyPlaceChanged(){
    EventNotifierService.notify(AppEvents.placeDataChanged);
  }
}
