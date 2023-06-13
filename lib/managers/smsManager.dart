import 'dart:async';

import 'package:app/services/sms_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:sms_advanced/sms_advanced.dart';

class SmsManager {
  static int _listenerCount = 0;
  static StreamSubscription? _subscription;

  SmsManager._();

  static void listenToDeviceMessage(){
    _listenerCount++;

    if(_listenerCount > 1){
      return;
    }


    void parse(SmsMessage msg){
      var n1 = msg.sender?.split('').reversed.take(10).join();

      for(final p in PublicAccess.places){
        var n2 = p.simCardNumber.split('').reversed.take(10).join();
print('>>>  $n1    ,n2:$n2');
        if(n1 == n2){
          _listenerCount--;

          if(_listenerCount < 1) {
            _subscription?.cancel();
          }

          p.parseUpdate(msg.body?? '');
          EventNotifierService.notify(AppEvents.placeDataChanged);
          break;
        }
      }
    }

    _subscription = SmsService.receiveSms(parse);
  }

  static Future<void> sendChargeCode(String sc, PlaceModel place, BuildContext context) async {
    final operator = detectOperator(place.simCardNumber);

    if(operator == null){
      AppSnack.showError(context, 'متاسفانه اپراتور سیم کار شناخته نشد');
      return;
    }

    String code = '60*141*$sc'; // iranCell

    if(operator == SimOperator.hamrahAval){
      code = '60*140*#$sc';
    }
    else if(operator == SimOperator.rightel){
      code = '60*141*$sc';
    }

    sendSms(code, place, context);
  }

  static Future<void> getChargeBalance(PlaceModel place, BuildContext context) async {
    final operator = detectOperator(place.simCardNumber);

    if(operator == null){
      AppSnack.showError(context, 'متاسفانه اپراتور سیم کار شناخته نشد');
      return;
    }

    String code = '60*555*1*2'; // iranCell

    if(operator == SimOperator.hamrahAval){
      code = '60*140*11';
    }
    else if(operator == SimOperator.rightel){
      code = '60*140';
    }

    listenToDeviceMessage();
    sendSms(code, place, context);
  }

  static Future<void> sendSms(String sc, PlaceModel place, BuildContext context) async {
    final code = '*${place.currentPassword}*$sc#';
    print('@@@@@@@ $code  to   ${place.simCardNumber}');
    final result = SmsService.sendSms(code, [place.simCardNumber]);

    final sms = await result.first;

    if(sms == null){
      return;
    }

    late StreamSubscription subscribe;

    subscribe = sms.onStateChanged.listen((event) {
      _notifyToUser(place, context, event);

      if(event != SmsMessageState.Sending) {
        subscribe.cancel();
      }
    });
  }

  static void _notifyToUser(PlaceModel place, BuildContext context, SmsMessageState state) {
    if(state == SmsMessageState.Sent || state == SmsMessageState.Delivered){
      AppToast.showToast(context, 'ارسال شد');
    }
    else if(state == SmsMessageState.Fail){
      AppToast.showToast(context, 'خطا، ارسال نشد');
    }
  }

  static SimOperator? detectOperator(String number){
    final hamrahList = [
      '0911', '0912', '0913', '0914',
      '0915', '0916', '0917', '0918',
      '0990', '0991', '0992', '0993',
    ];

    final iranCellList = [
      '0930', '0933', '0935', '0936',
      '0937', '0938', '0939', '0901',
      '0902', '0903', '0904', '0905',
      '0941', '0900',
    ];

    final rightelList = [
      '0920', '0921', '0922', '0936',
    ];

    for(final h in hamrahList) {
      if (number.startsWith(h)) {
        return SimOperator.hamrahAval;
      }
    }

    for(final i in iranCellList) {
      if (number.startsWith(i)) {
        return SimOperator.iranCell;
      }
    }

    for(final r in rightelList) {
      if (number.startsWith(r)) {
        return SimOperator.rightel;
      }
    }

    return null;
  }
}
///=============================================================================
enum SimOperator {
  hamrahAval,
  iranCell,
  rightel;
}