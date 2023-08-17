import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/structures/models/relayModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';

/// this page not used now (1402-05-19)

class ManageRelayDialog extends StatefulWidget {
  final PlaceModel place;

  const ManageRelayDialog({
    super.key,
    required this.place,
  });

  @override
  State<ManageRelayDialog> createState() => _ManageRelayDialogState();
}
///=============================================================================
class _ManageRelayDialogState extends State<ManageRelayDialog> {

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

          const Text('مدیریت رله ها').fsR(3).bold(),
          const SizedBox(height: 20),
          const Divider(indent: 20, endIndent: 20,),
          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
              itemCount: widget.place.relays.length,
              itemBuilder: itemBuilderRelayList
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget? itemBuilderRelayList(BuildContext context, int index) {
    final itm = widget.place.relays[index];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(itm.getName()),

        TextButton(
            onPressed: (){
              onChangeNameClick(itm);
            },
            child: const Text('تغییر نام')
        )
      ],
    );
  }

  void onChangeNameClick(RelayModel itm) async {
    final res = await AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('یک نام وارد کنید'),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        mainButton: (c, txt) async {
          FocusHelper.hideKeyboardByUnFocusRoot();
          Future.delayed(const Duration(milliseconds: 200)).then((value) {
            AppNavigator.pop(c, result: txt);
          });
        }
    );

    if(res is String){
      final name = res.trim();

      if(name.isNotEmpty){
        itm.name = TextHelper.subByCharCountSafe(name, 16);
      }
      else {
        itm.name = null;
      }

      saveAndNotify();
    }
  }

  void saveAndNotify() {
    setState(() {});
    PlaceManager.updatePlaceToDb(widget.place);
  }
}
