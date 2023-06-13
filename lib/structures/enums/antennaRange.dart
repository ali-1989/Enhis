
enum AntennaRange {
  unKnow(0),
  wake(1),
  good(2),
  veryGood(3);

  final int _number;

  const AntennaRange(this._number);

  int getNumber(){
    return _number;
  }

  static AntennaRange from(dynamic data){
    if(data == null){
      return AntennaRange.unKnow;
    }

    for(final i in AntennaRange.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return AntennaRange.unKnow;
  }
}
