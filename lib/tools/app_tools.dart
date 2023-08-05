import 'package:app/structures/models/pathDrawModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:app/structures/mixins/dateFieldMixin.dart';
import 'package:xml/xml.dart';

class AppTools {
  AppTools._();

  static void sortList(List<DateFieldMixin> list, bool isAsc){
    if(list.isEmpty){
      return;
    }

    int sorter(DateFieldMixin d1, DateFieldMixin d2){
      return DateHelper.compareDates(d1.date, d2.date, asc: isAsc);
    }

    list.sort(sorter);
  }

  static WidgetsBinding getAppWidgetsBinding() {
    return WidgetsBinding.instance;
  }

  /// 'assets/images/buttons.svg'
  static Future<List<PathDrawModel>> loadSvgImage({required String svgImage}) async {
    List<PathDrawModel> res = [];
    String generalString = await rootBundle.loadString(svgImage);
    final document = XmlDocument.parse(generalString);

    final paths = document.findAllElements('path');

    for (final element in paths) {
      String partId = element.getAttribute('id').toString();
      String partPath = element.getAttribute('d').toString();
      //String color = element.getAttribute('fill').toString();
      Color c = AppDecoration.mainColor;

      res.add(PathDrawModel(id: partId, path: partPath, color: c));
    }

    return res;
  }
}

