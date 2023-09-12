import 'package:animate_do/animate_do.dart';
import 'package:app/structures/enums/relay_status.dart';
import 'package:app/structures/models/relay_model.dart';
import 'package:app/views/pages/contact_manager_page.dart';
import 'package:app/system/keys.dart';
import 'package:app/tools/app/app_cache.dart';
import 'package:app/tools/app/app_db.dart';
import 'package:app/tools/app/app_directories.dart';
import 'package:app/tools/app/app_toast.dart';
import 'package:app/views/dialogs/remoteManageDialog.dart';
import 'package:app/views/pages/relay_page.dart';
import 'package:flutter/material.dart';

import 'package:iris_notifier/iris_notifier.dart';
import 'package:iris_route/iris_route.dart';
import 'package:iris_tools/api/helpers/colorHelper.dart';
import 'package:iris_tools/api/helpers/fileHelper.dart';
import 'package:iris_tools/api/helpers/focusHelper.dart';
import 'package:iris_tools/api/helpers/open_helper.dart';
import 'package:iris_tools/api/helpers/textHelper.dart';
import 'package:iris_tools/api/managers/assetManager.dart';
import 'package:iris_tools/api/system.dart';
import 'package:iris_tools/features/overlayDialog.dart';
import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_tools/widgets/circle_container.dart';
import 'package:iris_tools/widgets/customCard.dart';

import 'package:app/managers/place_manager.dart';
import 'package:app/managers/sms_manager.dart';
import 'package:app/views/pages/add_place_page.dart';
import 'package:app/views/pages/edit_place_page.dart';
import 'package:app/views/pages/settings_page.dart';
import 'package:app/structures/abstract/state_super.dart';
import 'package:app/structures/enums/app_events.dart';
import 'package:app/structures/enums/device_status.dart';
import 'package:app/structures/enums/zone_status.dart';
import 'package:app/structures/models/place_model.dart';
import 'package:app/structures/models/zone_model.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/app_decoration.dart';
import 'package:app/tools/app/app_dialog_iris.dart';
import 'package:app/tools/app/app_icons.dart';
import 'package:app/tools/app/app_images.dart';
import 'package:app/tools/app/app_messages.dart';
import 'package:app/tools/app/app_navigator.dart';
import 'package:app/tools/app/app_themes.dart';
import 'package:app/tools/route_tools.dart';
import 'package:app/views/dialogs/changeZoneStatusDialog.dart';
import 'package:app/views/dialogs/reChargeSimCardDialog.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:snapping_sheet_2/snapping_sheet.dart';
import 'package:toggle_switch/toggle_switch.dart';

class HomePage extends StatefulWidget {

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}
///==================================================================================
class _HomePageState extends StateSuper<HomePage> {
  PlaceModel? currentPlace;
  Color cColor = AppDecoration.secondColor;
  final settingCaseKey = GlobalKey();
  final helpCaseKey = GlobalKey();
  final placeSettingCaseKey = GlobalKey();
  final reloadCaseKey = GlobalKey();
  final relayCaseKey1 = GlobalKey();
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

