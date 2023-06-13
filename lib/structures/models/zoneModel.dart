import 'package:app/structures/enums/zoneStatus.dart';

class ZoneModel {
  late int number;
  String? name;
  bool isOpen = false;
  ZoneStatus status = ZoneStatus.normal;

  ZoneModel();

  ZoneModel.fromMap(Map map) {
    number = map['number'];
    name = map['name'];
    isOpen = map['isActive'];
    status = ZoneStatus.from(map['status']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['number'] = number;
    map['name'] = name;
    map['isActive'] = isOpen;
    map['status'] = status.getNumber();

    return map;
  }

  static List<ZoneModel> mapToList(dynamic data){
    if(data == null){
      return [];
    }

    return (data as List).map((e) => ZoneModel.fromMap(e)).toList();
  }
}
