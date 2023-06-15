import 'package:app/structures/models/placeModel.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:flutter/material.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:toggle_switch/toggle_switch.dart';

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
  }

  @override
  void dispose(){
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
              child: const Text('رله').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        Expanded(
            child: ListView(
              children: [
                buildRelay1Section(),

              ],
            )
        ),
      ],
    );
  }

  Widget buildRelay1Section() {
    final itm = widget.place.relays[0];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          children: [
            Text(itm.getName()),

            ToggleSwitch(
              changeOnTap: false,
              multiLineText: false,
              totalSwitches: 2,
              initialLabelIndex: 0,
              activeBgColor: const [Colors.green, Colors.red],
              activeFgColor: Colors.white,
              inactiveFgColor: Colors.white,
              labels: const [
                'فعال',
                'غیرفعال',
              ],
              onToggle: onChangeRelay1,
            ),
          ],
        ),
      ),
    );
  }


  void onChangeRelay1(int? index) {

  }
}