    return Stack(
      children: [
        Column(
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
                      child: buildFrontPage(),
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


            /// bottom section (places)
            Builder(
                builder: (_){
                  if(PlaceManager.places.length < 2){
                    return const SizedBox();
                  }

                  return buildLocationsSection();
                }
            )
          ],
        ),

        /// timer-sms-view
        Positioned(
          top: 20,
            right: 16,
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

  Widget buildFrontPage(){
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      children: [
        const SizedBox(height: 20),
        /// update status
        buildUpdateStatusSection(),

        const SizedBox(height: 14),

        /// device state
        buildDeviceStatusSection(),

        const SizedBox(height: 8),

        /// sim card state
        buildSimCardSection(),

        const SizedBox(height: 8),
        buildZonesStatusSection(),

        const SizedBox(height: 8),
        buildZonesStateSection(),

        const SizedBox(height: 6),
        buildRemoteAndContactSection(),

        Visibility(
            visible: currentPlace!.supportPhoneNumber.isNotEmpty,
            child: buildContactWithInstaller()
        ),
      ],
    );
  }

  Widget buildUpdateStatusSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(AppMessages.lastUpdate),
        const Text(':  '),
        Text(currentPlace!.getLastUpdateDate()).color(currentPlace!.getUpdateColor())
            .bold().fsR(2),
      ],
    );
  }

  Widget buildDeviceStatusSection() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [
              ColorHelper.lightPlus(cColor, val: 0.02),
              cColor,
              ColorHelper.darkPlus(cColor, val: 0.09),
            ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,

        )
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(''),

                Showcase(
                  key: reloadCaseKey,
                  description: 'با لمس این دکمه وضعیت دستگاه به روز رسانی می شود',
                  targetPadding: const EdgeInsets.all(4),
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: onUpdateInfoClick,
                    child: Row(
                      children: [
                        const Text('بروز رسانی').color(Colors.blue).bold().fsR(1),
                        const SizedBox(width: 5),
                        const Icon(AppIcons.refreshCircle, color: Colors.blue, size: 18)
                      ],
                    ),
                  ),
                ),

                GestureDetector(
                    onTap: onDeviceStatusHelpClick,
                    child: Icon(AppIcons.questionMarkCircle, size: 25*pw, color: Colors.orange)
                ),
              ],
            ),

            const SizedBox(height: 12),

            buildButtons(),

            const SizedBox(height: 12),

            buildPowerBatterySection(),
          ],
        ),
      ),
    );
  }

  Widget buildButtons(){
    const defaultColor = Colors.grey;
    final bWidth = sw/3 - 30;

    return SizedBox(
      height: 170,
      child: Stack(
        children: [
          Positioned(
            top: 4,
              left: 10,
              child: SizedBox(
                width: bWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPlace!.deviceStatus != DeviceStatus.inActive ? defaultColor : Colors.red,
                  ),
                  onPressed: (){onButtonsClick(2);},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text('غیر فعال'),
                        Icon(AppIcons.cancel)
                      ],
                    ),
                  ),
                ),
              )
          ),

          Positioned(
            top: 4,
              right: 10,
              child: SizedBox(
                width: bWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPlace!.deviceStatus != DeviceStatus.active ? defaultColor : Colors.green,
                  ),
                  onPressed: (){onButtonsClick(1);},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text('فعال'),
                        Icon(AppIcons.power)
                      ],
                    ),
                  ),
                ),
              )
          ),

          Positioned(
              top: 100,
              left: 10,
              child: SizedBox(
                width: bWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPlace!.deviceStatus != DeviceStatus.silent ? defaultColor : Colors.blue,
                  ),
                  onPressed: (){onButtonsClick(3);},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text('بی صدا'),
                        Icon(AppIcons.silent)
                      ],
                    ),
                  ),
                ),
              )
          ),

          Positioned(
              top: 100,
              right: 10,
              child: SizedBox(
                width: bWidth,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPlace!.deviceStatus != DeviceStatus.semiActive ? defaultColor : Colors.orange,
                  ),
                  onPressed: (){onButtonsClick(4);},
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Column(
                      children: [
                        Text('نیمه فعال'),
                        Icon(AppIcons.semiActive)
                      ],
                    ),
                  ),
                ),
              )
          ),

          Center(
            child: GestureDetector(
              onTap: onListeningClick,
              child: CircleContainer(
                size: bWidth-20,
                backColor: Colors.purple,
                border: Border.all(style: BorderStyle.none),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('شنود').color(Colors.white),
                      const Icon(AppIcons.headset, color: Colors.white)
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildPowerBatterySection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// battery state
        Card(
          color: Colors.grey.shade50,
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.batteryStatus),
                const SizedBox(height: 4),
                Text(currentPlace!.getBatteryStateText()).bold(),
              ],
            ),
          ),
        ),

        Card(
          color: Colors.grey.shade50,
          elevation: 0,
          margin: const EdgeInsets.all(0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 80,
            ),
            child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('آنتن دهی'),
                    const SizedBox(height: 4),
                    Text(currentPlace!.getSimCardAntenna()).bold().color(currentPlace!.getSimCardAntennaColor()),
                  ],
                )
            ),
          ),
        ),

        Card(
          color: Colors.grey.shade50,
          elevation: 0,
          margin: const EdgeInsets.all(0),
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('بلندگو'),
                  const SizedBox(height: 4),
                  Text(currentPlace!.getSpeakerStateText()).bold(),
                ],
              )
          ),
        ),

        /// power state
        Card(
          color: Colors.grey.shade50,
          margin: const EdgeInsets.all(0),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.powerStatus),
                const SizedBox(height: 4),
                Text(currentPlace!.getPowerState()).bold(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSimCardSection() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      controller: (ctr){
        animList.add(ctr);
      },
      child: Card(
        color: Colors.pink.shade100,
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
                  //Text(AppMessages.simCardStatus),

                  TextButton(
                      style: TextButton.styleFrom(
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: onGetSimCardBalance,
                      child: const Text('بروز رسانی')
                  ),

                  GestureDetector(
                      onTap: onSimCardHelpClick,
                      child: Icon(AppIcons.questionMarkCircle, size: 25*pw, color: Colors.orange)
                  ),
                ],
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text('شارژ سیم کارت:').bold(),
                      const SizedBox(width: 8),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRelayGrab() {
    return Center(
      child: GestureDetector(
        onTap: (){
          if(relaySnapController.currentPosition > sw/2) {
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
                                            Text('تغییر').color(Colors.blue).fsR(-1)
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
                                    onChangeRelayStatus(currentPlace!.relays[1], v == 0);
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
                                          Text('تغییر').color(Colors.blue).fsR(-1)
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
                                  onChangeRelayStatus(currentPlace!.relays[0], v == 0);
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

  Widget buildZonesStateSection() {
    String zoneDescription = 'اگر حسگر یک زون تحریک شود، به مدت چند ثانیه وضعیت آن به حالت بسته تغییر می کند';

    return FadeInLeft(
      delay: const Duration(milliseconds: 600),
      controller: (ctr){
        animList.add(ctr);
      },
      child: Card(
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

              const SizedBox(height: 20),
              CustomCard(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                color: Colors.lime,
                  child: Text(zoneDescription)
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: currentPlace!.zones.where((element) => element.show).map(mapStateZone).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildZonesStatusSection() {
    return FadeInLeft(
      delay: const Duration(milliseconds: 400),
      controller: (ctr){
        animList.add(ctr);
      },
      child: Card(
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
      ),
    );
  }

  Widget mapStateZone(ZoneModel zm){
    return CustomCard(
      color: Colors.white,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 60,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Column(
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
          ),
        ),
      ),
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
    return FadeInLeft(
      delay: const Duration(milliseconds: 800),
      controller: (ctr){
        animList.add(ctr);
      },
      child: Row(
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
      ),
    );
  }

  Widget buildContactWithInstaller(){
    return Card(
      color: ColorHelper.changeHue(AppDecoration.secondColor),
      elevation: 0,
      margin: const EdgeInsets.only(top: 8.0, bottom: 4),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: (){
                OpenHelper.makePhoneCall(currentPlace!.supportPhoneNumber);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('تماس با پشتیبان').color(Colors.white).bold(),

                  const Icon(AppIcons.callPhone, color: Colors.pink),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                  width: 200,
                child: Divider(color: Colors.grey.shade50),
              ),
            ),

            GestureDetector(
              onTap: onSendSms,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('پیامک به پشتیبان').color(Colors.white).bold(),

                  const Icon(AppIcons.email, color: Colors.pink),
                ],
              ),
            ),
          ],
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
      SmsManager.sendSms('20*2*T000002', currentPlace!, context);
    }
    else {
      final p1 = currentPlace!.relays[0].duration.toString().split('.');
      final p2 = p1[0].replaceAll(':', '');

      SmsManager.sendSms('20*2*T${p2.padLeft(6, '0')}', currentPlace!, context);
    }
  }

  void onRelay2CommandClick() {
    if(currentPlace!.relays[1].status == RelayStatus.shortCommand) {
      SmsManager.sendSms('20*1*T000002', currentPlace!, context);
    }
    else {
      final p1 = currentPlace!.relays[1].duration.toString().split('.');
      final p2 = p1[0].replaceAll(':', '');

      SmsManager.sendSms('20*1*T${p2.padLeft(6, '0')}', currentPlace!, context);
    }
  }

  void onChangeRelayStatus(RelayModel itm, bool isActive) async {
    final send = await SmsManager.sendSms('20*${itm.number}*${isActive? 'ON': 'OFF'}', currentPlace!, context);

    if(send){
      itm.isActive = isActive;
      PlaceManager.updatePlaceToDb(currentPlace!);
      //assistCtr.updateHead();
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

  void onDeviceStatusHelpClick() {
    const txt1 = 'چهار حالت ممکن:';
    const txt2 = '* حالت فعال: دزدگیر فعال می باشد';
    const txt3 = '* حالت غیرفعال: دزدگیر غیر فعال می باشد';
    const txt4 = '* حالت بی صدا: در این حالت فقط بلندگوی داخلی کار می کند';
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
        onTap: () async {
          if(isCurrentPlaceThis(itm)){
            return;
          }

          currentPlace = itm;
          PlaceManager.saveFavoritePlace(currentPlace!.id);
          assistCtr.updateHead();
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

    assistCtr.updateHead();
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
        assistCtr.updateHead();
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

  /*void onRelayClick() {
    RouteTools.pushPage(context, RelayPage(place: currentPlace!));
  }*/

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
        //assistCtr.updateHead();
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
    print('@@@@@@@@@@1  ${currentPlace?.deviceStatus}');
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

    if(currentPlace!.deviceStatus == ds){
      return;
    }

    final send = await SmsManager.sendSms('$num', currentPlace!, context);

    // must parse receive sms
    if(send){
      currentPlace!.deviceStatus = ds;
      PlaceManager.updatePlaceToDb(currentPlace!);
      //assistCtr.updateHead();
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
    OpenHelper.sendSmsToByBody(currentPlace!.supportPhoneNumber, 'سلام، تکنسین محترم اینجانب درخواست پشتیبانی دارم');
  }

  void gotoRelayManager() {
    RouteTools.pushPage(context, RelayPage(place: currentPlace!));
  }
}


/// antenna signal
//SmsManager.sendSms('61', currentPlace!, context);

