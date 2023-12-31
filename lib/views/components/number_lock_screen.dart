import 'dart:async';

import 'package:flutter/material.dart';

import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/widgets/number_pad.dart';

import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_snack.dart';
import 'package:app/tools/app/app_themes.dart';

typedef OnNewPassword = void Function(String pass);
typedef OnCorrectPassword = void Function(String pass);
///=============================================================================
class NumberLockScreen extends StatefulWidget {
  final bool showAppBar;
  final bool showFingerPrint;
  final bool canBack;
  final bool exitAppOnBack;
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
    this.exitAppOnBack = false,
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

        if(widget.exitAppOnBack && !widget.canBack) {
          System.exitApp();
        }

        return Future.value(widget.canBack);
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
      child: const Column(
        children: [
          SizedBox(height: 20),
          Text('می توانید با اثر انگشت وارد شوید'),

          SizedBox(height: 10),
          Icon(
            Icons.fingerprint,
            size: 55,
            color: Colors.red,
          ),
        ],
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
