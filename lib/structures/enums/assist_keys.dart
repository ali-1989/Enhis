import 'package:iris_tools/modules/stateManagers/assist.dart';

enum AssistKeys implements GroupId {
  updateAudioSeen(100);

  final int _number;

  const AssistKeys(this._number);

  int getNumber(){
    return _number;
  }
}
