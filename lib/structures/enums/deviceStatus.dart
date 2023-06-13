
enum DeviceStatus {
  unKnow(0),
  active(11),
  inActive(10),
  semiActive(13),
  silent(12);

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
