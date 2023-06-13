import 'dart:async';

import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appSnack.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/views/components/number_pad.dart';
import 'package:flutter/material.dart';

typedef OnNewPassword = void Function(String pass);
typedef OnCorrectPassword = void Function(String pass);
///=============================================================================
class NumberLockScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showFingerPrint;
  final bool canBack;
  final String? correctPassword;
  final String? enterCodeDescription;
  final String? createCodeDescription;
  final String? confirmCreateCodeDescription;
  final TextStyle descriptionStyle;
  final OnNewPassword? onNewPassword;
  final OnCorrectPassword? onCorrectPassword;

  const NumberLockScreen({
    Key? key,
    this.onNewPassword,
    this.onCorrectPassword,
    this.correctPassword,
    this.showAppBar = false,
    this.canBack = false,
    this.showFingerPrint = false,
    this.enterCodeDescription,
    this.createCodeDescription,
    this.confirmCreateCodeDescription,
    this.descriptionStyle = const TextStyle(
      fontSize: 14,
    ),
  })
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NumberLockScreenState();
  }
}
///===============================================================================================================
class NumberLockScreenState extends State<NumberLockScreen> {
  bool isStateOne = true;
  String password = '';
  String createPassword = '';
  String description = '';
  StreamController<bool>? clearer;

  @override
  void initState() {
    super.initState();

    if(isInCreate()) {
      description = widget.createCodeDescription ?? '';
      clearer = StreamController<bool>();
    }
    else {
      description = widget.enterCodeDescription?? '';
    }
  }

  @override
  void dispose() {
    clearer?.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (){
        if(isInCreate()){
          return Future.value(true);
        }

        return Future.value(widget.canBack? true : false);
      },
      child: Scaffold(
        appBar: widget.showAppBar? AppBar() : null,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Text(description, style: widget.descriptionStyle),
              const SizedBox(height: 30),

              Expanded(
                child: NumberPad(
                  minPinLength: 4,
                  maxPinLength: 11,
                  clearSignal: clearer?.stream,
                  buttonColor: AppThemes.instance.currentTheme.accentColor,
                  showEnteredKeyAsStar: false,
                  showDefaultConfirmButton: false,
                  onChangedPin: (pin) {
                    password = pin;

                    if(!isInCreate()){
                      if(widget.correctPassword == password){
                        if(widget.onCorrectPassword != null){
                          widget.onCorrectPassword!.call(password);
                        }
                        else {
                          pop();
                        }
                      }
                    }
                  },
                  onConfirm: (pin, _) {},
                  bottomWidget: getBottomWidget(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void update(){
    if(mounted){
      setState(() {});
    }
  }

  bool isInCreate(){
    return widget.onNewPassword != null;
  }

  Widget getBottomWidget() {
    if(isInCreate()){
      return Column(
        children: [
          SizedBox(
            width: 120,
            child: ElevatedButton(
                onPressed: onCreateClick,
                child: Text(isStateOne ? AppMessages.next : AppMessages.save)
            ),
          ),

          TextButton(
              onPressed: pop,
              child: const Text('لغو')
          )
        ],
      );
    }

    return Visibility(
      visible: !isInCreate() && widget.showFingerPrint,
      child: const Icon(
        Icons.fingerprint,
        size: 40,
      ),
    );
  }

  void onCreateClick() {
    if(isStateOne) {
      if (password.length < 4) {
        AppSnack.showError(context, 'حداقل 4 رقم وارد کنید');
        return;
      }

      createPassword = password;
      description = widget.confirmCreateCodeDescription ?? '';
      isStateOne = false;
      clearer?.sink.add(true);

      update();
    }
    else {
      if(password != createPassword){
        AppSnack.showError(context, 'رمز یکسان نیست');
        return;
      }

      widget.onNewPassword!.call(password);
      pop();
    }
  }

  void pop() {
    Navigator.pop(context);
  }
}
