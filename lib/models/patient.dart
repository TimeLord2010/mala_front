import 'package:isar/isar.dart';
import 'package:mala_front/models/address.dart';
import 'package:vit/vit.dart';

part 'patient.g.dart';

@collection
class Patient {
  Id id = Isar.autoIncrement;

  @Index(
    type: IndexType.hash,
  )
  String? remoteId;

  @ignore
  DateTime? uploadedAt;

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

  @Index()
  DateTime? createdAt;

  @Index()
  DateTime? updatedAt;

  final address = IsarLink<Address>();

  Patient({
    this.remoteId,
    this.uploadedAt,
    this.name,
    this.cpf,
    this.motherName,
    this.observation,
    this.phones,
    this.activitiesId,
    this.dayOfBirth,
    this.monthOfBirth,
    this.yearOfBirth,
    this.createdAt,
    this.updatedAt,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    List? phones = map['phones'];
    List? activities = map['activitiesId'];
    var p = Patient(
      name: map['name'],
      phones: phones?.map((x) => x as String).toList(),
      motherName: map['motherName'],
      cpf: map['cpf'],
      observation: map['observation'],
      yearOfBirth: map['yearOfBirth'],
      monthOfBirth: map['monthOfBirth'],
      dayOfBirth: map['dayOfBirth'],
      activitiesId: activities?.map((x) {
        if (x is int) {
          return x;
        }
        if (x is String) {
          return int.parse(x);
        }
        throw Exception('Invalid activity index: $x');
      }).toList(),
      createdAt: map.getMaybeDateTime('createdAt'),
      updatedAt: map.getMaybeDateTime('updatedAt'),
      uploadedAt: map.getMaybeDateTime('uploadedAt'),
      remoteId: map['remoteId'],
    );
    var address = map['address'];
    if (address != null) {
      p.address.value = Address.fromMap(address);
    }
    dynamic id = map['id'];
    if (id is int) {
      p.id = id;
    } else if (id is String) {
      p.remoteId = id;
    }
    return p;
  }

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
      if (remoteId != null) ...{
        'remoteId': remoteId,
      },
      if (uploadedAt != null) ...{
        'uploadedAt': uploadedAt!.toIso8601String(),
      },
      if (name != null) ...{
        'name': name,
      },
      if (phones?.isNotEmpty ?? false) ...{
        'phones': phones,
      },
      if (motherName != null) ...{
        'motherName': motherName,
      },
      if (cpf?.isNotEmpty ?? false) ...{
        'cpf': cpf,
      },
      if (observation?.isNotEmpty ?? false) ...{
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
      if (activitiesId?.isNotEmpty ?? false) ...{
        'activitiesId': activitiesId,
      },
      if (address.value != null) ...{
        'address': address.value?.toMap,
      },
      if (createdAt != null) ...{
        'createdAt': createdAt!.toIso8601String(),
      },
      if (updatedAt != null) ...{
        'updatedAt': updatedAt!.toIso8601String(),
      }
    };
  }

  @ignore
  Map<String, dynamic> get toApiMap {
    var map = toMap;
    map.remove('id');
    var remoteId = map['remoteId'];
    if (remoteId != null) {
      map['id'] = remoteId;
    }
    return map;
  }

  @ignore
  bool get isEmpty {
    if (id != Isar.autoIncrement) return false;
    if (name != null || cpf != null || motherName != null) return false;
    if (dayOfBirth != null || monthOfBirth != null || yearOfBirth != null) {
      return false;
    }
    if (remoteId != null || uploadedAt != null) return false;
    if (observation != null) return false;
    if (createdAt != null) return false;
    return true;
  }

  @override
  @ignore
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Patient && id == other.id;
}
