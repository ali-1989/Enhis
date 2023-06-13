
import 'package:app/structures/enums/antennaRange.dart';
import 'package:app/structures/enums/deviceStatus.dart';
import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/structures/models/contactModel.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:persian_needs/persian_needs.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';

class PlaceModel {
  late String id;
  String name = '';
  String simCardNumber = '';
  String supportName = '';
  String supportPhoneNumber = '';
  String? adminPhoneNumber;
  String currentPassword = '0000';
  String? newPassword;
  DateTime? lastUpdateTime;
  DeviceStatus deviceStatus = DeviceStatus.unKnow;
  int? batteryCharge;
  bool? isConnectedPower;
  int? simCardAntennaStatus;
  String? simCardAmount;
  List<ZoneModel> zones = [];
  List<ContactModel> contacts = [];

  PlaceModel(): id = Generator.generateKey(15) {
    int zIdx = 1;

    while(zones.length < 4){
      zones.add(ZoneModel()..number = zIdx);
      zIdx++;
    }
  }

  PlaceModel.fromMap(Map map) {
    id = map['id']?? Generator.generateKey(15);
    name = map['name'];
    simCardNumber = map['simCardNumber'];
    supportName = map['supportName'];
    supportPhoneNumber = map['supportPhoneNumber'];
    adminPhoneNumber = map['adminPhoneNumber'];
    currentPassword = map['currentPassword'];
    newPassword = map['newPassword'];
    lastUpdateTime = DateHelper.tsToSystemDate(map['lastUpdateTime']);
    deviceStatus = DeviceStatus.from(map['deviceStatus']);
    batteryCharge = map['batteryCharge'];
    isConnectedPower = map['isConnectedPower'];
    simCardAntennaStatus = map['simCardAntennaStatus'];
    simCardAmount = map['simCardAmount'];
    zones = ZoneModel.mapToList(map['zones']);
    contacts = ContactModel.mapToList(map['contacts']);
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['simCardNumber'] = simCardNumber;
    map['supportName'] = supportName;
    map['supportPhoneNumber'] = supportPhoneNumber;
    map['adminPhoneNumber'] = adminPhoneNumber;
    map['currentPassword'] = currentPassword;
    map['newPassword'] = newPassword;
    map['lastUpdateTime'] = DateHelper.toTimestampNullable(lastUpdateTime);
    map['deviceStatus'] = deviceStatus.getNumber();
    map['batteryCharge'] = batteryCharge;
    map['isConnectedPower'] = isConnectedPower;
    map['simCardAntennaStatus'] = simCardAntennaStatus;
    map['simCardAmount'] = simCardAmount;
    map['zones'] = zones.map((e) => e.toMap()).toList();
    map['contacts'] = contacts.map((e) => e.toMap()).toList();

    return map;
  }

  bool hasUpdate(){
    return lastUpdateTime != null;
  }

  String getLastUpdateDate(){
    if(!hasUpdate()){
      return AppMessages.needToUpdate;
    }

    //return DateTools.dateAndHmRelative(lastUpdateTime);
    return lastUpdateTime!.tillNow(numeric: true);
  }

  Color getUpdateColor(){
    if(!hasUpdate()){
      return Colors.red;
    }

    final dif = DateHelper.difference(lastUpdateTime!, DateHelper.getNow());

    if(dif.inHours < 4){
      return Colors.green;
    }

    if(dif.inHours < 8){
      return Colors.orange;
    }

    return Colors.red;
  }

  String getPowerState() {
    if(isConnectedPower == null) {
      return AppMessages.unKnow;
    }

    if(isConnectedPower!) {
      return AppMessages.connectedPower;
    }

    return AppMessages.unConnectedPower;
  }

  String getSimCardCharge() {
    if(simCardAmount == null){
      return AppMessages.unKnow;
    }

    return '$simCardAmount';
  }

  AntennaRange getSimCardAntennaRange() {
    if(simCardAntennaStatus == null){
      return AntennaRange.unKnow;
    }

    if(simCardAntennaStatus! < 10){
      return AntennaRange.wake;
    }

    if(simCardAntennaStatus! < 20){
      return AntennaRange.good;
    }

    return AntennaRange.veryGood;
  }

  String getSimCardAntenna() {
    if(simCardAntennaStatus == null){
      return AppMessages.unKnow;
    }

    return switch(getSimCardAntennaRange()){
      AntennaRange.unKnow => 'نامشخص',
      AntennaRange.wake => 'ضعیف',
      AntennaRange.good => 'خوب',
      AntennaRange.veryGood => 'عالی',
    };
  }

  Color getSimCardAntennaColor() {
    if(simCardAntennaStatus == null){
      return Colors.black;
    }

    return switch(getSimCardAntennaRange()){
      AntennaRange.unKnow => Colors.red,
      AntennaRange.wake => Colors.orange,
      AntennaRange.good => Colors.blue,
      AntennaRange.veryGood => Colors.green,
    };
  }

  String getBatteryStateText(){
    if(batteryCharge == null){
      return AppMessages.unKnow;
    }

    return '$batteryCharge %';
  }

  void parseUpdate(String txt){
    print('|||||| pars >>>>>> $txt');

    /// zones
    if(txt.startsWith('*') && txt.endsWith('#')){
      final splits = txt.split('*');
      final pat = RegExp(r'.*?Z(\d+)(\w+)', multiLine: false, unicode: false);

      print('zzz:$splits');
      for(final z in splits){
        if(!z.startsWith('Z')){
          continue;
        }

        final res = pat.firstMatch(z);

        if(res != null){
          final number = res.group(1);
          final status = res.group(2);
          print('---zone: $number-$status');

          for(final zon in zones){
            if(zon.number == MathHelper.clearToInt(number)){
              zon.status = ZoneStatus.byShortName(status!);
            }
          }
        }
      }
      return;
    }

    final splits = txt.split(',');

    /// update
    if (splits.length > 5) {
      print('>>>>>> $splits');
      print('>>>>>> ${splits[5]}, ${splits[6]}');
      simCardAntennaStatus = MathHelper.clearToInt(splits[5]);
      int contactCount = MathHelper.clearToInt(splits[6]) +1;
      int remoteCount = MathHelper.clearToInt(splits[4]);
      return;
    }


    /// charge-sim
    final pat = RegExp(r'.*?(\d+).*', multiLine: true, unicode: true);
    final res = pat.firstMatch(txt);

    if(res != null){
      simCardAmount = res.group(1);
    }
  }
}
