
import 'package:app/structures/enums/contactLevel.dart';
import 'package:iris_tools/api/generator.dart';

class ContactModel {
  late String id;
  String name = '';
  String phoneNumber = '';
  ContactLevel level = ContactLevel.levelD;

  ContactModel(): id = Generator.generateKey(15);

  ContactModel.fromMap(Map map) {
    id = map['id']?? Generator.generateKey(15);
    name = map['name']?? '';
    phoneNumber = map['phoneNumber'];
    level = ContactLevel.from(map['level']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['phoneNumber'] = phoneNumber;
    map['level'] = level.getNumber();

    return map;
  }

  static List<ContactModel> mapToList(dynamic data){
    if(data == null){
      return [];
    }

    return (data as List).map((e) => ContactModel.fromMap(e)).toList();
  }
}
