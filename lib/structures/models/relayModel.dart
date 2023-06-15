
class RelayModel {
  late int number;
  String? name;
  bool isActive = false;

  RelayModel();

  RelayModel.fromMap(Map map) {
    number = map['number'];
    name = map['name'];
    isActive = map['isActive'];
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['number'] = number;
    map['name'] = name;
    map['isActive'] = isActive;

    return map;
  }

  static List<RelayModel> mapToList(dynamic data){
    if(data == null){
      return [];
    }

    return (data as List).map((e) => RelayModel.fromMap(e)).toList();
  }
}
