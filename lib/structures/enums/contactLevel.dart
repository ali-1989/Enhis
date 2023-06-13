
enum ContactLevel {
  levelA(1), //admin
  levelB(2),
  levelC(3),
  levelD(4);

  final int _number;

  const ContactLevel(this._number);

  int getNumber(){
    return _number;
  }

  static ContactLevel from(dynamic number){
    if(number == null){
      return ContactLevel.levelD;
    }

    for(final i in ContactLevel.values){
      if(i._number == number){
        return i;
      }
    }

    return ContactLevel.levelD;
  }
}
