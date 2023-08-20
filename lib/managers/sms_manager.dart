import 'dart:async';

import 'package:app/tools/routeTools.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:sms_advanced/sms_advanced.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/settings_manager.dart';
import 'package:app/services/sms_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appToast.dart';

class SmsManager {
  static StreamSubscription? smsListenerSubscription;
  static DateTime? _lastSendSmsTime;
  static StreamController smsTimeStream = StreamController();
  static Timer? _timer;

  static int smsResponseTime = 20;

  SmsManager._();

  static void listenToDeviceMessage(){
    if(smsListenerSubscription != null && !smsListenerSubscription!.isPaused){
      return;
    }

    smsListenerSubscription = SmsService.receiveSms(_parseReceivedMessage);
  }

  static void _parseReceivedMessage(SmsMessage msg){
    /// used revers for avoid +98 if exist
    var n1 = msg.sender?.split('').reversed.take(10).join();

    for(final p in PlaceManager.places){
      var n2 = p.simCardNumber.split('').reversed.take(10).join();

      if(n1 == n2){
        _stopTimer();
        p.parseSms(msg.body?? '');
        EventNotifierService.notify(AppEvents.placeDataChanged);
        break;
      }
    }
  }

  static Future<void> sendChargeCode(String sc, PlaceModel place, BuildContext context) async {
    final operator = detectOperatorForNumber(place.simCardNumber);

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
    final operator = detectOperatorForNumber(place.simCardNumber);

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
    if(isInWaitingForResponse()){
      AppToast.showToast(context, 'حداقل 20 ثانیه بین دو درخواست باید فاصله قرار دهید');
      return false;
    }

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

    listenToDeviceMessage();
    final code = '*${place.currentPassword}*$sc#';
    final result = SmsService.sendSms(code, [place.simCardNumber]);

    final sms = await result.first;

    if(sms == null){
      return false;
    }

    _lastSendSmsTime = DateHelper.getNow();
    _startTimer();

    late StreamSubscription subscribe;
    final signal = Completer<bool>();

    subscribe = sms.onStateChanged.listen((event) {
      _notifyToUser(place, context, event);

      if(event == SmsMessageState.Fail) {
        subscribe.cancel();
        _stopTimer();
        signal.complete(false);
      }
      else if(event == SmsMessageState.Delivered) {
        subscribe.cancel();
        signal.complete(true);
      }
      else if(event == SmsMessageState.Sent){
        subscribe.cancel();
        //signal.complete(false);
        signal.complete(true);// todo. delete this
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

  static bool isInWaitingForResponse(){
    if(_lastSendSmsTime == null){
      return false;
    }

    if(DateHelper.isPastOf(_lastSendSmsTime, Duration(seconds: smsResponseTime))){
      return false;
    }

    return true;
  }

  static void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      smsTimeStream.sink.add(smsResponseTime - timer.tick);

      if(timer.tick >= smsResponseTime){
        _timer!.cancel();
        _timer = null;
        _lastSendSmsTime = null;
        smsTimeStream.sink.add(null);

        AppToast.showToast(RouteTools.materialContext!, 'متاسفانه جوابی دریافت نشد');
      }
    });
  }

  static void _stopTimer(){
    if(_timer == null || !_timer!.isActive){
      _timer = null;
      return;
    }

    _timer!.cancel();
    _timer = null;
    _lastSendSmsTime = null;
    smsTimeStream.sink.add(null);
  }

  static SimOperator? detectOperatorForNumber(String number){
    final hamrahList = [
      '0911', '0912', '0913', '0914',
      '0915', '0916', '0917', '0918',
      '0990', '0991', '0992', '0993',
      '0994','0995',
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

    if(number.startsWith('+98')){
      number = '0${number.substring(2)}';
    }

    if(number.startsWith('0098')){
      number = '0${number.substring(3)}';
    }

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
