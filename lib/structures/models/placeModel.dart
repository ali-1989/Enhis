import 'package:app/tools/app/appToast.dart';
import 'package:app/tools/routeTools.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/generator.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:persian_needs/persian_needs.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/antennaRange.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/contactLevel.dart';
import 'package:app/structures/enums/deviceStatus.dart';
import 'package:app/structures/enums/notifyToContactStatus.dart';
import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/structures/models/contactModel.dart';
import 'package:app/structures/models/relayModel.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/currencyTools.dart';
import 'package:app/tools/dateTools.dart';

class PlaceModel {
  late String id;
  String name = '';
  String simCardNumber = '';
  String supportName = '';
  String supportPhoneNumber = '';
  String? adminPhoneNumber;
  String currentPassword = '0000';
  String? newPassword;
  DateTime? lastUpdateTimeUTC;
  DeviceStatus deviceStatus = DeviceStatus.unKnow;
  NotifyToContactStatus notifyToContactStatus = NotifyToContactStatus.smsAndCallByRepeat;
  int simLanguage = 1; // 1:farsi, 0:english
  int notifyOnDisPower = 0; // 1:active, 0:inActive
  int? batteryCharge;
  bool? isConnectedPower;
  bool? speakerIsConnected;
  bool useOfRelays = false;
  int? simCardAntennaStatus;
  int? contactCount;
  int? remoteCount;
  int sirenDurationMinutes = 2;
  int smsCountReport = 20;
  int batteryReportDuration = 0;
  bool? wirelessIsActive;
  String? simCardAmount;
  List<ZoneModel> zones = [];
  List<RelayModel> relays = [];
  List<ContactModel> contacts = [];

