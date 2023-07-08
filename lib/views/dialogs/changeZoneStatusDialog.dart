import 'package:flutter/material.dart';

import 'package:app/structures/enums/zoneStatus.dart';
import 'package:app/structures/models/zoneModel.dart';
import 'package:app/system/extensions.dart';
import 'package:app/tools/app/appIcons.dart';
import 'package:app/tools/app/appNavigator.dart';

class ChangeZoneStatusDialog extends StatefulWidget {
  final ZoneModel zone;

  const ChangeZoneStatusDialog({
    super.key,
    required this.zone,
  });

  @override
  State<ChangeZoneStatusDialog> createState() => _ChangeZoneStatusDialogState();
}
///=============================================================================
class _ChangeZoneStatusDialogState extends State<ChangeZoneStatusDialog> {
  late ZoneStatus selectedStatus;

  @override
  void initState(){
    super.initState();

    selectedStatus = widget.zone.status;
  }

  @override
  void dispose(){
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final zName = widget.zone.name != null ? ' (${widget.zone.name})' : '';

    return Material(
      child: Column(
        mainAxisSize: MainAxisSize.min,
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

          Text('تغییر وضعیت زون ${widget.zone.number} $zName').bold().fsR(2),
          const SizedBox(height: 25),

          const Card(
            color: Colors.amber,
            child: Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('در صورتی که با این قسمت آشتایی ندارید از تغییر دادن آن خودداری کنید'),
            ),
          ),

          const SizedBox(height: 15),

          GridView.builder(
            shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  crossAxisCount: 3,
                childAspectRatio: 2,
              ),
              itemCount: ZoneStatus.values.length,
              itemBuilder: itemBuilderForStatus
          ),

          const SizedBox(height: 15),
          SizedBox(
            width: 110,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
                onPressed: (){
                  AppNavigator.pop(context, result: selectedStatus);
                },
                child: const Text('ارسال')
            ),
          )
        ],
      ),
    );
  }

  Widget? itemBuilderForStatus(BuildContext context, int index) {
    final itm = ZoneStatus.values[index];

    return ActionChip(
      backgroundColor: itm == selectedStatus? null : Colors.grey,
        onPressed: (){
          selectedStatus = itm;
          setState(() {});
        },
        label: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 50,
              maxWidth: 95,
              maxHeight: 42,
            ),
            child: Center(
              child: Text(itm.getHumanName()).fitWidthOverflow(),
            )
        )
    );
  }
}
