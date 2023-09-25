import 'package:app/structures/enums/relay_status.dart';

class RelayModel {
  late int number;
  String? name;
  bool isActive = false;
  RelayStatus status = RelayStatus.shortCommand;
  Duration duration = const Duration(seconds: 30);

  //--------- local
  bool isInWaitingForSms = false;

  RelayModel();

  RelayModel.fromMap(Map map) {
    number = map['number'];
    name = map['name'];
    isActive = map['isActive']?? false;
    duration = Duration(seconds: map['duration']?? 30);
    status = RelayStatus.from(map['status']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['number'] = number;
    map['name'] = name;
    map['isActive'] = isActive;
    map['status'] = status.getNumber();
    map['duration'] = duration.inSeconds;

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
