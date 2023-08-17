import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/views/components/backBtn.dart';

class ZonePage extends StatefulWidget {
  final PlaceModel place;

  const ZonePage({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<ZonePage> createState() => _ZonePageState();
}
///==================================================================================
class _ZonePageState extends StateBase<ZonePage> {

  @override
  void initState(){
    super.initState();

    EventNotifierService.addListener(AppEvents.placeDataChanged, eventListener);
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.placeDataChanged, eventListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Assist(
        controller: assistCtr,
        builder: (context, ctr, data) {
          return Scaffold(
            body: SafeArea(
                child: buildBody()
            ),
          );
        }
    );
  }

  Widget buildBody(){
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: const Text('مدیریت زون ها').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal:16.0),
          child: CustomCard(
            color: Colors.lime,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('اگر زونی را غیرفعال کنید، با تحریک حسگر زون ، دستگاه عمل نمی کند'),
              )
          ),
        ),

        const SizedBox(height: 15),

        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: widget.place.zones.map((e) => mapZone(e)).toList(),
              ),
            )
        ),
      ],
    );
  }

  Widget mapZone(ZoneModel zone) {
    return Card(
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(zone.getName()).bold().fsR(3),

            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CheckBoxRow(
                    value: zone.show,
                    description: Text('نمایش زون ${zone.number}').bold(),
                    onChanged: (v){
                      onChangeShowState(zone, v);
                    }
                ),

                TextButton(
                    onPressed: (){
                      onChangeNameClick(zone);
                    },
                    child: const Text('تغییر نام')
                )
              ],
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleSwitch(
                  changeOnTap: false,
                  multiLineText: false,
                  totalSwitches: 2,
                  initialLabelIndex: zone.isActive? 0 :1,
                  activeBgColors: const [[Colors.green], [Colors.red]],
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: const [
                    'فعال',
                    'غیرفعال',
                  ],
                  onToggle: (state){
                    onCloseZone(zone, state == 0);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onChangeNameClick(ZoneModel itm) async {
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

  void eventListener({data}) {
    assistCtr.updateHead();
  }

  void onCloseZone(ZoneModel zone, bool state) async {
    final send = await SmsManager.sendSms('Z${zone.number}T', widget.place, context);

    if(send){
      zone.isActive = state;
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
}