  PlaceModel(): id = Generator.generateKey(15) {
    int zIdx = 1;

    while(zones.length < 4){
      zones.add(ZoneModel()..number = zIdx);
      zIdx++;
    }

    zIdx = 1;

    while(relays.length < 2){
      relays.add(RelayModel()..number = zIdx);
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
    lastUpdateTimeUTC = DateHelper.tsToSystemDate(map['lastUpdateTimeUTC']);
    deviceStatus = DeviceStatus.from(map['deviceStatus']);
    notifyToContactStatus = NotifyToContactStatus.from(map['notifyToContactStatus']);
    batteryCharge = map['batteryCharge'];
    contactCount = map['contactCount'];
    remoteCount = map['remoteCount'];
    simLanguage = map['simLanguage'];
    notifyOnDisPower = map['notifyOnDisPower'];
    isConnectedPower = map['isConnectedPower'];
    simCardAntennaStatus = map['simCardAntennaStatus'];
    simCardAmount = map['simCardAmount'];
    speakerIsConnected = map['speakerIsConnected'];
    useOfRelays = map['useOfRelays'];
    wirelessIsActive = map['wirelessState'];
    sirenDurationMinutes = map['sirenDurationMinutes'];
    smsCountReport = map['smsCountReport'];
    batteryReportDuration = map['batteryReportDuration'];
    zones = ZoneModel.mapToList(map['zones']);
    relays = RelayModel.mapToList(map['relays']);
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
    map['lastUpdateTimeUTC'] = DateHelper.toTimestampNullable(lastUpdateTimeUTC);
    map['deviceStatus'] = deviceStatus.getNumber();
    map['notifyToContactStatus'] = notifyToContactStatus.getNumber();
    map['batteryCharge'] = batteryCharge;
    map['contactCount'] = contactCount;
    map['remoteCount'] = remoteCount;
    map['simLanguage'] = simLanguage;
    map['notifyOnDisPower'] = notifyOnDisPower;
    map['isConnectedPower'] = isConnectedPower;
    map['simCardAntennaStatus'] = simCardAntennaStatus;
    map['simCardAmount'] = simCardAmount;
    map['speakerIsConnected'] = speakerIsConnected;
    map['useOfRelays'] = useOfRelays;
    map['wirelessState'] = wirelessIsActive;
    map['sirenDurationMinutes'] = sirenDurationMinutes;
    map['smsCountReport'] = smsCountReport;
    map['batteryReportDuration'] = batteryReportDuration;
    map['zones'] = zones.map((e) => e.toMap()).toList();
    map['relays'] = relays.map((e) => e.toMap()).toList();
    map['contacts'] = contacts.map((e) => e.toMap()).toList();

    return map;
  }

  bool hasUpdate(){
    return lastUpdateTimeUTC != null;
  }

  bool hasDeviceStatus(){
    return deviceStatus != DeviceStatus.unKnow;
  }

  String getLastUpdateDate(){
    if(!hasUpdate()){
      return AppMessages.needToUpdate;
    }

    if(DateHelper.isToday(lastUpdateTimeUTC!)){
      return '${DateTools.hmOnlyRelative(lastUpdateTimeUTC, isUtc: true)}  امروز';
    }

    return DateHelper.utcToLocal(lastUpdateTimeUTC!).tillNow(numeric: true);
  }

  Color getUpdateColor(){
    if(!hasUpdate()){
      return Colors.red;
    }

    final dif = DateHelper.difference(lastUpdateTimeUTC!, DateHelper.getNowToUtc());

    if(dif.inHours < 1){
      return Colors.green;
    }

    if(dif.inHours < 3){
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

    final v = simCardAmount!.substring(0, simCardAmount!.length-1);

    return '${CurrencyTools.formatCurrencyString(v)} تومان';
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
      AntennaRange.good => 'متوسط',
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
      AntennaRange.good => Colors.purpleAccent,
      AntennaRange.veryGood => Colors.green,
    };
  }

  String getBatteryStateText(){
    if(batteryCharge == null){
      return AppMessages.unKnow;
    }

    return '$batteryCharge %';
  }

  String getSpeakerStateText(){
    if(speakerIsConnected == null){
      return AppMessages.unKnow;
    }

    if(speakerIsConnected == true){
      return 'متصل';
    }

    return 'بذون بلندگو';
  }

  void parseSms(String txt){
    //print('>>>> pars >>>>>> $txt');

    if(txt.contains('اپتکس: رله وصل شد')){
      relays.first.isActive = true;
      PlaceManager.updatePlaceToDb(this);
      EventNotifierService.notify(AppEvents.placeDataChanged);
      AppToast.showToast(RouteTools.materialContext!, 'رله فعال شد');
      return;
    }

    if(txt.contains('اپتکس: رله قطع شد')){
      relays.first.isActive = false;
      PlaceManager.updatePlaceToDb(this);
      EventNotifierService.notify(AppEvents.placeDataChanged);
      AppToast.showToast(RouteTools.materialContext!, 'رله غیر فعال شد');
      return;
    }

    if(txt.contains('اپتکس: شماره ذخیره شد')){
      AppToast.showToast(RouteTools.materialContext!, 'مخاطب ذخیره شد');
      return;
    }

    if(txt.startsWith('*') && txt.endsWith('#')){
      final splits = txt.split('*');

      /// zones
      if(txt.contains('Z')) {
        final pat = RegExp(r'.*?Z(\d+)(\w+)', multiLine: false, unicode: false);

        for (final z in splits) {
          if (!z.startsWith('Z')) {
            continue;
          }

          final res = pat.firstMatch(z);

          if (res != null) {
            final number = res.group(1);
            final status = res.group(2);

            for (final zon in zones) {
              if (zon.number == MathHelper.clearToInt(number)) {
                zon.status = ZoneStatus.byShortName(status!);
              }
            }
          }
        }
      }

      /// contacts
      else {
        final pat = RegExp(r'(\d+)(\w+)(\d+)', multiLine: false, unicode: false);

        for (final co in splits) {
          final res = pat.firstMatch(co);

          if (res != null) {
            final number = res.group(1);
            final level = res.group(2);
            final order = res.group(3);

            var exist = false;

            for (final user in contacts) {
              if (user.phoneNumber == number) {
                user.level = ContactLevel.byChar(level!);
                user.order = MathHelper.clearToInt(order!);
                exist = true;
                break;
              }
            }

            if (!exist) {
              final c = ContactModel();
              c.phoneNumber = number!;
              c.level = ContactLevel.byChar(level!);
              c.order = MathHelper.clearToInt(order!);

              contacts.add(c);
            }
          }
        }

        EventNotifierService.notify(AppEvents.contactDataChanged);
      }
    }

    /// update info
    else if(txt.endsWith(';')) {
      lastUpdateTimeUTC = DateHelper.getNowToUtc();
      final splits = txt.split(',');

      deviceStatus = DeviceStatus.from(MathHelper.clearToInt(splits[0]));
      isConnectedPower = MathHelper.clearToInt(splits[1]) == 1;
      final zonesState = splits[2];
      speakerIsConnected = MathHelper.clearToInt(splits[3]) == 1;
      remoteCount = MathHelper.clearToInt(splits[4]);
      simCardAntennaStatus = MathHelper.clearToInt(splits[5]);
      contactCount = MathHelper.clearToInt(splits[6]) + 1;
      wirelessIsActive = MathHelper.clearToInt(splits[7]) == 1;
      batteryCharge = MathHelper.clearToInt(splits[8]);
      relays.first.isActive = MathHelper.clearToInt(splits[9]) == 1;

      for(var i =0; i < zones.length; i++){
        final z = zones[i];
        z.isOpen = zonesState[i] == '0';
      }

      //EventNotifierService.notify(AppEvents.placeDataChanged);
    }

    /// charge-sim
    else {
      final pat = RegExp(r'.*?(\d+).*', multiLine: true, unicode: true);
      final res = pat.firstMatch(txt);

      if (res != null) {
        simCardAmount = res.group(1);
      }
    }

    EventNotifierService.notify(AppEvents.placeDataChanged);
    PlaceManager.updatePlaceToDb(this);
  }
}

/*int? getDeviceStatsForSwitchButtonA(){
    return switch(deviceStatus){
      DeviceStatus.unKnow => null,
      DeviceStatus.active => 0,
      DeviceStatus.inActive => 1,
      DeviceStatus.semiActive => null,
      DeviceStatus.silent => null,
    };
  }

  int? getDeviceStatsForSwitchButtonB(){
    return switch(deviceStatus){
      DeviceStatus.unKnow => null,
      DeviceStatus.active => null,
      DeviceStatus.inActive => null,
      DeviceStatus.semiActive => 0,
      DeviceStatus.silent => 1,
    };
  }*/