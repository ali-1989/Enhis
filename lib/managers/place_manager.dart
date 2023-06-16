import 'dart:async';

import 'package:iris_db/iris_db.dart';

import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';

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

  static Future savePickedPlace(String placeId){
    return AppDB.setReplaceKv(Keys.selectedPlaceId, placeId);
  }

  static PlaceModel? pickPlace(String? placeId){
    return places.firstWhereSafe((p) => p.id == placeId);
  }

  static PlaceModel? fetchSavedPlace(){
    var x = pickPlace(AppDB.fetchKv(Keys.selectedPlaceId));

    if(x == null && places.isNotEmpty){
      x = places.first;
    }

    return x;
  }

  static Future<int> updatePlaceToDb(PlaceModel place){
    return AppDB.db.update(
        AppDB.tbPlaces,
        place.toMap(),
        Conditions().add(Condition()..key = 'id'..value = place.id)
    );
  }

  static Future<int> deletePlaceFromDb(PlaceModel place){
    return AppDB.db.delete(
        AppDB.tbPlaces,
        Conditions().add(Condition()..key = 'id'..value = place.id)
    );
  }
}
