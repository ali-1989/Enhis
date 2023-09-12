
enum RelayStatus {
  shortCommand(1),
  twoState(2),
  customTime(3);

  final int _number;

  const RelayStatus(this._number);

  int getNumber(){
    return _number;
  }

  String getHumanName(){
    return switch(this){
      shortCommand => 'حالت تک فرمان',
      twoState => 'حالت خاموش/روشن',
      customTime => 'حالت مدت سفارشی',
    };
  }

  static RelayStatus from(dynamic data){
    if(data == null){
      return RelayStatus.shortCommand;
    }

    for(final i in RelayStatus.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return RelayStatus.shortCommand;
  }
}
