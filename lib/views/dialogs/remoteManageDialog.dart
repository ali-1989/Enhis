import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/routeTools.dart';
import 'package:flutter/material.dart';

import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';

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
          ),

          Visibility(
              visible: widget.place.remoteCount != null && widget.place.remoteCount! > 0,
              child: buildDeleteRemotesSection()
          ),

          const SizedBox(height: 20),
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

    if(sms){
      if(mounted) {
        RouteTools.popTopView(context: context);
      }
    }
  }

  void smsDeActiveRemotes() async {
    final sms = await SmsManager.sendSms('59*0', widget.place, context);

    if(sms){
      if(mounted) {
        RouteTools.popTopView(context: context);
      }
    }
  }

  Widget buildDeleteRemotesSection() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: (widget.place.remoteCount?? 0)+1,
        itemBuilder: itemBuilder
    );
  }

  Widget? itemBuilder(BuildContext context, int index) {
    if(index == 0){
      return const Padding(
        padding: EdgeInsets.only(bottom: 20.0),
        child: Divider(color: Colors.grey, endIndent: 8, indent: 8),
      );
    }

    return Card(
      color:ColorHelper.highLightMore(AppDecoration.mainColor),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text('ریموت $index').color(Colors.white),
          ),

          TextButton(
              onPressed: (){
                onDeleteRemoteClick(index);
              },
              child: const Text('حذف')
          )
        ],
      ),
    );
  }

  void onDeleteRemoteClick(int index) async {
    final sms = await SmsManager.sendSms('50*$index', widget.place, context);

    if(sms){
      widget.place.remoteCount = widget.place.remoteCount! -1;
      PlaceManager.updatePlaceToDb(widget.place);
      setState(() {});
    }
  }
}