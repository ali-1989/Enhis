import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:flutter/material.dart';

import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';

class RemoteManageDialog extends StatefulWidget {
  final PlaceModel place;

  const RemoteManageDialog({
    super.key,
    required this.place,
  });

  @override
  State<RemoteManageDialog> createState() => _RemoteManageDialogState();
}
///=============================================================================
class _RemoteManageDialogState extends State<RemoteManageDialog> {

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: (){
                AppNavigator.pop(context);
              },
              child: const Icon(AppIcons.close),
            ),
          ),

          const Text('مدیریت ریموت ها').bold().fsR(2),
          const SizedBox(height: 15),
          const Divider(),

          const SizedBox(height: 15),
          Text(AppMessages.remoteManageDescription),

          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                    onPressed: onActiveRemoteClick,
                    child: const Text('فعال')
                ),
              ),

              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                    onPressed: onDeActiveRemoteClick,
                    child: const Text('غیر فعال')
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  void onDeActiveRemoteClick() {
    smsDeActiveRemotes();
  }

  void onActiveRemoteClick() {
    smsActiveRemotes();
  }

  void smsActiveRemotes() async {
    final sms = await SmsManager.sendSms('59*1', widget.place, context);
    //if(sms){}
  }

  void smsDeActiveRemotes() async {
    final sms = await SmsManager.sendSms('59*0', widget.place, context);
    //if(sms){}
  }
}
