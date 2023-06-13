import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/contactLevel.dart';
import 'package:app/structures/models/contactModel.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/inputFormatter.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';

class AddPlacePage extends StatefulWidget {

  const AddPlacePage({
    Key? key,
  }) : super(key: key);

  @override
  State<AddPlacePage> createState() => _AddPlacePageState();
}
///==================================================================================
class _AddPlacePageState extends StateBase<AddPlacePage> {
  TextEditingController nameCtr = TextEditingController();
  TextEditingController numberCtr = TextEditingController();
  TextEditingController adminNumberCtr = TextEditingController();
  TextEditingController currentPasswordCtr = TextEditingController();
  TextEditingController newPasswordCtr = TextEditingController();
  late InputDecoration inputDecor;

  @override
  void initState(){
    super.initState();

    inputDecor = const InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    );

    currentPasswordCtr.addListener(() {
      assistCtr.updateHead();
    });
  }

  @override
  void dispose(){
    nameCtr.dispose();
    numberCtr.dispose();
    adminNumberCtr.dispose();
    currentPasswordCtr.dispose();
    newPasswordCtr.dispose();

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
              child: const Text('ثبت دستگاه جدید').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        Expanded(
            child: ListView(
              children: [
                buildDeviceNameInput(),

                buildDeviceNumberInput(),

                buildAdminNumberInput(),

                buildCurrentPasswordInput(),

                buildNewPasswordInput(),

                const SizedBox(height: 14),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: ElevatedButton(
                      onPressed: onRegisterClick,
                      child: const Text('ثبت دستگاه')
                  ),
                )
              ],
            )
        ),
      ],
    );
  }

  Widget buildDeviceNameInput() {
    return Card(
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نام مکان').bold().fsR(1),
            const Text('یک نام بنویسید. مثلا مغازه ، باغ ، خانه').alpha(),

            const SizedBox(height: 5),
            TextField(
              controller: nameCtr,
              textInputAction: TextInputAction.next,
              inputFormatters: [
                InputFormatter.inputFormatterMaxLen(20)
              ],
              decoration: inputDecor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDeviceNumberInput() {
    return Card(
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شماره سیم کارت').bold().fsR(1),
            const Text('شماره تلفن سیم کارت قرار داده شده در دستگاه').alpha(),

            const SizedBox(height: 5),
            TextField(
              controller: numberCtr,
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.phone,
              decoration: inputDecor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdminNumberInput() {
    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('شماره مدیر (اختیاری)').bold().fsR(1),
            const Text('می توانید شماره ی شخص کنترل کننده دستگاه را وارد کنید').alpha(),

            const SizedBox(height: 5),
            TextField(
              controller: adminNumberCtr,
              keyboardType: TextInputType.phone,
              decoration: inputDecor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCurrentPasswordInput() {
    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('رمز دستگاه').bold().fsR(1),
            const Text('اگر رمز پیش فرض دستگاه تغییر کرده، آن را وارد کنید').alpha(),

            const SizedBox(height: 5),
            TextField(
              controller: currentPasswordCtr,
              inputFormatters: [
                InputFormatter.inputFormatterMaxLen(12)
              ],
              keyboardType: TextInputType.text,
              decoration: inputDecor,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNewPasswordInput() {
    return Visibility(
      visible: currentPasswordCtr.text.trim().isEmpty,
      child: Card(
        color: Colors.grey.shade100,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('رمز جدید (اختیاری)').bold().fsR(1),
              const Text('بهتر است برای افزایش امنیت رمز دستگاه را عوض کنید').alpha(),

              const SizedBox(height: 5),
              TextField(
                controller: newPasswordCtr,
                inputFormatters: [
                  InputFormatter.inputFormatterMaxLen(12)
                ],
                keyboardType: TextInputType.text,
                decoration: inputDecor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onRegisterClick() async {
    final name = nameCtr.text.trim();
    final simNumber = numberCtr.text.trim();
    final adminNumber = adminNumberCtr.text.trim();
    final curPassword = currentPasswordCtr.text.trim();
    final newPassword = newPasswordCtr.text.trim();

    if(name.length < 2){
      AppSnack.showError(context, AppMessages.nameIsShort);
      return;
    }

    if(!Checker.validateMobile(simNumber)){
      AppSnack.showError(context, AppMessages.simCardNumberIsInvalid);
      return;
    }

    if(adminNumber.isNotEmpty && !Checker.validateMobile(adminNumber)){
      AppSnack.showError(context, AppMessages.adminNumberIsInvalid);
      return;
    }

    //showLoading();

    final p = PlaceModel();
    p.name = name;
    p.simCardNumber = simNumber;

    if(curPassword.isNotEmpty){
      p.currentPassword = curPassword;
    }
    else if(newPassword.isNotEmpty){
      p.newPassword = newPassword;
    }

    if(adminNumber.isNotEmpty){
      final cm = ContactModel();
      cm.phoneNumber = adminNumber;
      cm.level = ContactLevel.levelA;

      p.contacts.add(cm);
      p.adminPhoneNumber = adminNumber;
    }

    await AppDB.db.insert(AppDB.tbPlaces, p.toMap());

    await PublicAccess.fetchPlaces();

    EventNotifierService.notify(AppEvents.placeDataChanged);
    //hideLoading();

    if(!mounted){
      return;
    }

    AppSheet.showSheetOneAction(context, 'دستگاه ثبت شد', (){
      RouteTools.popTopView(context: context);
    });
  }
}
