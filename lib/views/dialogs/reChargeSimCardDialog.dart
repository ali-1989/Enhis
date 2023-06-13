
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:flutter/material.dart';

typedef OnApply = void Function(String txt, BuildContext context);
///=============================================================================
class RechargeSimCardDialog extends StatefulWidget {
  final OnApply onApplyClick;

  const RechargeSimCardDialog({
    super.key,
    required this.onApplyClick,
  });

  @override
  State<RechargeSimCardDialog> createState() => _RechargeSimCardDialogState();
}
///=============================================================================
class _RechargeSimCardDialogState extends State<RechargeSimCardDialog> {
  late TextEditingController txtCtr;

  @override
  void initState(){
    super.initState();

    txtCtr = TextEditingController();
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
        const Text('لطفا کد شارژ را وارد کنید').bold().fsR(2),
        const SizedBox(height: 25),

        TextField(
          controller: txtCtr,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(),
            disabledBorder: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(),
          ),
        ),

        const SizedBox(height: 15),

        ElevatedButton(
            onPressed: (){
              widget.onApplyClick(txtCtr.text, context);
            },
            child: const Text('ارسال')
        )
      ],
    );
  }
}
