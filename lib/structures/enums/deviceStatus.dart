
enum DeviceStatus {
  unKnow(-1),
  active(4),
  inActive(0),
  semiActive(2),
  silent(3);

  final int _number;

  const DeviceStatus(this._number);

  int getNumber(){
    return _number;
  }

  static DeviceStatus from(dynamic data){
    if(data == null){
      return DeviceStatus.unKnow;
    }

    for(final i in DeviceStatus.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return DeviceStatus.unKnow;
  }
}
