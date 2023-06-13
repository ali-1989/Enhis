import 'dart:async';

import 'package:app/services/sms_service.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';
import 'package:flutter/material.dart';
import 'package:sms_advanced/sms_advanced.dart';

class SmsManager {

  SmsManager._();

  static Future<void> sendChargeCode(String code, PlaceModel place, BuildContext context) async {
    final operator = detectOperator(place.simCardNumber);

    if(operator == null){
      AppSnack.showError(context, 'متاسفانه اپراتور سیم کار شناخته نشد');
      return;
    }

    final result = SmsService.sendSms('', [place.simCardNumber]);

    final sms = await result.first;

    if(sms == null){
      return;
    }

    late StreamSubscription subscribe;

    subscribe = sms.onStateChanged.listen((event) {
      _notifyToUser(place, context, event);
      subscribe.cancel();
    });
  }

  static void _notifyToUser(PlaceModel place, BuildContext context, SmsMessageState state) {
    if(state == SmsMessageState.Sent){
      AppToast.showToast(context, 'ارسال شد');
    }
    else if(state == SmsMessageState.Sent){
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