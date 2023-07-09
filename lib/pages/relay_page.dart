import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/relayStatus.dart';
import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/views/dialogs/manageRelayDialog.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/views/components/backBtn.dart';

class RelayPage extends StatefulWidget {
  final PlaceModel place;

  const RelayPage({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<RelayPage> createState() => _RelayPageState();
}
///==================================================================================
class _RelayPageState extends StateBase<RelayPage> {

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
              child: const Text('دستورات رله').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
                onPressed: onEditRelayClick,
                child: const Text('تنظیمات').bold().fsR(2),
            ),
          ),
        ),
        const SizedBox(height: 15),

        buildRelay1Section(),

        //buildRelay2Section(),
      ],
    );
  }

  Widget buildRelay1Section() {
    final itm = widget.place.relays[0];

    return Card(
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itm.getName()).bold().fsR(3),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleSwitch(
                  changeOnTap: false,
                  multiLineText: false,
                  totalSwitches: 2,
                  initialLabelIndex: itm.isActive? 0 :1,
                  activeBgColors: const [[Colors.green], [Colors.red]],
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: const [
                    'فعال',
                    'غیرفعال',
                  ],
                  onToggle: onChangeRelay1state,
                ),

                InputChip(
                    onPressed: onRelay1CommandClick,
                    label: const Text('اجرا فرمان')
                )
              ],
            ),

            const SizedBox(height: 12),
            const Text('نوع تحریک رله:'),

            const SizedBox(height: 8),
            Row(
              children: [
                ColoredBox(
                  color: AppDecoration.dropDownBackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: DropdownButton<RelayStatus>(
                        items: RelayStatus.values.map((e) => DropdownMenuItem<RelayStatus>(
                            value: e,
                            child: ColoredBox(
                                color: AppDecoration.dropDownBackground,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                  child: Text(e.getHumanName()),
                                ))
                        )
                        ).toList(),
                        value: itm.status,
                        dropdownColor: AppDecoration.dropDownBackground,
                        underline: const SizedBox(),
                        padding: EdgeInsets.zero,
                        isDense: true,
                        onChanged: (s){
                          onChangeRelay1Status(s!);
                        }
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRelay2Section() {
    final itm = widget.place.relays[1];

    return Card(
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(itm.getName()).bold().fsR(3),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleSwitch(
                  changeOnTap: false,
                  multiLineText: false,
                  totalSwitches: 2,
                  initialLabelIndex: itm.isActive? 0 :1,
                  activeBgColors: const [[Colors.green], [Colors.red]],
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: const [
                    'فعال',
                    'غیرفعال',
                  ],
                  onToggle: onChangeRelay2State,
                ),

                InputChip(
                    onPressed: onRelay2CommandClick,
                    label: const Text('اجرا فرمان')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void onChangeRelay1state(int? index) async {
    final send = await SmsManager.sendSms('20*1*${index == 0? 'ON': 'OFF'}', widget.place, context);

    if(send){
      //widget.place.relays[0].isActive = index == 0;
      //PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }

  void onRelay1CommandClick() {
    SmsManager.sendSms('20*1*000002', widget.place, context);
  }

  void onChangeRelay2State(int? index) async {
    final send = await SmsManager.sendSms('20*2*${index == 0? 'ON': 'OFF'}', widget.place, context);

    if(send){
      //widget.place.relays[1].isActive = index == 0;
      //PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }

  void onRelay2CommandClick() {
    SmsManager.sendSms('20*2*000002', widget.place, context);
  }

  void onEditRelayClick() {
    AppDialogIris.instance.showIrisDialog(
      context,
      descView: ManageRelayDialog(place: widget.place),
      decoration: AppDialogIris.instance.dialogDecoration.copy()..widthFactor = 0.9,
    );
  }

  void eventListener({data}) {
    assistCtr.updateHead();
  }

  void onChangeRelay1Status(RelayStatus relayStatus) async {
    final send = await SmsManager.sendSms('29*1*${relayStatus.getNumber()}', widget.place, context);

    if(send){
      widget.place.relays[0].status = relayStatus;
      PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }
}
