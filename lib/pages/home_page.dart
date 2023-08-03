import 'package:app/pages/contact_manager_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/appDb.dart';
import 'package:app/tools/app/appDirectories.dart';
import 'package:app/views/dialogs/remoteManageDialog.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/open_helper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/pages/add_place_page.dart';
import 'package:app/pages/edit_place_page.dart';
import 'package:app/pages/relay_page.dart';
import 'package:app/pages/settings_page.dart';
import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/deviceStatus.dart';
import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appDecoration.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/dialogs/changeZoneStatusDialog.dart';
import 'package:app/views/dialogs/reChargeSimCardDialog.dart';
import 'package:showcaseview/showcaseview.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
///==================================================================================
class _HomePageState extends StateBase<HomePage> {
  PlaceModel? currentPlace;
  Color cColor = AppDecoration.secondColor;
  final settingCaseKey = GlobalKey();
  final helpCaseKey = GlobalKey();
  final placeSettingCaseKey = GlobalKey();
  final reloadCaseKey = GlobalKey();
  final relayCaseKey = GlobalKey();


  @override
  void initState(){
    super.initState();

    currentPlace = PlaceManager.fetchSavedPlace();

    if(currentPlace != null){
      SmsManager.listenToDeviceMessage();
    }
    
    EventNotifierService.addListener(AppEvents.placeDataChanged, listenPlacesDataChanged);
    IrisNavigatorObserver.addEventListener(navigateState);
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.placeDataChanged, listenPlacesDataChanged);

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
    if(PlaceManager.places.isEmpty) {
      return buildEmptyPlaces();
    }

