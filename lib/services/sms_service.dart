import 'dart:async';

import 'package:flutter/material.dart';

import 'package:sms_advanced/sms_advanced.dart';

import 'package:app/tools/app/appDialog.dart';
import 'package:app/tools/app/appMessages.dart';

typedef SmsReceiveHandler = Function(SmsMessage msg);
///-----------------------------------------------------------------------------
class SmsService {
  SmsService._();

  static Future<bool> hasMultiSim() async {
    final provider = SimCardsProvider();
    final cards = await provider.getSimCards();

    return cards.length > 1;
  }

  static Future<List<SimCard>> getSimCards() {
    final provider = SimCardsProvider();
    return provider.getSimCards();
  }

  static List<Future<SmsMessage?>> sendSms(String txt, List<String> numbers){
    final sender = SmsSender();

    final res = <Future<SmsMessage?>>[];

    for(final num in numbers){
      final sms = SmsMessage(num, txt);
      res.add(sender.sendSms(sms));
    }

    return res;
  }

  static Future<List<Future<SmsMessage?>>> sendSmsWithSelectSim(String txt, List<String> numbers, BuildContext context) async {
    final sender = SmsSender();

    final provider = SimCardsProvider();
    final cards = await provider.getSimCards();

    if(cards.isEmpty){
      return [];
    }

    var simCard = cards.first;

    if(cards.length > 1){
      Widget build(SimCard sim){
        return GestureDetector(
            onTap: (){
              simCard = sim;

              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('      Sim ${sim.slot} ', style: const TextStyle(fontSize: 16)),
            )
        );
      }

      if (!context.mounted) {
        return [];
      }

      await AppDialog.instance.showCustomDialog(context,
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(AppMessages.selectASimCard, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
              ),
            ),
            const SizedBox(height: 20),
            ...cards.map((e) => build(e)).toList()
          ],
        ),
      );
    }

    final res = <Future<SmsMessage?>>[];

    for(final num in numbers){
      final sms = SmsMessage(num, txt);
      res.add(sender.sendSms(sms, simCard: simCard));
    }

    return res;
  }

  static Future<List<Future<SmsMessage?>>> sendSmsWithSim(String txt, List<String> numbers, int slot) async {
    final sender = SmsSender();

    final provider = SimCardsProvider();
    final cards = await provider.getSimCards();

    if(cards.isEmpty){
      return [];
    }

    var simCard = cards.first;

    if(cards.length > 1){
      for(final s in cards){
        if(s.slot == slot){
          simCard = s;
          break;
        }
      }
    }

    final res = <Future<SmsMessage?>>[];

    for(final num in numbers){
      final sms = SmsMessage(num, txt);
      res.add(sender.sendSms(sms, simCard: simCard));
    }

    return res;
  }

  static StreamSubscription receiveSms(SmsReceiveHandler handler){
    SmsReceiver receiver = SmsReceiver();
    return receiver.onSmsReceived!.listen(handler);
    // usage : s.body, s.address, s.sender
  }
}
