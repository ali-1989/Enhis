
import 'package:app/structures/enums/contactLevel.dart';
import 'package:app/structures/models/contactModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/api/checker.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';

class AddContactDialog extends StatefulWidget {

  const AddContactDialog({
    super.key,
  });

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}
///=============================================================================
class _AddContactDialogState extends State<AddContactDialog> {
  late TextEditingController txtCtr;
  late InputDecoration inputDecor;
  String phoneNumber = '';
  ContactLevel contactLevel = ContactLevel.levelA;

  @override
  void initState(){
    super.initState();

    txtCtr = TextEditingController();
    inputDecor = const InputDecoration(
      border: OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(),
      focusedBorder: OutlineInputBorder(),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 5),
    );
  }

  @override
  void dispose(){
    txtCtr.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        const Text('اضافه کردن مخاطب').bold().fsR(3),
        const SizedBox(height: 20),

        Align(
          alignment: Alignment.centerRight,
            child: const Text('شماره ی مخاطب  را وارد کنید').bold()
        ),

        const SizedBox(height: 8),

        TextField(
          controller: txtCtr,
          keyboardType: TextInputType.phone,
          decoration: inputDecor,
          onChanged: (t){
            phoneNumber = t;
          },
        ),

        const SizedBox(height: 20),
        Align(
            alignment: Alignment.centerRight,
            child: const Text('سطح کاربر را انتخاب کنید').bold()
        ),
        const SizedBox(height: 8),

        Align(
          alignment: Alignment.centerRight,
          child: ColoredBox(
            color: AppDecoration.dropDownBackground,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: DropdownButton<ContactLevel>(
                  items: ContactLevel.values.map((e) => DropdownMenuItem<ContactLevel>(
                      value: e,
                      child: ColoredBox(
                          color: AppDecoration.dropDownBackground,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: SizedBox(width: 40, child: Text('سطح ${e.getChar()}')),
                          ))
                  )
                  ).toList(),
                  value: contactLevel,
                  dropdownColor: AppDecoration.dropDownBackground,
                  underline: const SizedBox(),
                  padding: EdgeInsets.zero,
                  isDense: true,
                  onChanged: (level){
                    contactLevel = level!;
                    setState(() {});
                  }
              ),
            ),
          ),
        ),

        const SizedBox(height: 30),

        SizedBox(
          width: 120,
          child: ElevatedButton(
              onPressed: (){
                FocusHelper.hideKeyboardByUnFocusRoot();

                if(phoneNumber.isEmpty){
                  AppSnack.showError(context, 'شماره ی مخاطب را وارد کنید');
                  return;
                }

                if(!Checker.validateMobile(phoneNumber)){
                  AppSnack.showError(context, 'شماره ی وارد شده صحیح نیست');
                  return;
                }

                final contact = ContactModel();
                contact.phoneNumber = phoneNumber;
                contact.level = contactLevel;

                AppNavigator.pop(context, result: contact);
              },
              child: const Text('ارسال')
          ),
        )
      ],
    );
  }
}
