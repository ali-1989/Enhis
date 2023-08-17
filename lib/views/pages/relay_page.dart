import 'package:app/managers/place_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/relayStatus.dart';
import 'package:app/structures/models/relayModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:iris_tools/widgets/optionsRow/radioRow.dart';

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
  TextEditingController r1HourCtr = TextEditingController();
  TextEditingController r1MinCtr = TextEditingController();
  TextEditingController r1SecCtr = TextEditingController();
  TextEditingController r2HourCtr = TextEditingController();
  TextEditingController r2MinCtr = TextEditingController();
  TextEditingController r2SecCtr = TextEditingController();


  @override
  void initState(){
    super.initState();

    EventNotifierService.addListener(AppEvents.placeDataChanged, eventListener);

    final d1 = widget.place.relays[0].duration.toString().split(':');
    final d2 = widget.place.relays[1].duration.toString().split(':');

    r1HourCtr.text = d1[0].padLeft(2, '0');
    r1MinCtr.text = d1[1];
    r1SecCtr.text = d1[2].split('.')[0];
    r2HourCtr.text = d2[0].padLeft(2, '0');
    r2MinCtr.text = d2[1];
    r2SecCtr.text = d2[2].split('.')[0];
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
              child: const Text('مدیریت رله ها').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        const SizedBox(height: 15),

        Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  buildRelay1Section(),

                  const SizedBox(height: 15),

                  buildRelay2Section(),
                ],
              ),
            )
        )
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(itm.getName()).bold().fsR(3),

                TextButton(
                    onPressed: (){
                      onChangeNameClick(itm);
                    },
                    child: const Text('تغییر نام')
                )
              ],
            ),

            const SizedBox(height: 12),

            CheckBoxRow(
                value: widget.place.useOfRelay1,
                description: const Text('استفاده از رله 1').bold(),
                onChanged: (v){
                  widget.place.useOfRelay1 = v;
                  assistCtr.updateHead();
                  PlaceManager.updatePlaceToDb(widget.place);
                }
            ),

            const SizedBox(height: 12),

            RadioRow(
              description: Text(RelayStatus.shortCommand.getHumanName()),
              groupValue: itm.status.getNumber(),
              value: 1,
              color: AppDecoration.mainColor,
              onChanged: (value) {
                itm.status = RelayStatus.from(value);
                setState(() {});
                PlaceManager.updatePlaceToDb(widget.place);
              },
            ),

            RadioRow(
              description: Text(RelayStatus.twoState.getHumanName()),
              groupValue: itm.status.getNumber(),
              value: 2,
              color: AppDecoration.mainColor,
              onChanged: (value) {
                itm.status = RelayStatus.from(value);
                setState(() {});
                PlaceManager.updatePlaceToDb(widget.place);
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RadioRow(
                  mainAxisSize: MainAxisSize.min,
                  description: Text(RelayStatus.customTime.getHumanName()),
                  groupValue: itm.status.getNumber(),
                  value: 3,
                  color: AppDecoration.mainColor,
                  onChanged: (value) {
                    itm.status = RelayStatus.from(value);
                    r1TimeChange(itm);
                    setState(() {});
                  },
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 40,
                      child: TextField(
                        controller: r1SecCtr,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                        decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                            isDense: true,
                            hintText: '30',
                            contentPadding: const EdgeInsets.all(5)
                        ),
                        onChanged: (t){
                          r1TimeChange(itm);
                        },
                      ),
                    ),

                    const Text(' : '),

                    SizedBox(
                      width: 30,
                      height: 40,
                      child: TextField(
                        controller: r1MinCtr,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                        decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                            isDense: true,
                            hintText: '00',
                            contentPadding: const EdgeInsets.all(5)
                        ),
                        onChanged: (t){
                          r1TimeChange(itm);
                        },
                      ),
                    ),

                    const Text(' : '),

                    SizedBox(
                        width: 30,
                        height: 40,
                        child: TextField(
                          controller: r1HourCtr,
                          maxLines: 1,
                          keyboardType: TextInputType.number,
                          inputFormatters: [LengthLimitingTextInputFormatter(2)],
                          decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                              isDense: true,
                              hintText: '00',
                              contentPadding: const EdgeInsets.all(5)
                          ),
                          onChanged: (t){
                            r1TimeChange(itm);
                          },
                        ),
                    )
                  ],
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
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(itm.getName()).bold().fsR(3),

                TextButton(
                    onPressed: (){
                      onChangeNameClick(itm);
                    },
                    child: const Text('تغییر نام')
                )
              ],
            ),

            const SizedBox(height: 12),

            CheckBoxRow(
                value: widget.place.useOfRelay2,
                description: const Text('استفاده از رله 2').bold(),
                onChanged: (v){
                  widget.place.useOfRelay2 = v;
                  assistCtr.updateHead();
                  PlaceManager.updatePlaceToDb(widget.place);
                }
            ),

            const SizedBox(height: 12),

            RadioRow(
              description: Text(RelayStatus.shortCommand.getHumanName()),
              groupValue: itm.status.getNumber(),
              value: 1,
              color: AppDecoration.mainColor,
              onChanged: (value) {
                itm.status = RelayStatus.from(value);
                setState(() {});
                PlaceManager.updatePlaceToDb(widget.place);
              },
            ),

            RadioRow(
              description: Text(RelayStatus.twoState.getHumanName()),
              groupValue: itm.status.getNumber(),
              value: 2,
              color: AppDecoration.mainColor,
              onChanged: (value) {
                itm.status = RelayStatus.from(value);
                setState(() {});
                PlaceManager.updatePlaceToDb(widget.place);
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RadioRow(
                  mainAxisSize: MainAxisSize.min,
                  description: Text(RelayStatus.customTime.getHumanName()),
                  groupValue: itm.status.getNumber(),
                  value: 3,
                  color: AppDecoration.mainColor,
                  onChanged: (value) {
                    itm.status = RelayStatus.from(value);
                    r2TimeChange(itm);
                    setState(() {});
                    PlaceManager.updatePlaceToDb(widget.place);
                  },
                ),

                Row(
                  children: [
                    SizedBox(
                      width: 30,
                      height: 40,
                      child: TextField(
                        controller: r2SecCtr,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                        decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                            isDense: true,
                            hintText: '30',
                            contentPadding: const EdgeInsets.all(5)
                        ),
                        onChanged: (t){
                          r2TimeChange(itm);
                        },
                      ),
                    ),

                    const Text(' : '),

                    SizedBox(
                      width: 30,
                      height: 40,
                      child: TextField(
                        controller: r2MinCtr,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                        decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                            isDense: true,
                            hintText: '00',
                            contentPadding: const EdgeInsets.all(5)
                        ),
                        onChanged: (t){
                          r2TimeChange(itm);
                        },
                      ),
                    ),

                    const Text(' : '),

                    SizedBox(
                      width: 30,
                      height: 40,
                      child: TextField(
                        controller: r2HourCtr,
                        maxLines: 1,
                        keyboardType: TextInputType.number,
                        inputFormatters: [LengthLimitingTextInputFormatter(2)],
                        decoration: AppDecoration.outlineBordersInputDecoration.copyWith(
                            isDense: true,
                            hintText: '00',
                            contentPadding: const EdgeInsets.all(5)
                        ),
                        onChanged: (t){
                          r2TimeChange(itm);
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void r1TimeChange(RelayModel itm){
    itm.duration = Duration(
      hours: MathHelper.clearToInt(r1HourCtr.text),
      minutes: MathHelper.clearToInt(r1MinCtr.text),
      seconds: MathHelper.clearToInt(r1SecCtr.text),
    );

    PlaceManager.updatePlaceToDb(widget.place);
  }

  void r2TimeChange(RelayModel itm){
    itm.duration = Duration(
      hours: MathHelper.clearToInt(r2HourCtr.text),
      minutes: MathHelper.clearToInt(r2MinCtr.text),
      seconds: MathHelper.clearToInt(r2SecCtr.text),
    );
    setState(() {});
    PlaceManager.updatePlaceToDb(widget.place);
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

  void eventListener({data}) {
    assistCtr.updateHead();
  }
}