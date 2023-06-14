
enum NotifyToContactStatus {
  callAndSmsByRepeat(1),
  callAndSms(7),
  smsAndCallByRepeat(0),
  smsAndCall(6);

  final int _number;

  const NotifyToContactStatus(this._number);

  int getNumber(){
    return _number;
  }

  String getHumanName(){
    return switch(this){
      callAndSmsByRepeat => 'ابتدا تماس بعد پیامک (با تکرار)',
      callAndSms => 'ابتدا تماس بعد پیامک',
      smsAndCallByRepeat => 'ابتدا پیامک بعد تماس (با تکرار)',
      smsAndCall => 'ابتدا پیامک بعد تماس',
    };
  }

  static NotifyToContactStatus from(dynamic data){
    if(data == null){
      return NotifyToContactStatus.smsAndCallByRepeat;
    }

    for(final i in NotifyToContactStatus.values){
      if(data is int && i._number == data){
        return i;
      }

      if(data is String && i.name == data){
        return i;
      }
    }

    return NotifyToContactStatus.smsAndCallByRepeat;
  }
}
