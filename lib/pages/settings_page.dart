import 'package:app/managers/settingsManager.dart';
import 'package:app/pages/add_place_page.dart';
import 'package:app/services/lock_service.dart';
import 'package:app/services/sms_service.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appSheet.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/components/number_lock_screen.dart';
import 'package:app/views/states/backBtn.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/features/overlayDialog.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/widgets/optionsRow/checkRow.dart';
import 'package:sms_advanced/sms_advanced.dart';

class SettingsPage extends StatefulWidget {

  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}
///==================================================================================
class _SettingsPageState extends StateBase<SettingsPage> {
  List<SimCard> simCards = [];
  bool canUseBiometric = false;

  @override
  void initState(){
    super.initState();

    SmsService.getSimCards().then((value){
      simCards = value;
      assistCtr.updateHead();
    });

    LockService.hasBiometrics().then((value){
      if(value){
        canUseBiometric = true;
        assistCtr.updateHead();
      }
    });
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
              child: const Text('تنظیمات برنامه').bold().fsR(4),
            ),

            const BackBtn(),
          ],
        ),

        Expanded(
            child: ListView(
              children: [
                buildAddLocationSection(),

                buildSecuritySection(),

                buildSimCardSection(),
              ],
            )
        ),
      ],
    );
  }

  Widget buildAddLocationSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مدیریت دستگاه ها').bold().fsR(2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade300),
            ),
            const Text('می توانید دستگاه های بیشتری اضافه کنید').alpha(),

            ElevatedButton(
                onPressed: onAddNewPlaceClick,
                child: const Text('اضافه کردن')
            ),
          ],
        ),
      ),
    );
  }

  void onAddNewPlaceClick() {
    RouteTools.pushPage(context, const AddPlacePage());
  }

  Widget buildSecuritySection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('امنیت برنامه').bold().fsR(2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade300),
            ),
            const Text('می توانید برای ورود به برنامه قفل قرار دهید').alpha(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CheckBoxRow(
                    value: SettingsManager.settingsModel.unLockByNumber,
                    description: const Text('استفاده از قفل عددی'),
                    onChanged: (v){
                      if(v == true){
                        if(SettingsManager.settingsModel.appNumberLock == null){
                          gotoNumberLockScreen();
                        }
                      }
                      else {
                        SettingsManager.settingsModel.unLockByNumber = false;
                        SettingsManager.settingsModel.appNumberLock = null;
                        SettingsManager.saveSettings(context: context);
                        assistCtr.updateHead();
                      }
                    }
                ),

                Visibility(
                  visible: SettingsManager.settingsModel.unLockByNumber,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      padding: EdgeInsets.zero,
                      alignment: Alignment.centerLeft,
                    ),
                      onPressed: onChangePasswordClick,
                      child: const Text('تغییر')
                  ),
                )
              ],
            ),

            Visibility(
              visible: canUseBiometric,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CheckBoxRow(
                        value: SettingsManager.settingsModel.unLockByBiometric,
                        description: const Text('استفاده از بیومتریک (اثر انگشت و ...)'),
                        onChanged: (v){
                          if(v == true){
                            checkBiometric();
                          }
                          else {
                            SettingsManager.settingsModel.unLockByBiometric = false;
                            SettingsManager.saveSettings(context: context);
                            assistCtr.updateHead();
                          }
                        }
                    ),

                    Builder(
                      builder: (c_) {
                        return GestureDetector(
                            onTap: (){
                              onBiometricHelpClick(c_);
                            },
                            child: const Icon(AppIcons.questionMarkCircle, size: 16)
                        );
                      }
                    ),
                  ],
                ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSimCardSection(){
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      color: Colors.grey.shade200,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مدیریت پیامک').bold().fsR(2),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Divider(color: Colors.grey.shade300),
            ),

            CheckBoxRow(
                value: SettingsManager.settingsModel.askSndSmsEveryTime,
                description: const Text('قبل از ارسال پیامک، تایید گرفته شود'),
                onChanged: (v){
                  SettingsManager.settingsModel.askSndSmsEveryTime = v;
                  SettingsManager.saveSettings(context: context);
                  assistCtr.updateHead();
                }
            ),

            Builder(
                builder: (_){
                  if(simCards.length < 2){
                    return const SizedBox();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: Row(
                      children: [
                        const Text('سیم کارت پیش فرض'),

                        const SizedBox(width: 14),

                        ColoredBox(
                          color: AppThemes.instance.currentTheme.accentColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: DropdownButton<SimCard>(
                                items: simCards.map((e) => DropdownMenuItem<SimCard>(
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
                                  SettingsManager.settingsModel.defaultSimSlot = sim?.slot?? 1;
                                  SettingsManager.saveSettings(context: context);
                                  assistCtr.updateHead();
                                }
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                }
            )

          ],
        ),
      ),
    );
  }

  SimCard? getDefaultSimCard() {
    if(SettingsManager.settingsModel.defaultSimSlot == null){
      return simCards.first;
    }

    for(final sim in simCards){
      if(sim.slot == SettingsManager.settingsModel.defaultSimSlot){
        return sim;
      }
    }

    return simCards.first;
  }

  void gotoNumberLockScreen() async {
    final page = NumberLockScreen(
      onNewPassword: (p){
        SettingsManager.settingsModel.appNumberLock = p;
        SettingsManager.saveSettings(context: context);

      },
      createCodeDescription: 'لطفا یک رمز وارد کنید',
      confirmCreateCodeDescription: 'لطفا رمز را دوباره وارد کنید',
    );

    await RouteTools.pushPage(context, page);

    if(SettingsManager.settingsModel.appNumberLock != null && mounted){
      SettingsManager.settingsModel.unLockByNumber = true;
      SettingsManager.saveSettings(context: context);
      assistCtr.updateHead();
    }
  }

  void onChangePasswordClick() {
    gotoNumberLockScreen();
  }

  void checkBiometric() async {
    var bio = await LockService.hasAnySecureLock();

    if(!bio && mounted){
      AppSheet.showSheetOk(context, 'شما هیچ قفلی (عدد ، الکو و ...) برای گوشی تنظیم نکرده اید.ابتدا وارد تنظیمات گوشی شوید و یک قفل قرار دهید ، سپس دوباره اقدام کنید');
      return;
    }

    bio = await LockService.isSetFinger();

    if(!bio && mounted){
      AppSheet.showSheetOk(context, 'شما قفل بیومتریک برای گوشی تنظیم نکرده اید.ابتدا وارد تنظیمات گوشی شوید و بیومتریک را فعال کنید ، سپس دوباره اقدام کنید');
      return;
    }

    SettingsManager.settingsModel.unLockByBiometric = true;
    SettingsManager.saveSettings(context: context);
    assistCtr.updateHead();
  }



  void onBiometricHelpClick(BuildContext anchor) {
    const txt1 = 'برای فعال کردن قفل بیومتریک:';
    const txt2 = '* ابتدا باید یکی از حالت های قفل (الکو یا پین کد) را برای گوشی فعال کنید';
    const txt3 = '* سپس قفل اثر انگشت را بر روی گوشی فعال کنید و در آخر این گرینه را فعال کنید';

    OverlayDialog.showMiniInfo(context,
        builder: (_, c){
          return c;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(txt1).bold(),
          const SizedBox(height: 10),

          const Text(txt2),
          const Text(txt3),
        ],
      ),
    );
  }
}
