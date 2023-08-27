import 'package:mala_front/models/address.dart';

class Patient {
  String? name;
  Address? address;
  List<String>? phones;
  String? motherName;
  String? cpf;
  String? observation;
  DateTime? birthDate;

  Patient({
    this.name,
    this.address,
    this.cpf,
    this.motherName,
    this.observation,
    this.phones,
    this.birthDate,
  });

  int? get years {
    if (birthDate == null) return null;
    var dif = DateTime.now().difference(birthDate!);
    return (dif.inDays / 365).floor();
  }

  bool get hasBirthDayThisMonth {
    var birth = birthDate;
    if (birth == null) return false;
    var nowMonth = DateTime.now().month;
    return nowMonth == birth.month;
  }

  bool get isBirthdayToday {
    var birth = birthDate;
    if (birth == null) return false;
    var now = DateTime.now();
    return now.month == birth.month && now.day == birth.day;
  }
}
