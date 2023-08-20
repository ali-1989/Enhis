import 'package:app/tools/app/appToast.dart';
import 'package:app/views/pages/relay_page.dart';
import 'package:app/views/pages/zone_page.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/callAction/manageCallAction.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/mathHelper.dart';
import 'package:iris_tools/api/helpers/open_helper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/dateSection/dateHelper.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/text/titleInfo.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/views/pages/contact_manager_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/notifyToContactStatus.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/backBtn.dart';

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
  final ClickCounter clickCounter = ClickCounter(const Duration(seconds: 3), 3);

  @override
  void initState(){
    super.initState();

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

                buildZoneSection(),

                buildRelaySection(),

                buildContactSection(),

                buildLanguageSection(),

                buildCallOnDisConnectPowerSection(),

                buildNotifyStateSection(),

                buildSirenSection(),

                buildChargeReportSection(),

                buildBatteryReportSection(),

                buildInstallerSection(),

                buildWarrantySection(),

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
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نام مکان').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

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
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شماره سیم کارت دستگاه').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

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
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رمز دستگاه').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

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
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مخاطبین دستگاه').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: const Text('در این بخش می توانید مخاطبین را مدیریت کنید', maxLines: 2).bold().fsR(1)
                ),

                const SizedBox(width: 5),

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
      color: AppDecoration.cardSectionsColor,
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
      color: AppDecoration.cardSectionsColor,
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
      color: AppDecoration.cardSectionsColor,
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
                  color: AppDecoration.dropDownBackground,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: DropdownButton<NotifyToContactStatus>(
                        items: NotifyToContactStatus.values.map((e) => DropdownMenuItem<NotifyToContactStatus>(
                            value: e,
                            child: ColoredBox(
                                color: AppDecoration.dropDownBackground,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                  child: Text(e.getHumanName()),
                                ))
                        )
                        ).toList(),
                        value: widget.place.notifyToContactStatus,
                        dropdownColor: AppDecoration.dropDownBackground,
                        underline: const SizedBox(),
                        padding: EdgeInsets.zero,
                        isDense: true,
                        onChanged: (state){
                          onChangeNotifyState(state!);
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

  Widget buildZoneSection() {
    return Card(
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مدیریت بخش زون ها').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('در این بخش مناطق را مدیریت کنید').bold(),

                TextButton(
                  onPressed: onEditZoneClick,
                  child: Text(AppMessages.manage)
                ),
                ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildRelaySection() {
    return Card(
      color: AppDecoration.cardSectionsColor,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مدیریت بخش فرمان (رله)').alpha().bold(),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: const Text('می توانید دستوراتی مثل باز شدن درب را تنظیم کنید').bold()
                ),

                const SizedBox(width: 8),

                TextButton(
                  onPressed: onEditRelayClick,
                  child: Text(AppMessages.manage)
                ),
                ],
            ),

            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }

  Widget buildSirenSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppDecoration.cardSectionsColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('آژیر').bold().fsR(2),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(title: 'مدت زمان آژیر کشیدن: ', info: '${widget.place.sirenDurationMinutes} دقیقه'),

                TextButton(
                    onPressed: onChangeSirenDuration,
                    child: const Text('تغییر')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChargeReportSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppDecoration.cardSectionsColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('گزارش دوره ای موجودی').bold().fsR(2),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(title: 'تعداد فعلی: ', info: '${widget.place.smsCountReport} پیامک'),

                TextButton(
                    onPressed: onChangeSmsReportCount,
                    child: const Text('تغییر')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBatteryReportSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppDecoration.cardSectionsColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('گزارش دوره ای باطری').bold().fsR(2),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(title: 'مدت فعلی: ', info: '${widget.place.batteryReportDuration} دقیقه'),

                TextButton(
                    onPressed: onChangeBatteryReportDuration,
                    child: const Text('تغییر')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInstallerSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppDecoration.cardSectionsColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('اطلاعات پشتیبان').bold().fsR(2),

                GestureDetector(
                    onTap: onHiddenHelpClick,
                    behavior: HitTestBehavior.translucent,
                    child: const Icon(AppIcons.dotsHor)
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TitleInfo(title: 'نام: ', info: widget.place.supportName),

                TextButton(
                    onPressed: onChangeInstallerName,
                    child: const Text('تغییر')
                )
              ],
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: (){
                    OpenHelper.makePhoneCall(widget.place.supportPhoneNumber);
                  },
                  child: Row(
                    children: [
                      TitleInfo(title: 'شماره تماس: ', info: widget.place.supportPhoneNumber),
                      const SizedBox(width: 8),
                      const Icon(AppIcons.callPhone, color: Colors.blueAccent),
                    ],
                  ),
                ),

                TextButton(
                    onPressed: onChangeInstallerMobile,
                    child: const Text('تغییر')
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildWarrantySection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: AppDecoration.cardSectionsColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('اطلاعات گارانتی').bold().fsR(2),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade400),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('تاریخ اتمام: ').bold(),
                    Text('${widget.place.getWarrantyText()} ,  '),
                    Text(widget.place.getLeftWarrantyText()),
                  ],
                ),

                Visibility(
                  visible: widget.place.warrantyEndTime == null,
                  child: TextButton(
                      onPressed: onChangeWarranty,
                      child: const Text('ثبت')
                  ),
                )
              ],
            ),
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
        mainButton: (ctx, txt){
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
        }
    );
  }

  void onEditSimCardNumberClick() async {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('شماره خط تلفن دستگاه را وارد کنید').bold(),
        inputDecoration: inputDecoration,
        textInputType: TextInputType.phone,
        mainButton: (ctx, txt) {
          FocusHelper.hideKeyboardByUnFocusRoot();
          final newValue = txt.trim();

          if (widget.place.simCardNumber == newValue) {
            AppNavigator.pop(ctx);
            return null;
          }

          if(!Checker.validateMobile(newValue)){
            AppSnack.showError(context, AppMessages.simCardNumberIsInvalid);
            return null;
          }

          for (final p in PlaceManager.places) {
            if (p.simCardNumber == newValue) {
              AppSnack.showError(context, 'این شماره تلفن قبلا ثبت شده است');
              return null;
            }
          }

          widget.place.simCardNumber = newValue;
          saveAndNotify();
          AppNavigator.pop(ctx);
        }
    );
  }

  void onEditPasswordClick() async {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('رمز جدید را وارد کنید (حداکثر 4 رقم)').bold(),
        inputDecoration: inputDecoration,
        textInputType: TextInputType.number,
        mainButton: (ctx, txt) async {
          FocusHelper.hideKeyboardByUnFocusRoot();
          await System.wait(const Duration(milliseconds: 500));
          final newValue = txt.trim();

          if(widget.place.currentPassword == newValue){
            return null;
          }

          if(newValue.length < 2) {
            AppSnack.showError(context, 'حداقل 2 رقم وارد کنید');
            return null;
          }

          if(newValue.length > 4) {
            AppSnack.showError(context, 'حداکثر 4 رقم وارد کنید');
            return null;
          }

          SmsManager.sendSms('40*$newValue', widget.place, context).then((send) {
            if(send){
              widget.place.currentPassword = newValue;
              saveAndNotify();
            }
          });

          AppNavigator.pop(ctx);
        }
    );
  }

  void onManageContactClick() async {
    RouteTools.pushPage(context, ContactManagerPage(place: widget.place));
  }

  void saveAndNotify() {
    PlaceManager.updatePlaceToDb(widget.place);
    assistCtr.updateHead();
  }

  void onDeleteDeviceClick() async {
    final res = await AppDialogIris.instance.showYesNoDialog(
        context,
      desc: 'آیا دستگاه حذف شود؟',
      yesFn: (_){
          return true;
      }
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

  void onChangeNotifyState(NotifyToContactStatus state) async {
    final sms = await SmsManager.sendSms('51*${state.getNumber()}', widget.place, context);

    if(sms){
      widget.place.notifyToContactStatus = state;
      PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }

  void onEditZoneClick() {
    RouteTools.pushPage(context, ZonePage(place: widget.place));

    /*AppDialogIris.instance.showIrisDialog(
        context,
      descView: ManageZoneDialog(place: widget.place),
      decoration: AppDialogIris.instance.dialogDecoration.copy()..widthFactor = 0.9,
    );*/
  }

  void onEditRelayClick() {
    RouteTools.pushPage(context, RelayPage(place: widget.place));

    /*AppDialogIris.instance.showIrisDialog(
      context,
      descView: ManageRelayDialog(place: widget.place),
      decoration: AppDialogIris.instance.dialogDecoration.copy()..widthFactor = 0.9,
    );*/
  }

  void onChangeInstallerName() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('نام پشتیبان یا نصاب').bold(),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        textInputType: TextInputType.text,
        mainButton: (ctx, txt) {
          FocusHelper.hideKeyboardByUnFocusRoot();
          widget.place.supportName = txt.trim();
          PlaceManager.updatePlaceToDb(widget.place);
          assistCtr.updateHead();
          AppNavigator.pop(ctx);
        }
    );
  }

  void onChangeInstallerMobile() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('شماره تماس پشتیبان یا نصاب').bold(),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        textInputType: TextInputType.phone,
        mainButton: (ctx, txt) {
          FocusHelper.hideKeyboardByUnFocusRoot();
          widget.place.supportPhoneNumber = txt.trim();
          PlaceManager.updatePlaceToDb(widget.place);
          assistCtr.updateHead();
          AppNavigator.pop(ctx);
        }
    );
  }

  void onHiddenHelpClick() async {
    /*if(clickCounter.touch()){
      final path = '${AppDirectories.getAppFolderInInternalStorage()}/help_hamkar.pdf';

      if(!FileHelper.existSync(path)) {
        await AssetsManager.assetsToFile('assets/pdf/help_hamkar.pdf', path);
      }

      OpenHelper.openFile(path, type: 'application/pdf');
    }*/

    AppDialogIris.instance.showTextInputDialog(
        context,
        mainButtonText: '   ورود  ',
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        descView: const Text('لطفا کلید ورود را وارد کنید').bold().fsR(1),
        mainButton: (ctx, txt) async{
          if(txt == 'enhis.ir'){
            final path = '${AppDirectories.getAppFolderInInternalStorage()}/help_hamkar.pdf';

            if(!FileHelper.existSync(path)) {
              await AssetsManager.assetsToFile('assets/pdf/help_hamkar.pdf', path);
            }

            OpenHelper.openFile(path, type: 'application/pdf');

            RouteTools.popTopView(context: ctx);
          }
          else {
            await FocusHelper.hideKeyboardByUnFocusRootWait();
            AppToast.showToast(ctx, 'صحیح نیست');
          }
        },
    );
  }

  void onChangeSirenDuration() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('مدت زمان آژیر کشیدن به دقیقه').bold(),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        textInputType: TextInputType.number,
        initValue: widget.place.sirenDurationMinutes.toString(),
        mainButton: (ctx, txt) async {
          FocusHelper.hideKeyboardByUnFocusRoot();
          await System.wait(const Duration(milliseconds: 500));

          final min = MathHelper.clearToInt(txt.trim());

          if((min < 1 || min > 99) && context.mounted){
            AppSnack.showInfo(context, 'مقدار وارد شده صحیح نیست');
            return;
          }

          AppNavigator.pop(ctx);
          await System.wait(const Duration(milliseconds: 250));

          sendSmsChangeSirenDuration(min);
        }
    );
  }

  void sendSmsChangeSirenDuration(int minutes) async {
    final send = await SmsManager.sendSms('41*$minutes', widget.place, context);

    if(send){
      widget.place.sirenDurationMinutes = minutes;
      PlaceManager.updatePlaceToDb(widget.place, notify: false);
      assistCtr.updateHead();
    }
  }

  void onChangeSmsReportCount() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('تعداد پیامک برای گزارش موجودی سیم کارت').bold(),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        textInputType: TextInputType.number,
        initValue: widget.place.smsCountReport.toString(),
        mainButton: (ctx, txt) async {
          FocusHelper.hideKeyboardByUnFocusRoot();
          await System.wait(const Duration(milliseconds: 500));

          final min = MathHelper.clearToInt(txt.trim());

          if((min < 5 || min > 99) && context.mounted){
            AppSnack.showInfo(context, 'مقدار وارد شده صحیح نیست');
            return;
          }

          AppNavigator.pop(ctx);
          await System.wait(const Duration(milliseconds: 250));

          sendSmsChangeSmsReportCount(min);
        }
    );
  }

  void sendSmsChangeSmsReportCount(int count) async {
    final send = await SmsManager.sendSms('43*$count', widget.place, context);

    if(send){
      widget.place.smsCountReport = count;
      PlaceManager.updatePlaceToDb(widget.place, notify: false);
      assistCtr.updateHead();
    }
  }

  void onChangeBatteryReportDuration() {
    AppDialogIris.instance.showTextInputDialog(
        context,
        descView: const Text('گزارش درصد باطری هر (دقیقه)').bold(),
        inputDecoration: AppDecoration.outlineBordersInputDecoration,
        textInputType: TextInputType.number,
        initValue: widget.place.batteryReportDuration.toString(),
        mainButton: (ctx, txt) async {
          FocusHelper.hideKeyboardByUnFocusRoot();
          await System.wait(const Duration(milliseconds: 500));

          final min = MathHelper.clearToInt(txt.trim());

          if((min < 1 || min > 99) && context.mounted){
            AppSnack.showInfo(context, 'مقدار وارد شده صحیح نیست');
            return;
          }

          AppNavigator.pop(ctx);
          await System.wait(const Duration(milliseconds: 250));

          sendSmsChangeBatteryReportDuration(min);
        }
    );
  }

  void sendSmsChangeBatteryReportDuration(int minutes) async {
    final send = await SmsManager.sendSms('44*$minutes', widget.place, context);

    if(send){
      widget.place.batteryReportDuration = minutes;
      PlaceManager.updatePlaceToDb(widget.place, notify: false);
      assistCtr.updateHead();
    }
  }

  void onChangeWarranty() async {
    /*final date = await AppDialogIris.instance.showIrisDialog(
        context,
        descView: SelectDateCalendarView(
          maxYearAsGregorian: 2030,
          minYearAsGregorian: 2022,
          title: 'توجه : فقط یک بار امکان وارد کردن تاریخ را دارید',
        ),
    );*/

    AppDialogIris.instance.showYesNoDialog(
        context,
      desc: 'توجه : فقط یک بار امکان ثبت را دارید. الان ثبت شود؟',
      yesFn: (ctx){
        widget.place.warrantyEndTime = DateHelper.getNowToUtc().add(const Duration(days: 365*2));
        PlaceManager.updatePlaceToDb(widget.place);
        setState(() {});
      }
    );

    /*if(date != null){
      widget.place.warrantyEndTime = date!;
      setState(() {});
    }*/
  }
}
