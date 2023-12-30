import 'package:app/views/components/emboss.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/open_helper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/widgets/border/keep_shadow_bound.dart';
import 'package:iris_tools/widgets/circle_container.dart';
import 'package:iris_tools/widgets/custom_card.dart';
import 'package:iris_tools/widgets/overflow_touchable.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:toggle_switch/toggle_switch.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/device_status.dart';
import 'package:app/structures/enums/relay_status.dart';
import 'package:app/structures/enums/zone_status.dart';
import 'package:app/structures/models/place_model.dart';
import 'package:app/structures/models/relay_model.dart';
import 'package:app/structures/models/zone_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/dialogs/changeZoneStatusDialog.dart';
import 'package:app/views/dialogs/reChargeSimCardDialog.dart';
import 'package:app/views/dialogs/remoteManageDialog.dart';
import 'package:app/views/pages/add_place_page.dart';
import 'package:app/views/pages/contact_manager_page.dart';
import 'package:app/views/pages/edit_place_page.dart';
import 'package:app/views/pages/relay_page.dart';
import 'package:app/views/pages/settings_page.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}
///=============================================================================
class _HomePageState extends StateSuper<HomePage> {
  PlaceModel? currentPlace;
  Color cColor = AppDecoration.secondColor;
  final settingCaseKey = GlobalKey();
  final helpCaseKey = GlobalKey();
  final placeSettingCaseKey = GlobalKey();
  final ScrollController scrollController = ScrollController();

  final reloadCaseKey = GlobalKey();
  final relayCaseKey1 = GlobalKey();
  final listViewKey = GlobalKey();
  final Set<AnimationController> animList = {};
  SnappingSheetController relaySnapController = SnappingSheetController();
  final SnappingPosition closePosition = const SnappingPosition.factor(positionFactor: 1,
    grabbingContentOffset: GrabbingContentOffset.bottom,
  );

  final SnappingPosition openPosition = const SnappingPosition.factor(positionFactor: 0.5,
    grabbingContentOffset: GrabbingContentOffset.bottom,
  );



  @override
  void initState(){
    super.initState();

    currentPlace = PlaceManager.fetchFavoritePlace();

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
    return Scaffold(
      backgroundColor: AppDecoration.cardSectionsColor,
      body: SafeArea(
          child: buildBody()
      ),
    );
  }

