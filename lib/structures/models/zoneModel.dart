import 'package:app/structures/enums/zoneStatus.dart';

class ZoneModel {
  late int number;
  String? name;
  bool isOpen = false;
  bool show = true;
  ZoneStatus status = ZoneStatus.normal;

  ZoneModel();

  ZoneModel.fromMap(Map map) {
    number = map['number'];
    name = map['name'];
    isOpen = map['isOpen'];
    show = map['show'];
    status = ZoneStatus.from(map['status']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['number'] = number;
    map['name'] = name;
    map['isOpen'] = isOpen;
    map['show'] = show;
    map['status'] = status.getNumber();

    return map;
  }

  static List<ZoneModel> mapToList(dynamic data){
    if(data == null){
      return [];
    }

    return (data as List).map((e) => ZoneModel.fromMap(e)).toList();
  }

  String getName(){
    final post = name != null && name!.isNotEmpty ? '($name)' : '';

    return 'زون $number $post';
  }
}
