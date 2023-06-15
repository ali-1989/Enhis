import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/pages/contact_manager_page.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/notifyToContactStatus.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:toggle_switch/toggle_switch.dart';


class EditPlacePage extends StatefulWidget {
  final PlaceModel place;

  const EditPlacePage({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<EditPlacePage> createState() => _EditPlacePageState();
}
///==================================================================================
class _EditPlacePageState extends StateBase<EditPlacePage> {
  late InputDecoration inputDecoration;
  late Color cColor;

  @override
  void initState(){
    super.initState();

    cColor = Colors.grey.shade300;

    inputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    );
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
              child: const Text('تنظیمات دستگاه').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        Expanded(
            child: ListView(
              children: [
                buildDeleteDeviceSection(),

                buildDeviceNameSection(),

                buildDeviceNumberSection(),

                buildDevicePasswordSection(),

                buildContactSection(),

                buildLanguageSection(),

                buildCallOnDisConnectPowerSection(),

                buildNotifyStateSection(),

                const SizedBox(height: 14),
              ],
            )
        ),
      ],
    );
  }

  Widget buildDeleteDeviceSection() {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: onDeleteDeviceClick,
            child: const Text('حذف دستگاه')
          ),
        ),
      ],
    );
  }

  Widget buildDeviceNameSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نام مکان').alpha().bold(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.place.name).bold().fsR(1),

                TextButton(
                    onPressed: onEditNameClick,
                    child: Text(AppMessages.edit)
                )
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildDeviceNumberSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شماره سیم کارت دستگاه').alpha().bold(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.place.simCardNumber).bold().fsR(1),

                TextButton(
                    onPressed: onEditSimCardNumberClick,
                    child: Text(AppMessages.edit)
                )
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildDevicePasswordSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رمز دستگاه').alpha().bold(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.place.currentPassword).bold().fsR(1),

                TextButton(
                    onPressed: onEditPasswordClick,
                    child: Text(AppMessages.edit)
                )
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildContactSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مخاطبین دستگاه').alpha().bold(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('در این بخش می توانید مخاطبین را مدیریت کنید').bold().fsR(1),

                TextButton(
                    onPressed: onManageContactClick,
                    child: Text(AppMessages.manage)
                )
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildLanguageSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('زبان سیم کارت دستگاه').alpha().bold(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleSwitch(
                  changeOnTap: false,
                  multiLineText: false,
                  totalSwitches: 2,
                  initialLabelIndex: widget.place.simLanguage,
                  activeBgColor: const [Colors.green],
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: const [
                    'انگلیسی',
                    'فارسی',
                  ],
                  onToggle: onChangeLanguage,
                ),
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildCallOnDisConnectPowerSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('پیامک هنگام قطع برق دستگاه').alpha().bold(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ToggleSwitch(
                  changeOnTap: false,
                  multiLineText: false,
                  totalSwitches: 2,
                  initialLabelIndex: widget.place.notifyOnDisPower,
                  activeBgColor: const [Colors.green],
                  activeFgColor: Colors.white,
                  inactiveFgColor: Colors.white,
                  labels: const [
                    'غیرفعال',
                    'فعال',
                  ],
                  onToggle: onChangePowerState,
                ),
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildNotifyStateSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نحوه ی اطلاع رسانی').alpha().bold(),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ColoredBox(
                  color: AppThemes.instance.currentTheme.accentColor,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: DropdownButton<NotifyToContactStatus>(
                        items: NotifyToContactStatus.values.map((e) => DropdownMenuItem<NotifyToContactStatus>(
                            value: e,
                            child: ColoredBox(
                                color: AppThemes.instance.currentTheme.accentColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                  child: SizedBox(width: 50, child: Text('Sim ${e.slot}')),
                                ))
                        )
                        ).toList(),
                        value: getDefaultSimCard(),
                        dropdownColor: AppThemes.instance.currentTheme.accentColor,
                        underline: const SizedBox(),
                        padding: EdgeInsets.zero,
                        isDense: true,
                        onChanged: (sim){
                          SettingsManager.localSettings.defaultSimSlot = sim?.slot?? 1;
                          SettingsManager.saveSettings(context: context);
                          assistCtr.updateHead();
                        }
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  void onEditNameClick() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('یک نام جدید وارد کنید').bold(),
        inputDecoration: inputDecoration,
        yesFn: (ctx, txt){
          FocusHelper.hideKeyboardByUnFocusRoot();

          final newValue = txt.trim();

          if(widget.place.currentPassword == newValue){
            AppNavigator.pop(ctx);
            return null;
          }

          if(newValue.length < 2){
            AppSnack.showError(context, AppMessages.nameIsShort);
            return null;
          }

          for(final p in PlaceManager.places){
            if(p.name == newValue){
              AppSnack.showError(context, 'نام تکراری است');
              return null;
            }
          }

          widget.place.name = TextHelper.subByCharCountSafe(newValue, 20);
          saveAndNotify();

          AppNavigator.pop(ctx);
          return null;
        }
    );
  }

  void onEditSimCardNumberClick() async {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('شماره خط تلفن دستگاه را وارد کنید').bold(),
        inputDecoration: inputDecoration,
        textInputType: TextInputType.phone,
        yesFn: (ctx, txt) {
          FocusHelper.hideKeyboardByUnFocusRoot();
          final newValue = txt.trim();

          if (widget.place.simCardNumber == newValue) {
            AppNavigator.pop(ctx);
            return false;
          }

          if(!Checker.validateMobile(newValue)){
            AppSnack.showError(context, AppMessages.simCardNumberIsInvalid);
            return true;
          }

          for (final p in PlaceManager.places) {
            if (p.simCardNumber == newValue) {
              AppSnack.showError(context, 'این شماره تلفن قبلا ثبت شده است');
              return false;
            }
          }

          widget.place.simCardNumber = newValue;
          saveAndNotify();
          AppNavigator.pop(ctx);
          return false;
        }
    );
  }

  void onEditPasswordClick() async {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('رمز جدید را وارد کنید (حداکثر 4 رقم)').bold(),
        inputDecoration: inputDecoration,
        textInputType: TextInputType.number,
        yesFn: (ctx, txt) {
          FocusHelper.hideKeyboardByUnFocusRoot();

          final newValue = txt.trim();

          if(widget.place.currentPassword == newValue){
            return null;
          }

          if(newValue.length < 2) {
            AppSnack.showError(context, 'حداقل 2 رقم وارد کنید');
            return false;
          }

          if(newValue.length > 4) {
            AppSnack.showError(context, 'حداکثر 4 رقم وارد کنید');
            return false;
          }

          SmsManager.sendSms('40*$newValue', widget.place, context).then((send) {
            if(send){
              widget.place.currentPassword = newValue;
              saveAndNotify();
            }
          });

          AppNavigator.pop(ctx);
          return false;
        }
    );
  }

  void onManageContactClick() async {
    RouteTools.pushPage(context, ContactManagerPage(place: widget.place));
  }

  void saveAndNotify() {
    PlaceManager.updatePlaceToDb(widget.place);
    EventNotifierService.notify(AppEvents.placeDataChanged);
    assistCtr.updateHead();
  }

  void onDeleteDeviceClick() async {
    final res = await AppDialogIris.instance.showYesNoDialog(
        context,
      desc: 'آیا دستگاه حذف شود؟',
    );

    if(res is bool && res && mounted){
      PlaceManager.places.removeWhere((element) => element.id == widget.place.id);
      PlaceManager.deletePlaceFromDb(widget.place);
      EventNotifierService.notify(AppEvents.placeDataChanged);
      AppNavigator.pop(context);
    }
  }

  void onChangeLanguage(int? index) async {
    if(index == null){
      return;
    }

    final send = await SmsManager.sendSms('53*$index', widget.place, context);

    if(send){
      widget.place.simLanguage = index;
      PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }

  void onChangePowerState(int? index) async {
    if(index == null){
      return;
    }

    final send = await SmsManager.sendSms('55*$index', widget.place, context);

    if(send){
      widget.place.notifyOnDisPower = index;
      PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }
}