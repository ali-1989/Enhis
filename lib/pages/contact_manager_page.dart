import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/contactLevel.dart';
import 'package:app/structures/models/contactModel.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/tools/app/appColors.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/views/dialogs/addContactDialog.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:flutter/material.dart';
import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_tools/features/overlayDialog.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';

class ContactManagerPage extends StatefulWidget {
  final PlaceModel place;

  const ContactManagerPage({
    Key? key,
    required this.place,
  }) : super(key: key);

  @override
  State<ContactManagerPage> createState() => _ContactManagerPageState();
}
///==================================================================================
class _ContactManagerPageState extends StateBase<ContactManagerPage> {

  @override
  void initState(){
    super.initState();

    EventNotifierService.addListener(AppEvents.contactDataChanged, listenToContactChange);
    sort();
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.contactDataChanged, listenToContactChange);

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
              child: const Text('مدیریت مخاطبین').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          color: Colors.amber,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const Text('حداکثر تعداد مخاطبین 10 مورد می باشد').fsR(2),
                const Text('هرچه تعداد مخاطبین کمتر باشد در مواقع لزوم زودتر اطلاع رسانی می شود', textAlign: TextAlign.center,).fsR(2),
              ],
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: widget.place.contacts.length < 10,
                child: ElevatedButton(
                    onPressed: onAddContactClick,
                    child: const Text('اضافه کردن')
                ),
              ),

              TextButton(
                  onPressed: onLevelsHelpClick,
                  child: const Text('راهنمای سطوح')
              ),

              ElevatedButton(
                  onPressed: onUpdateClick,
                  child: const Text('بروز رسانی')
              ),
            ],
          ),
        ),

        Expanded(
            child: ListView.builder(
              itemCount: widget.place.contacts.length,
              itemBuilder: itemBuilder,

            )
        ),
      ],
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    final itm = widget.place.contacts[index];

    return Card(
      color: Colors.purple.shade100,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('${itm.order} )  '),
                Text(itm.phoneNumber).bold().fsR(2),
              ],
            ),

            Visibility(
              visible: itm.phoneNumber != widget.place.adminPhoneNumber,
              child: ColoredBox(
                color: AppColors.dropDownBackground,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: DropdownButton<ContactLevel>(
                      items: ContactLevel.values.map((e) => DropdownMenuItem<ContactLevel>(
                          value: e,
                          child: ColoredBox(
                              color: AppColors.dropDownBackground,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: SizedBox(width: 40, child: Text('سطح ${e.getChar()}')),
                              ))
                      )
                      ).toList(),
                      value: itm.level,
                      dropdownColor: AppColors.dropDownBackground,
                      underline: const SizedBox(),
                      padding: EdgeInsets.zero,
                      isDense: true,
                      onChanged: (level){
                        onContactLevelChangeClick(level!, itm);
                      }
                  ),
                ),
              ),
            ),

            Visibility(
              visible: itm.phoneNumber != widget.place.adminPhoneNumber,
              child: GestureDetector(
                onTap: (){
                  onDeleteContactClick(itm);
                },
                  child: const Icon(AppIcons.delete, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onUpdateClick() {
    SmsManager.sendSms('91', widget.place, context);
  }

  void onAddContactClick() async {
    final contact = await AppDialogIris.instance.showIrisDialog(
        context,
      descView: const AddContactDialog(),
    );

    if(contact is ContactModel){
      int? order = findFreeOrder();

      if(order == null){
        if(!mounted){
          return;
        }

        AppSheet.showSheetOk(context, 'امکان اضافه کردن بیشتر از 10 مورد نیست');
        return;
      }

      callAddContact(contact.phoneNumber, order, contact.level);
    }
  }

  int? findFreeOrder(){
    int t = 2;

    for(var i=0; i < widget.place.contacts.length; i++){
      final c = widget.place.contacts[i];

      if(c.order == t){
        t++;
        i=0;

        if(t > 10){
          break;
        }
      }
    }

    return t < 11? t : null;
  }

  void callAddContact(String number, int order, ContactLevel level) async {
    final send = await SmsManager.sendSms('31*$order*$number${level.getChar()}', widget.place, context);

    if(send){
      final c = ContactModel();
      c.phoneNumber = number;
      c.level = level;
      c.order = order;

      widget.place.contacts.add(c);
      PlaceManager.updatePlaceToDb(widget.place);
      assistCtr.updateHead();
    }
  }

  void sort(){
    widget.place.contacts.sort((e1, e2){
      if(e1.order == e2.order){
        return 0;
      }

      return e1.order > e2.order? 1 : -1;
    });
  }

  void listenToContactChange({data}){
    sort();
    assistCtr.updateHead();
  }

  void onDeleteContactClick(ContactModel itm) async {
    final res = await AppDialogIris.instance.showYesNoDialog(
        context,
      desc: 'آیا مخاطب حذف شود؟',
      yesFn: (_){
          return true;
      }
    );

    if(res is bool && res){
      callDeleteContact(itm);
    }
  }

  void callDeleteContact(ContactModel cm) async {
    final send = await SmsManager.sendSms('30*${cm.order}*D', widget.place, context);

    if(send){
      widget.place.contacts.removeWhere((element) => element.order == cm.order);
      PlaceManager.updatePlaceToDb(widget.place);
      sort();
      assistCtr.updateHead();
    }
  }

  void onLevelsHelpClick() {
    const txt1 = 'چهار سطح وجود دارد، به ترتیب از بالا بیشترین دسترسی را دارد.';
    const txt2 = '* سطح A: دریافت پیامک و تماس/فعال و غیرفعال کردن دستگاه/دریافت گزارش/دسترسی به تنظیمات';
    const txt3 = '* سطح B: دریافت پیامک و تماس/فعال و غیرفعال کردن دستگاه/دریافت گزارش';
    const txt4 = '* سطح C: دریافت پیامک و تماس/فعال و غیرفعال کردن دستگاه';
    const txt5 = '* سطح D: دریافت پیامک و تماس';

    OverlayDialog.showMiniInfo(context,
      builder: (_, c){
        return c;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const Text(txt1).bold().fsR(3),
          const SizedBox(height: 10),

          const Text(txt2).fsR(1),
          const Text(txt3).fsR(1),
          const Text(txt4).fsR(1),
          const Text(txt5).fsR(1),
        ],
      ),
    );
  }

  void onContactLevelChangeClick(ContactLevel level, ContactModel contact) async {
    if(contact.level == level){
      return;
    }

    final send = await SmsManager.sendSms('31*${contact.order}*${level.getChar()}', widget.place, context);

    if(send){
      contact.level = level;
      PlaceManager.updatePlaceToDb(widget.place);

      assistCtr.updateHead();
    }
  }
}