    /*final tt = Theme.of(context);
    Future.delayed(Duration(seconds: 1), (){
      print('---------> ${tt.textTheme.bodySmall?.fontSize}');
      print('----p-----> ${FontManager.instance.getPlatformFont().size}');
    });*/
    return Column(
      children: [
        buildTopSection(),

        const SizedBox(height: 12),

        /// center section
        Expanded(
            child: Stack(
              children: [
                Card(
                  color: Colors.grey.shade100,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
                    child: ListView(
                      children: [
                        /// update status
                        buildUpdateStatusSection(),

                        const SizedBox(height: 14),

                        /// device state
                        buildDeviceStatusSection(),

                        const SizedBox(height: 6),

                        /// batter/power
                        buildPowerBatterySection(),

                        const SizedBox(height: 6),

                        /// sim card state
                        buildSimCardSection(),

                        const SizedBox(height: 6),

                        /// Zones state
                        buildZonesStateSection(),
                        const SizedBox(height: 6),
                        buildZonesStatusSection(),

                        const SizedBox(height: 6),
                        buildRemoteAndContactSection(),

                        Visibility(
                          visible: currentPlace!.supportPhoneNumber.isNotEmpty,
                            child: buildContactWithInstaller()
                        ),
                      ],
                    ),
                  ),
                ),

                /// location-name
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Showcase(
                      key: placeSettingCaseKey,
                      description: 'تنظیمات دستگاه اینجاست',
                      targetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: ActionChip(
                          labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
                          onPressed: onEditPlaceClick,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(currentPlace!.name).bold().fsR(2),
                              ),
                              const SizedBox(width: 4),
                              const CustomCard(
                                color: Colors.green,
                                  radius: 25,
                                  padding: EdgeInsets.all(2),
                                  child: Icon(AppIcons.settings,
                                    color: Colors.white, size: 18)
                              )
                            ],
                          )
                      ),
                    ),
                  ),
                ),
              ],
            )
        ),


        /// bottom section
        Builder(
            builder: (_){
              if(PlaceManager.places.length < 2){
                return const SizedBox();
              }

              return buildLocationsSection();
            }
        )
      ],
    );
  }

  Widget buildTopSection() {
    return Stack(
      children: [
        /// logo
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.appIcon, width: 90, height: 70),
          ],
        ),

        /// setting Icon
        Positioned(
            top: 2,
            left: 2,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Showcase(
                  key: settingCaseKey,
                  description: 'تنظیمات برنامه اینجاست',
                  child: IconButton(
                    style: IconButton.styleFrom(
                      visualDensity: const VisualDensity(vertical: -4),
                    ),
                      onPressed: onSettingClick,
                      visualDensity: const VisualDensity(vertical: -4),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      icon: const Icon(AppIcons.settings)
                  ),
                ),

                Showcase(
                  key: helpCaseKey,
                  description: 'اگر نیاز به راهنمایی دارید، اینجاست',
                  child: TextButton(
                    style: TextButton.styleFrom(
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: const VisualDensity(vertical: -4),
                    ),
                    onPressed: onPdfHelpClick,
                    child: const Text('راهنما').color(Colors.blueAccent),
                  ),
                )


              ],
            )
        )
      ],
    );
  }

  Widget buildUpdateStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// last update
        Row(
          children: [
            Column(
              children: [
                Text(AppMessages.lastUpdate),
                Text(currentPlace!.getLastUpdateDate()).color(currentPlace!.getUpdateColor())
                .bold().fsR(2),
              ],
            ),
          ],
        ),

        /// relay
        Visibility(
          visible: currentPlace!.useOfRelays,
          child: Showcase(
            key: relayCaseKey,
            description: 'از اینجا دستور رله را اجرا کنید',
            targetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: GestureDetector(
                onTap: onRelayClick,
                child: CustomCard(
                  color: AppDecoration.mainColor,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: const Text('کلید (رله)').color(Colors.white)
                )
            ),
          ),
        )
      ],
    );
  }

  Widget buildDeviceStatusSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppMessages.deviceStatus),

                Showcase(
                  key: reloadCaseKey,
                  description: 'با لمس این دکمه وضعیت دستگاه به روز رسانی می شود',
                  targetPadding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onUpdateInfoClick,
                    child: Row(
                      children: [
                        const Text('بروز رسانی').color(Colors.blue).bold(),
                        const SizedBox(width: 5),
                        const Icon(AppIcons.refreshCircle, color: Colors.blue, size: 18)
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                    onTap: onDeviceStatusHelpClick,
                    child: const Icon(AppIcons.questionMarkCircle, size: 22, color: Colors.orange)
                ),
              ],
            ),

            const SizedBox(height: 10),

            Builder(
              builder: (context) {
                /*if(currentPlace!.deviceStatus == DeviceStatus.unKnow){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text('نا مشخص').alpha(),
                  );
                }*/

                return SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ToggleSwitch(
                        minHeight: 45.0,
                        minWidth: 110,
                        initialLabelIndex: currentPlace!.getDeviceStatsForSwitchButtonA(),
                        cornerRadius: 8.0,
                        totalSwitches: 2,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey.shade400,
                        inactiveFgColor: Colors.white,
                        iconSize: 14.0,
                        borderWidth: 1.0,
                        multiLineText: false,
                        changeOnTap: false,
                        labels: const [
                          'فعال',
                          'غیرفعال',
                        ],
                        activeBgColors: const [
                          [Colors.green],
                          [Colors.red],
                        ],
                        onToggle: (index) {
                          onChangeDeviceStatusClick(index?? 0);
                        },
                      ),

                      ToggleSwitch(
                        minHeight: 45.0,
                        minWidth: 110,
                        initialLabelIndex: currentPlace!.getDeviceStatsForSwitchButtonB(),
                        cornerRadius: 8.0,
                        totalSwitches: 2,
                        activeFgColor: Colors.white,
                        inactiveBgColor: Colors.grey.shade400,
                        inactiveFgColor: Colors.white,
                        iconSize: 14.0,
                        borderWidth: 1.0,
                        multiLineText: false,
                        changeOnTap: false,
                        labels: const [
                          'نیمه فعال',
                          'بی صدا',
                        ],
                        activeBgColors: const [
                          [Colors.orange],
                          [Colors.blue]
                        ],
                        onToggle: (index) {
                          onChangeDeviceStatusClick((index?? 0)+2);
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPowerBatterySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// battery state
        Card(
          color: cColor,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.batteryStatus),

                const SizedBox(height: 6),

                Text(currentPlace!.getBatteryStateText()).bold(),
              ],
            ),
          ),
        ),

        /// listening
        Card(
          color: ColorHelper.changeHue(cColor),
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
          child: GestureDetector(
            onTap: onListeningClick,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppMessages.listening),

                  const SizedBox(height: 6),

                  const Icon(AppIcons.light),
                ],
              ),
            ),
          ),
        ),

        /// power state
        Card(
          color: cColor,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.powerStatus),

                const SizedBox(height: 6),

                Text(currentPlace!.getPowerState()).bold(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSimCardSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppMessages.simCardStatus),

                Row(
                  children: [
                    TextButton(
                        style: TextButton.styleFrom(
                          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: onGetSimCardBalance,
                        child: const Text('بروز رسانی')
                    ),


                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('موجودی شارژ').bold(),
                    const SizedBox(height: 4),
                    Text(currentPlace!.getSimCardCharge()).bold(),
                  ],
                ),

                Column(
                  children: [
                    ActionChip(
                      label: const Text('افزایش شارژ'),
                      onPressed: onReChargeSimCardClick,
                    )
                  ],
                ),

                Column(
                  children: [
                    const Text('آنتن دهی').bold(),
                    const SizedBox(height: 4),
                    Text(currentPlace!.getSimCardAntenna()).bold().color(currentPlace!.getSimCardAntennaColor()),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildZonesStateSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppMessages.zoneState),

                TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onUpdateInfoClick,
                    child: const Text('بروز رسانی')
                ),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: currentPlace!.zones.where((element) => element.show).map(mapStateZone).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildZonesStatusSection() {
    return Card(
      color: cColor,
      margin: const EdgeInsets.symmetric(horizontal: 0),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppMessages.zoneStatus),

                TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onZoneUpdateClick,
                    child: const Text('بروز رسانی')
                ),
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: currentPlace!.zones.where((element) => element.show).map(mapStatusZone).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapStateZone(ZoneModel zm){
    return Column(
      children: [
        Builder(
          builder: (context) {
            if(zm.name != null){
              return Text(TextHelper.subByCharCountSafe(zm.name, 8)).bold().fsR(1);
            }

            return Text('زون ${zm.number}').bold().fsR(1);
          }
        ),

        const SizedBox(height: 8),
        Text(zm.isOpen? '${AppMessages.open} ' : '∑ ${AppMessages.close}')
        .bold().fsR(2)
        .color(zm.isOpen? Colors.green : Colors.red),
      ],
    );
  }

  Widget mapStatusZone(ZoneModel zm){
    return Column(
      children: [
        Builder(
          builder: (context) {
            if(zm.name != null){
              return Text(TextHelper.subByCharCountSafe(zm.name, 8)).bold().fsR(1);
            }

            return Text('زون ${zm.number}').bold().fsR(1);
          }
        ),

        const SizedBox(height: 8),
        GestureDetector(
          onTap: (){
            onChangeZoneStatusClick(zm, currentPlace!);
          },
            child: Chip(
                elevation: 0,
                padding: EdgeInsets.zero,
                visualDensity: const VisualDensity(vertical: -4),
                label: Text('${zm.status.getHumanName()} ').color(Colors.white)
            )
        ),
      ],
    );
  }

  Widget buildRemoteAndContactSection(){
    return Row(
      children: [

        Expanded(
          child: GestureDetector(
            onTap: onRemoteManageClick,
            child: Card(
              color: cColor,
              elevation: 0,
              margin: const EdgeInsets.only(top: 8.0, bottom: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تعداد ریموت ها: ${currentPlace!.remoteCount?? 0}').bold(),

                    Icon(AppIcons.remote, color: AppThemes.instance.themeData.chipTheme.backgroundColor),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),
        Expanded(
          child: GestureDetector(
            onTap: (){
              RouteTools.pushPage(context, ContactManagerPage(place: currentPlace!));
            },
            child: Card(
              color: cColor,
              elevation: 0,
              margin: const EdgeInsets.only(top: 8.0, bottom: 4),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('تعداد مخاطبین: ${currentPlace!.contactCount?? 0}').bold(),

                    Icon(AppIcons.accountDoubleCircle, color: AppThemes.instance.themeData.chipTheme.backgroundColor),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildContactWithInstaller(){
    return GestureDetector(
      onTap: (){
        OpenHelper.makePhoneCall(currentPlace!.supportPhoneNumber);
      },
      child: Card(
        color: ColorHelper.changeHue(AppDecoration.secondColor),
        elevation: 0,
        margin: const EdgeInsets.only(top: 8.0, bottom: 4),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('تماس با پشتیبان').color(Colors.white).bold(),

              const Icon(AppIcons.callPhone, color: Colors.pink),
            ],
          ),
        ),
      ),
    );
  }

  void onUpdateInfoClick() {
    SmsManager.sendSms('90', currentPlace!, context);
  }

  void onZoneUpdateClick() {
    SmsManager.sendSms('92', currentPlace!, context);
  }

  void onGetSimCardBalance() {
    SmsManager.getChargeBalance(currentPlace!, context);
  }

  void onListeningClick() {
    SmsManager.sendSms('62', currentPlace!, context);
  }

  void onReChargeSimCardClick() {
    void onApply(String txt, ctx){
      FocusHelper.hideKeyboardByUnFocusRoot();
      AppNavigator.pop(ctx);

      if(txt.trim().isNotEmpty){
        SmsManager.sendChargeCode(txt, currentPlace!, context);
      }
    }

    AppDialogIris.instance.showIrisDialog(
        context,
        descView: RechargeSimCardDialog(onApplyClick: onApply),
    );
  }

  void onDeviceStatusHelpClick() {
    const txt1 = 'چهار حالت ممکن:';
    const txt2 = '* حالت فعال: دزدگیر فعال می باشد';
    const txt3 = '* حالت غیرفعال: دزدگیر غیر فعال می باشد';
    const txt4 = '* حالت بی صدا: در این حالت فقط بلندگوی داخلی کار می کتد';
    const txt5 = '* حالت نیمه فعال: در این حالت فقط مناطق (زون) 1 و 2 کار می کند';

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
          const Text(txt4),
          const Text(txt5),
        ],
      ),
    );
  }

  Widget buildLocationsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
      child: Column(
        children: [
          Row(
            children: [
              const Text('مکان ها (دستگاه ها)').bold(),
            ],
          ),

          const SizedBox(height: 5),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
                itemCount: PlaceManager.places.length,
                itemBuilder: itemBuilderForLocations
            ),
          ),

          const SizedBox(height: 5),
        ],
      ),
    );
  }

  bool isCurrentPlaceThis(PlaceModel itm){
    return currentPlace!.id == itm.id;
  }

  Widget itemBuilderForLocations(_, idx){
    final itm = PlaceManager.places[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: (){
          if(isCurrentPlaceThis(itm)){
            return;
          }

          currentPlace = itm;
          PlaceManager.savePickedPlace(currentPlace!.id);
          assistCtr.updateHead();
        },
        child: CustomCard(
          color: isCurrentPlaceThis(itm) ? AppThemes.instance.currentTheme.accentColor : Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              const Icon(AppIcons.home),
              Text(itm.name).bold(),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyPlaces() {
    return SizedBox.expand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(AppImages.appIcon, width: 90, height: 60),

          Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImages.emptyLogo, width: 120, height: 120),
                  Text(AppMessages.mustAddAPlaceDescription),

                  GestureDetector(
                    onTap: onAddNewPlaceClick,
                    child: CustomCard(
                        color: AppDecoration.mainColor,
                        padding: const EdgeInsets.fromLTRB(8, 2, 8, 3),
                        child: const Text('اضافه کردن دستگاه').color(Colors.white)
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                      onPressed: onPdfHelpClick,
                      child: const Text('راهنما')
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  void listenPlacesDataChanged({data}){
    if(PlaceManager.places.isNotEmpty){
      if(currentPlace == null) {
        currentPlace = PlaceManager.places.first;
        PlaceManager.savePickedPlace(currentPlace!.id);
      }
    }
    else {
      currentPlace = null;
    }

    assistCtr.updateHead();
  }

  void onAddNewPlaceClick() {
    RouteTools.pushPage(context, const AddPlacePage());
  }

  void onEditPlaceClick() async {
    await RouteTools.pushPage(context, EditPlacePage(place: currentPlace!));

    if(context.mounted && currentPlace != null && currentPlace!.useOfRelays){
      final isShowRelayCase = AppDB.fetchKv(Keys.relayCaseIsShow)?? false;

      if(!isShowRelayCase) {
        AppDB.setReplaceKv(Keys.relayCaseIsShow, true);
        ShowCaseWidget.of(context).startShowCase([relayCaseKey]);
      }
    }
  }

  void navigateState(Route? route, NavigateState state) async {
    await System.wait(const Duration(milliseconds: 900));

    if(RouteTools.getTopWidgetState() == this){
      final isShowCase = AppDB.fetchKv(Keys.homeCaseIsShow)?? false;

      if(context.mounted && currentPlace != null && !isShowCase) {
        AppDB.setReplaceKv(Keys.homeCaseIsShow, true);
        ShowCaseWidget.of(context).startShowCase([settingCaseKey, helpCaseKey, placeSettingCaseKey, reloadCaseKey]);
      }
    }
  }

  void onSettingClick() {
    RouteTools.pushPage(context, const SettingsPage());
  }

  void onPdfHelpClick() async {
    final path = '${AppDirectories.getAppFolderInInternalStorage()}/help.pdf';
    await AssetsManager.assetsToFile('assets/pdf/test.pdf', path);
    OpenHelper.openFile(path, type: 'application/pdf');
  }

  void onRelayClick() {
    RouteTools.pushPage(context, RelayPage(place: currentPlace!));
  }

  void onChangeZoneStatusClick(ZoneModel zm, PlaceModel place) async {
    ZoneStatus? selectedZone = await AppDialogIris.instance.showIrisDialog(
        context,
      descView: ChangeZoneStatusDialog(zone: zm),
      decoration: AppDialogIris.instance.dialogDecoration.copy()..widthFactor = 0.95,
    );

    if(selectedZone == null || selectedZone == zm.status){
      return;
    }

    if(context.mounted) {
      final sms = await SmsManager.sendSms('42*${zm.number}*${selectedZone.getNumber()}', currentPlace!, context);

      if(sms){
        zm.status = selectedZone;
        PlaceManager.updatePlaceToDb(place);
        assistCtr.updateHead();
      }
    }
  }

  void onRemoteManageClick() async {
    /*if((currentPlace!.remoteCount?? 0) < 1){
      return;
    }*/

    await AppDialogIris.instance.showIrisDialog(
        context,
      descView: RemoteManageDialog(place: currentPlace!),
      decoration: AppDialogIris.instance.dialogDecoration.copy()..widthFactor = 0.95,
    );
  }

  void onChangeDeviceStatusClick(int index) async {
    int num = 11;
    var ds = DeviceStatus.active;

    if(index == 1){
      num = 10;
      ds = DeviceStatus.inActive;
    }
    else if(index == 2){
      num = 13;
      ds = DeviceStatus.semiActive;
    }
    else if(index == 3){
      num = 12;
      ds = DeviceStatus.silent;
    }

    final send = await SmsManager.sendSms('$num', currentPlace!, context);

    if(send){
      currentPlace!.deviceStatus = ds;
      PlaceManager.updatePlaceToDb(currentPlace!);
      assistCtr.updateHead();
    }
  }
}


/// antenna signal
//SmsManager.sendSms('61', currentPlace!, context);

