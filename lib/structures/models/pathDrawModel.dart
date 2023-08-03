import 'package:flutter/material.dart';

class PathDrawModel {
  String id = '';
  String path = '';
  late Color color;

  PathDrawModel({required this.id, required this.color, required this.path});

  PathDrawModel.fromMap(Map? map){
    if(map == null){
      return;
    }
  }

  Map<String, dynamic> toMap(){
    final map = <String, dynamic>{};

    //map['enableLights'] = enableLights;

    return map;
  }
}
