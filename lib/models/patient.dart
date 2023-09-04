import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';

part 'patient.g.dart';

@collection
class Patient {
  Id id = Isar.autoIncrement;

  @Index(
    type: IndexType.value,
  )
  String? name;
  List<String>? phones;
  String? motherName;

  @Index()
  String? cpf;
  String? observation;

  /// Exists to improve performance for filtering users that
  /// have a certain age.
  @Index()
  int? yearOfBirth;

  /// Exists to improve query performance for month birthdays.
  @Index()
  int? monthOfBirth;

  /// Exists to improve query performance for birthdays.
  @Index()
  int? dayOfBirth;

  @Index(type: IndexType.value)
  List<short>? activitiesId;

  final address = IsarLink<Address>();

  Patient({
    this.name,
    this.cpf,
    this.motherName,
    this.observation,
    this.phones,
    this.activitiesId,
    this.dayOfBirth,
    this.monthOfBirth,
    this.yearOfBirth,
  });

  @ignore
  DateTime? get birthDate {
    if (yearOfBirth == null || monthOfBirth == null || dayOfBirth == null) {
      return null;
    }
    return DateTime(yearOfBirth!, monthOfBirth!, dayOfBirth!);
  }

  @ignore
  int? get years {
    if (birthDate == null) return null;
    var dif = DateTime.now().difference(birthDate!);
    return (dif.inDays / 365).floor();
  }

  @ignore
  bool get hasBirthDayThisMonth {
    var birth = birthDate;
    if (birth == null) return false;
    var nowMonth = DateTime.now().month;
    return nowMonth == birth.month;
  }

  @ignore
  bool get isBirthdayToday {
    var birth = birthDate;
    if (birth == null) return false;
    var now = DateTime.now();
    return now.month == birth.month && now.day == birth.day;
  }

  @ignore
  Map<String, dynamic> get toMap {
    return {
      'id': id,
      if (name != null) ...{
        'name': name,
      },
      if (phones != null) ...{
        'phones': phones,
      },
      if (motherName != null) ...{
        'montherName': motherName,
      },
      if (cpf != null) ...{
        'cpf': cpf,
      },
      if (observation != null) ...{
        'observation': observation,
      },
      if (yearOfBirth != null) ...{
        'yearOfBirth': yearOfBirth,
      },
      if (monthOfBirth != null) ...{
        'monthOfBirth': monthOfBirth,
      },
      if (dayOfBirth != null) ...{
        'dayOfBirth': dayOfBirth,
      },
      if (activitiesId != null) ...{
        'activitiesId': activitiesId,
      },
      if (address.value != null) ...{
        'address': address.value?.toMap,
      },
    };
  }

  @override
  @ignore
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Patient && id == other.id;
}
