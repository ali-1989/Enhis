import 'package:app/managers/smsManager.dart';
import 'package:app/pages/add_place_page.dart';
import 'package:app/pages/settings_page.dart';
import 'package:app/services/sms_service.dart';
import 'package:app/structures/enums/appEvents.dart';
import 'package:app/structures/enums/deviceStatus.dart';
import 'package:app/structures/models/placeModel.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/system/publicAccess.dart';
import 'package:app/tools/app/appDialogIris.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appImages.dart';
import 'package:app/tools/app/appMessages.dart';
import 'package:app/tools/app/appNavigator.dart';
import 'package:app/tools/app/appThemes.dart';
import 'package:app/tools/routeTools.dart';
import 'package:app/views/dialogs/reChargeSimCardDialog.dart';
import 'package:flutter/material.dart';
import 'package:iris_tools/features/overlayDialog.dart';

import 'package:iris_tools/modules/stateManagers/assist.dart';
import 'package:iris_notifier/iris_notifier.dart';

import 'package:app/structures/abstract/stateBase.dart';
import 'package:app/system/extensions.dart';
import 'package:iris_tools/widgets/customCard.dart';
import 'package:toggle_switch/toggle_switch.dart';

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

  @override
  void initState(){
    super.initState();

    currentPlace = PublicAccess.pickSavedPlace();
    EventNotifierService.addListener(AppEvents.placeDataChanged, onPlacesDataChanged);
  }

  @override
  void dispose(){
    EventNotifierService.removeListener(AppEvents.placeDataChanged, onPlacesDataChanged);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //AppDB.db.clearTable(AppDB.tbPlaces);

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
    if(PublicAccess.places.isEmpty) {
      return buildEmptyState();
    }


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
                        buildZonesSection(),
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
                    child: ActionChip(
                        labelPadding: const EdgeInsets.symmetric(horizontal: 5),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                        onPressed: onEditPlaceClick,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(currentPlace!.name).bold().fsR(2),
                            ),
                            const SizedBox(width: 2),
                            const CustomCard(
                              color: Colors.green,
                                radius: 25,
                                padding: EdgeInsets.all(2),
                                child: Icon(AppIcons.settings,
                                  color: Colors.white, size: 15)
                            )
                          ],
                        )
                    ),
                  ),
                ),
              ],
            )
        ),


        /// bottom section
        Builder(
            builder: (_){
              if(PublicAccess.places.length < 2){
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
            Image.asset(AppImages.appIcon, width: 90, height: 60),
          ],
        ),

        /// setting Icon
        Positioned(
            top: 2,
            left: 2,
            child: IconButton(
                onPressed: onSettingClick,
                icon: const Icon(AppIcons.settings)
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
                Text(currentPlace!.getLastUpdateDate()).color(currentPlace!.getUpdateColor()),
              ],
            ),

            IconButton(
                onPressed: onUpdateInfoClick,
                icon: const Icon(AppIcons.refreshCircle, color: Colors.blue)
            )
          ],
        ),

        /// relay
        TextButton(
            onPressed: onRelayClick,
            child: const Text('کلید (رله)')
        )
      ],
    );
  }

  Widget buildDeviceStatusSection() {
    return Card(
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

                GestureDetector(
                    onTap: onDeviceStatusHelpClick,
                    child: const Icon(AppIcons.questionMarkCircle, size: 16)
                ),
              ],
            ),

            const SizedBox(height: 10),

            Builder(
              builder: (context) {
                if(currentPlace!.deviceStatus == DeviceStatus.unKnow){
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: const Text('نا مشخص').alpha(),
                  );
                }

                return ToggleSwitch(
                  minHeight: 30.0,
                  initialLabelIndex: 1,
                  cornerRadius: 8.0,
                  activeFgColor: Colors.white,
                  inactiveBgColor: Colors.grey.shade400,
                  inactiveFgColor: Colors.white,
                  totalSwitches: 4,
                  /*icons: [
                                        AppIcons.calendar,
                                        AppIcons.infoCircle,
                                        AppIcons.wallet,
                                        AppIcons.backupCloud,
                                      ],*/
                  labels: const [
                    'فعال',
                    'غیرفعال',
                    'نیمه فعال',
                    'بی صدا',
                  ],
                  iconSize: 14.0,
                  borderWidth: 1.0,
                  multiLineText: false,
                  activeBgColors: const [
                    [Colors.green],
                    [Colors.red],
                    [Colors.orange],
                    [Colors.blue]
                  ],
                  onToggle: (index) {

                  },
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
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.batteryStatus),

                const SizedBox(height: 6),

                Text(currentPlace!.getBatteryStateText()),
              ],
            ),
          ),
        ),

        /// listening
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
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

        /// power state
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 0),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(AppMessages.powerStatus),

                const SizedBox(height: 6),

                Text(currentPlace!.getPowerState()),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSimCardSection() {
    return Card(
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

                TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: onReChargeSimCardClick,
                    child: const Text('بروز رسانی')
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('موجودی شارژ'),
                    const SizedBox(height: 4),
                    Text(currentPlace!.getSimCardCharge()),
                  ],
                ),

                Column(
                  children: [
                    ActionChip(
                      label: const Text('افزایش شارژ'),
                      onPressed: onReChargeSimCardClick,
                    )
                    /*TextButton(
                                            style: TextButton.styleFrom(
                                                visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: onReChargeSimCardClick,
                                            child: Text('افزایش شارژ')
                                        )*/
                  ],
                ),

                Column(
                  children: [
                    const Text('آنتن دهی'),
                    const SizedBox(height: 4),
                    Text(currentPlace!.getSimCardAntenna()).color(currentPlace!.getSimCardAntennaColor()),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildZonesSection() {
    return Card(
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
              ],
            ),

            const SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: currentPlace!.zones.map(mapZone).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget mapZone(ZoneModel zm){
    //final idx = currentPlace!.zones.indexOf(zm);

    return Column(
      children: [
        Text(zm.name?? 'زون ${zm.number}'),

        //const SizedBox(height: 8),
        Chip(
          elevation: 0,
            padding: EdgeInsets.zero,
            visualDensity: const VisualDensity(vertical: -4),
            label: Text('${zm.isActive? AppMessages.active : AppMessages.inActive} ')
        ),

        Text('${zm.status.getHumanName()} ').color(Colors.blue),
      ],
    );
  }

  void onSettingClick() {
    RouteTools.pushPage(context, const SettingsPage());
  }

  void onRelayClick() {
  }

  void onUpdateInfoClick() {
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

  void onReChargeSimCardClick() {
    void onApply(String txt, ctx){
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
                itemCount: PublicAccess.places.length,
                itemBuilder: itemBuilderForLocations
            ),
          )
        ],
      ),
    );
  }

  bool isCurrentPlaceThis(PlaceModel itm){
    return currentPlace!.id == itm.id;
  }

  Widget itemBuilderForLocations(_, idx){
    final itm = PublicAccess.places[idx];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: (){
          if(isCurrentPlaceThis(itm)){
            return;
          }

          currentPlace = itm;
          assistCtr.updateHead();
        },
        child: CustomCard(
          color: isCurrentPlaceThis(itm) ? AppThemes.instance.currentTheme.accentColor : Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              const Icon(AppIcons.home),
              Text(itm.name),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyState() {
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

                  TextButton(
                      onPressed: onAddNewPlaceClick,
                      child: const Text('اضافه کردن دستگاه')
                  )
                ],
              )
          ),
        ],
      ),
    );
  }

  void onAddNewPlaceClick() {
    RouteTools.pushPage(context, const AddPlacePage());
  }

  void onPlacesDataChanged({data}){
    if(PublicAccess.places.isNotEmpty){
      if(currentPlace == null) {
        currentPlace = PublicAccess.places.first;
        PublicAccess.savePickedPlace(currentPlace!.id);
      }
    }
    else {
      currentPlace = null;
    }

    assistCtr.updateHead();
  }

  void onEditPlaceClick() async {

  }
}
