
import 'package:app/structures/enums/relayStatus.dart';

class RelayModel {
  late int number;
  String? name;
  bool isActive = false;
  RelayStatus status = RelayStatus.dingDang;

  RelayModel();

  RelayModel.fromMap(Map map) {
    number = map['number'];
    name = map['name'];
    isActive = map['isActive'];
    status = RelayStatus.from(map['status']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['number'] = number;
    map['name'] = name;
    map['isActive'] = isActive;
    map['status'] = status.getNumber();

    return map;
  }

  static List<RelayModel> mapToList(dynamic data){
    if(data == null){
      return [];
    }

    return (data as List).map((e) => RelayModel.fromMap(e)).toList();
  }

  String getName(){
    final post = name != null && name!.isNotEmpty ? '($name)' : '';

    return 'رله $number $post';
  }
}