  Widget buildBody(){
    if(PlaceManager.places.isEmpty) {
      return buildEmptyPlaces();
    }

    return Stack(
      children: [
        Column(
          children: [
            buildTopSection(),

            const SizedBox(height: 12),

            /// center section
            Expanded(
                child: buildFrontPage()
            ),
          ],
        ),

        Visibility(
          visible: currentPlace!.useOfRelay1 || currentPlace!.useOfRelay2,
          child: Center(
            child: SizedBox(
              height: currentPlace!.useOfRelay1 && currentPlace!.useOfRelay2? 300 : 150,
              child: SnappingSheet.horizontal(
                lockOverflowDrag: false,
                controller: relaySnapController,
                grabbingWidth: 30,
                initialSnappingPosition: closePosition,
                grabbing: buildRelayGrab(),
                snappingPositions: [
                  openPosition,
                  closePosition,
                ],
                sheetRight: SnappingSheetContent(
                  draggable: (x)=> true,
                  child: buildRelaysSection(),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget buildTopSection() {
    return Stack(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Showcase(
                key: settingCaseKey,
                description: 'تنظیمات برنامه اینجاست',
                child: Emboss(
                  deBoss: true,
                  borderRadius: BorderRadius.circular(25),
                  backgroundColor: AppDecoration.cardSectionsColor,
                  child: IconButton(
                      style: IconButton.styleFrom(
                        visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                      ),
                      onPressed: onSettingClick,
                      visualDensity: const VisualDensity(vertical: -4, horizontal: -4),
                      padding: const EdgeInsets.symmetric(vertical: 0),
                      icon: const Icon(AppIcons.settings)
                  ),
                ),
              ),
            ),

            /// logo
            Image.asset(AppImages.appIcon, width: 90, height: 70),

            Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Showcase(
                key: helpCaseKey,
                description: 'اگر نیاز به راهنمایی دارید، اینجاست',
                child: GestureDetector(
                  onTap: onPdfHelpClick,
                  child: Image.asset(AppImages.helpIco, width: 40, height: 40),
                ),
              ),
            ),
          ],
        ),

        /// timer-sms-view
        Positioned(
            top: 20,
            right: 50,
            child: StreamBuilder(
              stream: SmsManager.smsTimeStream.stream,
              builder: (_, data){
                if(data.data == null || data.error != null){
                  return const SizedBox();
                }

                return CircleContainer(
                    backColor: AppDecoration.mainColor,
                    size: 30,
                    border: Border.all(style: BorderStyle.none),
                    //padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    child: Center(child: Text('${data.data}').color(Colors.white))
                );
              },
            )
        ),
      ],
    );
  }

  Widget buildFrontPage(){
    return ListView(
      key: listViewKey,
      controller: scrollController,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              /// place and update info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [

                  /// place name
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: onEditPlaceClick,
                      child: Transform.translate(
                        offset: const Offset(0,2),
                        child: Stack(
                          children: [
                            Emboss(
                              backgroundColor: AppDecoration.cardSectionsColor,
                              borderRadius: BorderRadius.circular(17),
                              deBoss: true,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 34.0, bottom: 4),
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Text(currentPlace!.name,
                                      style: const TextStyle(height: 0, inherit: false), maxLines: 1,)
                                    .bold().fsR(2).color(Colors.black),
                                  ),
                              ),
                            ),

                            /// place settings icon
                            Transform.translate(
                              offset: const Offset(0, -2),
                              child: Showcase(
                                key: placeSettingCaseKey,
                                description: 'تنظیمات دستگاه اینجاست',
                                targetPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                                child: Emboss(
                                    borderRadius: BorderRadius.circular(25),
                                    backgroundColor: AppDecoration.cardSectionsColor,
                                    child: const Padding(
                                      padding: EdgeInsets.all(1.0),
                                      child: Icon(AppIcons.settings, size: 23),
                                    )
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// last update text
                  Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppMessages.lastUpdate),
                          const Text(':  '),
                          Text(currentPlace!.getLastUpdateDate())
                              .color(currentPlace!.getUpdateColor())
                              .bold(),
                        ],
                      )
                  ),
                ],
              ),

              /// device state
              const SizedBox(height: 14),
              buildButtonsSection(),

              const SizedBox(height: 20),
              buildPowerSpeakerAntennaBatterySection(),

              const SizedBox(height: 15),
              buildZonesStateSection(),

              const SizedBox(height: 15),
              buildZonesStatusSection(),

              /// sim card state
              const SizedBox(height: 20),
              buildSimCardSection(),

              const SizedBox(height: 15),
              buildRemoteAndContactSection(),
            ],
          ),
        ),

        /// bottom section (places)
        const SizedBox(height: 25),
        buildLocationsSection(),
      ],
    );
  }

  Widget buildButtonsSection() {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Emboss(
          backgroundColor: AppDecoration.cardSectionsColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal :14, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onButtonsClick(1),
                        behavior: HitTestBehavior.translucent,
                        child: buildButton(
                          'فعال',
                          AppIcons.power,
                          currentPlace!.deviceStatus == DeviceStatus.active,
                          1,
                        ),
                      ),
                    ),

                    const SizedBox(width: 50),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => onButtonsClick(2),
                        behavior: HitTestBehavior.translucent,
                        child: buildButton(
                          'غیر فعال',
                          AppIcons.block,
                            currentPlace!.deviceStatus == DeviceStatus.inActive,
                          2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onButtonsClick(4),
                        behavior: HitTestBehavior.translucent,
                        child: buildButton(
                          'نیمه فعال',
                          AppIcons.semiActive,
                          currentPlace!.deviceStatus == DeviceStatus.semiActive,
                          4,
                        ),
                      ),
                    ),

                    const SizedBox(width: 50),

                    Expanded(
                      child: GestureDetector(
                        onTap: () => onButtonsClick(3),
                        behavior: HitTestBehavior.translucent,
                        child: buildButton(
                          'بی صدا',
                          AppIcons.speakerOff,
                          currentPlace!.deviceStatus == DeviceStatus.silent,
                          3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        GestureDetector(
          onTap: onListeningClick,
          child: Column(
            children: [
              Emboss(
                backgroundColor: AppDecoration.cardSectionsColor,
                offset: const Offset(1.1, 1.1),
                child: const Padding(
                  padding: EdgeInsets.all(1.0),
                  child: Icon(
                    Icons.headphones,
                    color: Colors.blue,
                  ),
                ),
              ),

              const Text('شنود').color(Colors.blue)
            ],
          ),
        ),

        Positioned(
          top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: OverflowTouchable(
                scrollController: scrollController,
                scrollWidgetKey: listViewKey,
                child: GestureDetector(
                  onTap: onUpdateInfoClick,
                  behavior: HitTestBehavior.translucent,
                  child: KeepShadowBound(
                    child: Emboss(
                      backgroundColor: AppDecoration.cardSectionsColor,
                      child: Text('  ${AppMessages.update}  ',
                          style: TextStyle(inherit: false, color: AppDecoration.redColor)
                      ).fsR(-1).bold(),
                    ),
                  ),
                ),
              ),
            )
        ),
      ],
    );
  }

  Widget buildButton(String text, IconData icon, bool isActive, int index){
    Color activeColor = Colors.black;

    if(isActive) {
      switch (index) {
        case 1:
          activeColor = Colors.green;
          break;
        case 2:
          activeColor = Colors.red;
          break;
        case 3:
          activeColor = Colors.orange;
          break;
        case 4:
          activeColor = Colors.blueAccent;
          break;
      }
    }

    return Emboss(
      backgroundColor: AppDecoration.cardSectionsColor,
      deBoss: true,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),

            DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: isActive? activeColor : Colors.transparent,
                  boxShadow: [
                    if(isActive)
                    BoxShadow(
                      color: activeColor,
                      offset: const Offset(0,0),
                      blurRadius: 4,
                      spreadRadius: 2,
                    )
                  ]
                ),
              child: Padding(
                padding: const EdgeInsets.all(3.0),
                child: Icon(
                  icon, color: isActive? Colors.white: Colors.black,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(width: 15),
            Text(text)
                .bold().color(isActive? activeColor : Colors.black)
          ],
        ),
      ),
    );
  }

  Widget buildPowerSpeakerAntennaBatterySection() {
    return Emboss(
      backgroundColor: AppDecoration.cardSectionsColor,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: buildPowerItem(
                  'باتری',
                  const Icon(Icons.battery_charging_full),
                  Text(currentPlace!.getBatteryStateText()).color(Colors.white)
                ),
            ),
            Expanded(
              child: buildPowerItem(
                  'آنتن',
                  const Icon(Icons.signal_cellular_alt_outlined),
                  Text(currentPlace!.getSimCardAntenna()).color(Colors.white)
              ),
            ),
            Expanded(
              child: buildPowerItem(
                  'برق',
                  const Icon(Icons.power),
                  Text(currentPlace!.getPowerState()).color(Colors.white)
              ),
            ),
            Expanded(
              child: buildPowerItem(
                  'بلندگو',
                  const Icon(AppIcons.speaker),
                  Text(currentPlace!.getSpeakerStateText()).color(Colors.white)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPowerItem(String text, Widget icon, Widget state){
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 5),
        icon,
        const SizedBox(height: 5),
        Center(child: Text(text)
            .color(Colors.black).bold().fsR(-1)),
        const SizedBox(height: 8),

        SizedBox(
          height: 25,
          child: ColoredBox(
            color: Colors.black,
            child: Center(child: state),
          ),
        )
      ],
    );
  }

  Widget buildZonesStatusSection() {
    return Stack(
      children: [
        Emboss(
          backgroundColor: AppDecoration.cardSectionsColor,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                const Text('حالت مناطق (زون ها)')
                .bold(weight: FontWeight.w900).fsR(2),

                const SizedBox(height: 4),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: currentPlace!.zones.where((element) => element.show)
                      .map(mapStatusZone).toList(),
                ),
              ],
            ),
          ),
        ),

        Positioned(
            left: 5,
            top: 5,
            child: GestureDetector(
              onTap: onZoneUpdateClick,
              behavior: HitTestBehavior.translucent,
              child: Emboss(
                backgroundColor: AppDecoration.cardSectionsColor,
                child: Text('  ${AppMessages.update}  ',
                    style: TextStyle(inherit: false, color: AppDecoration.redColor)
                ).fsR(-1).bold(),
              ),
            )
        ),
      ],
    );
  }

  Widget buildZonesStateSection() {
    return Emboss(
      backgroundColor: AppDecoration.cardSectionsColor,
      //offset: const Offset(1,1),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            const Text('وضعیت مناطق (زون ها)')
                .bold(weight: FontWeight.w900).fsR(2),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: currentPlace!.zones.where((element) => element.show)
                  .map(mapStateZone).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSimCardSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Emboss(
          backgroundColor: AppDecoration.cardSectionsColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.sim_card_outlined),
                    const SizedBox(width: 4),
                    const Text('شارژ سیم کارت:').bold(),
                  ],
                ),
                Text(currentPlace!.getSimCardCharge()).bold().color(AppDecoration.redColor),
              ],
            ),
          ),
        ),

        Positioned(
          top: -0,
            left: 30,
            child: OverflowTouchable(
              child: GestureDetector(
                onTap: onSimCardHelpClick,
                behavior: HitTestBehavior.translucent,
                child: Image.asset(AppImages.helpIco2, width: 28, height: 28,),
              ),
            )
        ),

        Positioned(
            bottom: 0,
            right: 55,
            child: OverflowTouchable(
              child: GestureDetector(
                onTap: onGetSimCardBalance,
                behavior: HitTestBehavior.translucent,
                child: Emboss(
                  backgroundColor: AppDecoration.cardSectionsColor,
                  child: Text('  ${AppMessages.update}  ',
                          style: TextStyle(
                              inherit: false, color: AppDecoration.redColor))
                      .fsR(-1)
                      .bold(),
                ),
              ),
            )),

        Positioned(
            bottom: 0,
            left: 55,
            child: OverflowTouchable(
              child: GestureDetector(
                onTap: onReChargeSimCardClick,
                behavior: HitTestBehavior.translucent,
                child: Emboss(
                  backgroundColor: AppDecoration.cardSectionsColor,
                  child: const Text('  افزایش شارژ  ',
                      style: TextStyle(inherit: false, color: Colors.black)
                  ).fsR(-1).bold(),
                ),
              ),
            )
        ),
      ],
    );
  }

  Widget mapStatusZone(ZoneModel zm){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: IntrinsicWidth(
          child: Column(
            children: [
              ColoredBox(
                color: Colors.blueAccent,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 60,
                      maxWidth: double.infinity
                  ),
                  child: Center(
                    child: Builder(
                      builder: (context) {
                        if(zm.name != null){
                          return Text(' ${TextHelper.subByCharCountSafe(zm.name, 12)} ', maxLines: 1)
                              .bold().fsR(1).color(Colors.white);
                        }

                        return Text('زون ${zm.number} ')
                            .bold().fsR(1).color(Colors.white);
                      }
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: (){
                  onChangeZoneStatusClick(zm, currentPlace!);
                },
                  child: ColoredBox(
                    color: Colors.black,
                      child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 60,
                            maxWidth: double.infinity
                          ),
                          child: Center(
                            child: Text(' ${zm.status.getHumanName()} ')
                                .color(Colors.white),
                          ))
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget mapStateZone(ZoneModel zm){
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Emboss(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicWidth(
            child: Column(
              children: [
                ColoredBox(
                  color: Colors.black,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 60,
                        maxWidth: double.infinity
                    ),
                    child: Center(
                      child: Builder(
                        builder: (context) {
                          if(zm.name != null){
                            return Text(' ${TextHelper.subByCharCountSafe(zm.name, 12)} ', maxLines: 1)
                                .bold().fsR(1).color(Colors.white);
                          }

                          return Text('زون ${zm.number} ')
                              .bold().fsR(1).color(Colors.white);
                        }
                      ),
                    ),
                  ),
                ),

                ColoredBox(
                  color: AppDecoration.cardSectionsColor,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          minWidth: 60,
                          maxWidth: double.infinity
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 6, left: 6, right: 6, bottom: 5),
                          child: Emboss(
                            backgroundColor: AppDecoration.cardSectionsColor,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            deBoss: true,
                            child: SizedBox(
                              height: 25,
                              child: ColoredBox(
                                color: zm.isOpen? Colors.green : Colors.red,
                                child: Center(
                                  child: Text(zm.isOpen? '${AppMessages.openState} ' : AppMessages.closeState)
                                  .color(Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ))
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRemoteAndContactSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Emboss(
          backgroundColor: AppDecoration.cardSectionsColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: onRemoteManageClick,
                    child: Emboss(
                      deBoss: true,
                      backgroundColor: AppDecoration.cardSectionsColor,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(AppIcons.remote, color: AppThemes.instance.themeData.chipTheme.backgroundColor),
                            const SizedBox(width: 4),
                            Text('تعداد ریموت ها: ${currentPlace!.remoteCount?? 0}').bold(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      RouteTools.pushPage(context, ContactManagerPage(place: currentPlace!));
                    },
                    child: Emboss(
                      deBoss: true,
                      backgroundColor: AppDecoration.cardSectionsColor,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(AppIcons.accountCircle,
                                  color: AppThemes.instance.themeData.chipTheme.backgroundColor),
                              const SizedBox(width: 4),
                              Text('تعداد مخاطبین: ${currentPlace!.contactCount?? 0}').bold(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildLocationsSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// place list
        DecoratedBox(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
              ),
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xff21218d),
                    Color(0xff1c1c81),
                    Color(0xff10104d),
                  ],
                  stops: [
                    0.3,
                    0.6,
                    0.9
                  ]
              )
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4),
            child: SizedBox(
              height: 50,
              child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: PlaceManager.places.length,
                  itemBuilder: itemBuilderForLocations
              ),
            ),
          ),
        ),

        /// add
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(
              child: OverflowTouchable(
                child: GestureDetector(
                    onTap: onAddNewPlaceClick,
                    child: Image.asset(AppImages.addIco, width: 40, height: 40,)
                ),
              ),
            )
        ),

        /// support
        Positioned(
          top: 0,
          left: 15,
          child: Theme(
            data: AppThemes.instance.themeData.copyWith(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: OverflowTouchable(
              offset: const Offset(15, 0),
              child: PopupMenuButton(
                  itemBuilder: supportMenuItemBuilder,
                  color: Colors.transparent,
                  elevation: 0,
                  child: Image.asset(AppImages.supportIco, width: 40, height: 40)
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget itemBuilderForLocations(_, idx){
    final itm = PlaceManager.places[idx];

    return UnconstrainedBox(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: GestureDetector(
          onTap: () async {
            if(isCurrentPlaceThis(itm)){
              return;
            }
      
            currentPlace = itm;
            PlaceManager.saveFavoritePlace(currentPlace!.id);
            callState();
            for(final x in animList) {
              try{
                x.reset();
                x.forward();
                await Future.delayed(const Duration(milliseconds: 100));
              }
              catch (e){/**/}
            }
          },
          child: CustomCard(
            color: isCurrentPlaceThis(itm) ? AppThemes.instance.currentTheme.accentColor : Colors.grey.shade300,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              children: [
                const Icon(AppIcons.home),
                const SizedBox(width: 5),
                Text(itm.name).bold(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildRelayGrab() {
    return Center(
      child: GestureDetector(
        onTap: (){
          if(relaySnapController.currentPosition > ws/2) {
            relaySnapController.snapToPosition(openPosition);
          }
          else {
            relaySnapController.snapToPosition(closePosition);
          }
        },
        child: SizedBox(
          height: 100,
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: AppDecoration.mainColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(),
                    Container(
                      width: 4,
                      color: Colors.amber,
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                    )
                  ],
                ),
              ),

              Center(child: const Text('رله').color(Colors.white).bold().fsR(3))
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRelaysSection(){
    return Showcase(
      key: relayCaseKey1,
      description: 'از اینجا دستور رله را اجرا کنید',
      targetPadding: const EdgeInsets.fromLTRB(40, 10, 0, 10),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          bottomLeft: Radius.circular(15),
        ),
        child: ColoredBox(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// relay 1
                Visibility(
                  visible: currentPlace!.useOfRelay1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentPlace!.relays[0].getName(), maxLines: 1).bold().fsR(4),

                        Text(currentPlace!.relays[0].status.getHumanName(), maxLines: 1),

                        const SizedBox(height: 20),

                        Center(
                          child: Builder(
                              builder: (context) {
                                if(currentPlace!.relays[0].status == RelayStatus.shortCommand){
                                  return GestureDetector(
                                    onTap: onRelay1CommandClick,
                                    child: CustomCard(
                                        color: AppDecoration.mainColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                                        child: const Text('فرمان').color(Colors.white)
                                    ),
                                  );
                                }

                                if(currentPlace!.relays[0].status == RelayStatus.customTime){
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: gotoRelayManager,
                                        child: Column(
                                          children: [
                                            Text(currentPlace!.relays[0].duration.toString().split('.')[0]).fsR(-2.5),
                                            const Text('تغییر').color(Colors.blue).fsR(-1)
                                          ],
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: onRelay1CommandClick,
                                        child: CustomCard(
                                            color: AppDecoration.mainColor,
                                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                                            child: const Text('فرمان').color(Colors.white)
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return ToggleSwitch(
                                  changeOnTap: false,
                                  multiLineText: false,
                                  totalSwitches: 2,
                                  initialLabelIndex: currentPlace!.relays[1].isActive? 0 : 1,
                                  activeBgColors: const [[Colors.green], [Colors.red]],
                                  activeFgColor: Colors.white,
                                  inactiveFgColor: Colors.white,
                                  labels: const [
                                    'فعال',
                                    'غیرفعال',
                                  ],
                                  onToggle: (v){
                                    onChangeRelayStatus(currentPlace!.relays[0], v == 0);
                                  },
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Visibility(
                  visible: currentPlace!.useOfRelay1 && currentPlace!.useOfRelay2,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(color: Colors.grey, indent: 7, endIndent: 7,),
                  ),
                ),

                /// relay 2
                Visibility(
                  visible: currentPlace!.useOfRelay2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(currentPlace!.relays[1].getName(), maxLines: 1).bold().fsR(4),

                        Text(currentPlace!.relays[1].status.getHumanName(), maxLines: 1),

                        const SizedBox(height: 20),

                        Center(
                          child: Builder(
                              builder: (context) {
                                if(currentPlace!.relays[1].status == RelayStatus.shortCommand){
                                  return GestureDetector(
                                    onTap: onRelay2CommandClick,
                                    child: CustomCard(
                                        color: AppDecoration.mainColor,
                                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                                        child: const Text('فرمان').color(Colors.white)
                                    ),
                                  );
                                }

                                if(currentPlace!.relays[1].status == RelayStatus.customTime){
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.translucent,
                                        onTap: gotoRelayManager,
                                        child: Column(
                                          children: [
                                            Text(currentPlace!.relays[1].duration.toString().split('.')[0]).fsR(-2.5),
                                            const Text('تغییر').color(Colors.blue).fsR(-1)
                                          ],
                                        ),
                                      ),

                                      GestureDetector(
                                        onTap: onRelay2CommandClick,
                                        child: CustomCard(
                                            color: AppDecoration.mainColor,
                                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 7),
                                            child: const Text('فرمان').color(Colors.white)
                                        ),
                                      ),
                                    ],
                                  );
                                }

                                return ToggleSwitch(
                                  changeOnTap: false,
                                  multiLineText: false,
                                  totalSwitches: 2,
                                  initialLabelIndex: currentPlace!.relays[0].isActive? 0 : 1,
                                  activeBgColors: const [[Colors.green], [Colors.red]],
                                  activeFgColor: Colors.white,
                                  inactiveFgColor: Colors.white,
                                  labels: const [
                                    'فعال',
                                    'غیرفعال',
                                  ],
                                  onToggle: (v){
                                    onChangeRelayStatus(currentPlace!.relays[1], v == 0);
                                  },
                                );
                              }
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
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

  void onRelay1CommandClick() {
    if(currentPlace!.relays[0].status == RelayStatus.shortCommand) {
      SmsManager.sendSms('20*1*T000002', currentPlace!, context);
    }
    else {
      final p1 = currentPlace!.relays[0].duration.toString().split('.');
      final p2 = p1[0].replaceAll(':', '');

      SmsManager.sendSms('20*1*T${p2.padLeft(6, '0')}', currentPlace!, context);
    }
  }

  void onRelay2CommandClick() {
    if(currentPlace!.relays[1].status == RelayStatus.shortCommand) {
      SmsManager.sendSms('20*2*T000002', currentPlace!, context);
    }
    else {
      final p1 = currentPlace!.relays[1].duration.toString().split('.');
      final p2 = p1[0].replaceAll(':', '');

      SmsManager.sendSms('20*2*T${p2.padLeft(6, '0')}', currentPlace!, context);
    }
  }

  void onChangeRelayStatus(RelayModel itm, bool isActive) async {
    final send = await SmsManager.sendSms('20*${itm.number}*${isActive? 'ON': 'OFF'}', currentPlace!, context);

    if(send){
      itm.isActive = isActive;
      PlaceManager.updatePlaceToDb(currentPlace!);
      //callState();
    }
  }

  void onSimCardHelpClick() {
    const txt1 = 'برای دریافت صحیح جواب، زبان سیم کارت باید انگلیسی باشد';

    OverlayDialog.showMiniInfo(context,
      builder: (_, c){
        return c;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(txt1).bold(),
        ],
      ),
    );
  }

  bool isCurrentPlaceThis(PlaceModel itm){
    return currentPlace!.id == itm.id;
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

                  const SizedBox(height: 20),

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
                      child: const Text('راهنما').fsR(1)
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
        PlaceManager.saveFavoritePlace(currentPlace!.id);
      }
    }
    else {
      currentPlace = null;
    }

    callState();
  }

  void onAddNewPlaceClick() {
    RouteTools.pushPage(context, const AddPlacePage());
  }

  void onEditPlaceClick() async {
    await RouteTools.pushPage(context, EditPlacePage(place: currentPlace!));

    if(context.mounted && currentPlace != null &&
        (currentPlace!.useOfRelay1 || currentPlace!.useOfRelay2)){

      final isShowRelayCase = AppDB.fetchKv(Keys.relayCaseIsShow)?? false;

      if(!isShowRelayCase) {
        AppDB.setReplaceKv(Keys.relayCaseIsShow, true);
        callState();
        ShowCaseWidget.of(context).startShowCase([relayCaseKey1]);
        relaySnapController.snapToPosition(openPosition);
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
    if(!AppCache.canCallMethodAgain('onPdfHelpClick')){
      AppToast.showToast(context, AppMessages.bePatient);
      return;
    }

    final path = '${AppDirectories.getAppFolderInInternalStorage()}/help_user.pdf';

    if(!FileHelper.existSync(path)) {
      await AssetsManager.assetsToFile('assets/pdf/help_user.pdf', path);
    }

    OpenHelper.openFile(path, type: 'application/pdf');
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
        //callState();
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

    /* aga mehdi goft ke besh tekrari ham befreste
    if(currentPlace!.deviceStatus == ds){
      return;
    }*/

    final send = await SmsManager.sendSms('$num', currentPlace!, context);

    // must parse receive sms
    if(send){
      currentPlace!.deviceStatus = ds;
      PlaceManager.updatePlaceToDb(currentPlace!);
      //callState();
    }
  }

  void onButtonsClick(int index) {
    if(index == 0){
      onListeningClick();
    }
    else if(index ==1){//active
      onChangeDeviceStatusClick(0);
    }
    else if(index == 2){//inActive
      onChangeDeviceStatusClick(1);
    }
    else if(index == 3){//silent
      onChangeDeviceStatusClick(3);
    }
    else if(index == 4){//semi
      onChangeDeviceStatusClick(2);
    }
  }

  void onSendSms() {
    if(currentPlace!.supportPhoneNumber.isEmpty){
      AppToast.showToast(context, 'شماره ی پشتیبان ثبت نشده');
      return;
    }

    OpenHelper.sendSmsToByBody(currentPlace!.supportPhoneNumber, 'سلام، تکنسین محترم اینجانب درخواست پشتیبانی دارم');
  }

  void onMakeCall() {
    if(currentPlace!.supportPhoneNumber.isEmpty){
      AppToast.showToast(context, 'شماره ی پشتیبان ثبت نشده');
      return;
    }

    OpenHelper.makePhoneCall(currentPlace!.supportPhoneNumber);
  }

  void gotoRelayManager() {
    RouteTools.pushPage(context, RelayPage(place: currentPlace!));
  }

  List<PopupMenuEntry> supportMenuItemBuilder(BuildContext ctx) {
    return [
      PopupMenuItem(
        child: UnconstrainedBox(
          alignment: Alignment.topCenter,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        Navigator.of(context).pop();
                        onSendSms();
                      },
                      child: const Text('ارسال پیامک به پشتیبان')
                  ),

                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: (){
                      Navigator.of(context).pop();
                      onMakeCall();
                    },
                    child: const Text('تماس با پشتیبان'),
                  ),
                ],
              ),
            ),
          ),
        ),

      )

    ];
  }
}


/// antenna signal
//SmsManager.sendSms('61', currentPlace!, context);
