import 'dart:async';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/sms_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:sms_advanced/sms_advanced.dart';

class SmsManager {
  static StreamSubscription? smsListenerSubscription;

  SmsManager._();

  static void listenToDeviceMessage(){
    if(smsListenerSubscription != null && !smsListenerSubscription!.isPaused){
      return;
    }

    void parse(SmsMessage msg){
      var n1 = msg.sender?.split('').reversed.take(10).join();

      for(final p in PlaceManager.places){
        var n2 = p.simCardNumber.split('').reversed.take(10).join();

        if(n1 == n2){
          p.parseUpdate(msg.body?? '');
          EventNotifierService.notify(AppEvents.placeDataChanged);
          break;
        }
      }
    }

    smsListenerSubscription = SmsService.receiveSms(parse);
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

    sendSms(code, place, context, showSmsDialog: false);
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

    sendSms(code, place, context);
  }

  static Future<bool> sendSms(String sc, PlaceModel place, BuildContext context, {bool showSmsDialog = true}) async {
    if(showSmsDialog && SettingsManager.localSettings.askSndSmsEveryTime){
      final can = await AppDialogIris.instance.showYesNoDialog(
          context,
        desc: 'آیا پیامک ارسال شود؟',
        yesFn: (ctx){
            return true;
        }
      );

      if(can == null || !can){
        return false;
      }
    }

    final code = '*${place.currentPassword}*$sc#';
    print('@@@@@@@ $code  to   ${place.simCardNumber}');
    final result = SmsService.sendSms(code, [place.simCardNumber]);

    final sms = await result.first;

    if(sms == null){
      return false;
    }

    late StreamSubscription subscribe;
    final signal = Completer<bool>();

    subscribe = sms.onStateChanged.listen((event) {
      _notifyToUser(place, context, event);

      if(event == SmsMessageState.Fail) {
        subscribe.cancel();
        signal.complete(false);
      }

      if(event == SmsMessageState.Sent || event == SmsMessageState.Delivered) {
        subscribe.cancel();
        signal.complete(true);
      }
    });

    return signal.future;
  }

  static void _notifyToUser(PlaceModel place, BuildContext context, SmsMessageState state) {
    if(state == SmsMessageState.Sending){
      AppToast.showToast(context, 'در حال ارسال');
    }
    if(state == SmsMessageState.Sent || state == SmsMessageState.Delivered){
      AppToast.showToast(context, 'تا رسیدن جواب صبور باشید');
    }
    else if(state == SmsMessageState.Fail){
      AppToast.showToast(context, 'خطا، پیامک ارسال نشد');
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