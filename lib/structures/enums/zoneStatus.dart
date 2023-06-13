
enum ZoneStatus {
  normal(1),
  dingDang(2),
  fullDay(3),
  guard(4),
  spy(6),
  blue(7),
  spyFullDay(8);

  final int _number;

  const ZoneStatus(this._number);

  int getNumber(){
    return _number;
  }

  String getHumanName(){
    return switch(this){
      normal => 'معمولی',
      dingDang => 'دینگ دانگ',
      fullDay => '24 ساعته',
      guard => 'گارد',
      spy => 'جاسوسی',
      blue => 'آبی',
      spyFullDay => 'جاسوسی 24 ساعته',
    };
  }

  static ZoneStatus from(dynamic data){
    if(data == null){
      return ZoneStatus.normal;
    }

    for(final i in ZoneStatus.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return ZoneStatus.normal;
  }
}
