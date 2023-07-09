
enum RelayStatus {
  dingDang(1),
  normal(2),
  spy(3),
  fullDay(4),
  disPower(5),
  silent(6);

  final int _number;

  const RelayStatus(this._number);

  int getNumber(){
    return _number;
  }

  String getHumanName(){
    return switch(this){
      normal => 'معمولی',
      dingDang => 'دینگ دانگ',
      fullDay => '24 ساعته',
      spy => 'جاسوسی',
      disPower => 'قطع برق',
      silent => 'بی صدا',
    };
  }

  static RelayStatus from(dynamic data){
    if(data == null){
      return RelayStatus.normal;
    }

    for(final i in RelayStatus.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return RelayStatus.normal;
  }

  static RelayStatus byShortName(String data){
    if(data == 'N'){//1
      return RelayStatus.normal;
    }

    if(data == 'D'){//2
      return RelayStatus.dingDang;
    }

    if(data == 'H'){//3
      return RelayStatus.fullDay;
    }

    if(data == 'S'){
      return RelayStatus.spy;
    }

    if(data == 'D'){
      return RelayStatus.disPower;
    }

    if(data == 'A'){
      return RelayStatus.silent;
    }

    return RelayStatus.dingDang;
  }
}
