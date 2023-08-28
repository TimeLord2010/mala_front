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

  DateTime? get birthDate {
    if (yearOfBirth == null || monthOfBirth == null || dayOfBirth == null) {
      return null;
    }
    return DateTime(yearOfBirth!, monthOfBirth!, dayOfBirth!);
  }

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
