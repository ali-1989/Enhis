
import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';

class ManageZoneDialog extends StatefulWidget {
  final PlaceModel place;

  const ManageZoneDialog({
    super.key,
    required this.place,
  });

  @override
  State<ManageZoneDialog> createState() => _ManageZoneDialogState();
}
///=============================================================================
class _ManageZoneDialogState extends State<ManageZoneDialog> {

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

          const Text('مدیریت زون ها').bold().fsR(2),
          const SizedBox(height: 25),

          const Card(
            color: Colors.amber,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('حداقل یک مورد انتخاب شده باشد'),
            ),
          ),

          const SizedBox(height: 15),

          ListView.builder(
            shrinkWrap: true,
              itemCount: widget.place.zones.length,
              itemBuilder: itemBuilderZoneList
          ),

          const SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget? itemBuilderZoneList(BuildContext context, int index) {
    final itm = widget.place.zones[index];
    final zName = (itm.name != null && itm.name!.isNotEmpty)? '(${itm.name})' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CheckBoxRow(
                value: itm.show,
                description: Text('نمایش زون ${itm.number} $zName'),
                onChanged: (v){
                  onChangeShowState(itm, v);
                },
            )
          ],
        ),

        TextButton(
            onPressed: (){
              onChangeNameClick(itm);
            },
            child: const Text('تغییر نام')
        )
      ],
    );
  }

  void onChangeNameClick(ZoneModel itm) async {
    final res = await AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('یک نام وارد کنید'),
        inputDecoration: AppDecoration.inputDecor,
        yesFn: (c, txt){
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

  void onChangeShowState(ZoneModel itm, bool v) {
    if(v){
      if(!itm.show) {
        itm.show = true;
        saveAndNotify();
      }
    }
    else {
      final activeCount = widget.place.zones.where((element) => element.show).length;

      if(activeCount < 2){

      }
      else{
        itm.show = false;
        saveAndNotify();
      }
    }
  }

  void saveAndNotify() {
    setState(() {});
    PlaceManager.updatePlaceToDb(widget.place);
    EventNotifierService.notify(AppEvents.placeDataChanged);
  }
}
