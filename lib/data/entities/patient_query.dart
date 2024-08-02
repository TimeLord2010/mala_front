import 'package:isar/isar.dart';
import 'package:mala_front/data/entities/address.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/enums/activities.dart';
import 'package:mala_front/data/factories/logger.dart';

class PatientQuery {
  String? name;
  String? district;
  String? street;
  int? minAge;
  int? maxAge;
  bool monthBirthday;
  Set<Activities>? activies;

  PatientQuery({
    this.name,
    this.district,
    this.street,
    this.minAge,
    this.maxAge,
    this.activies,
    this.monthBirthday = false,
  });

  bool get hasName => name?.isNotEmpty ?? false;
  bool get hasDistrict => district?.isNotEmpty ?? false;
  bool get hasStreet => street?.isNotEmpty ?? false;
  bool get hasActivities => activies?.isNotEmpty ?? false;

  bool get hasAddress => hasDistrict || hasStreet;
  bool get isEmptyQuery {
    if (minAge != null || maxAge != null) return false;
    return !hasAddress && !monthBirthday && !hasActivities;
  }

  QueryBuilder<Patient, Patient, QAfterSortBy> buildQuery(Isar isar) {
    var r = isar.patients.filter().nameContains(name ?? '');
    if (isEmptyQuery) {
      return r.sortByName();
    }
    var filter = r;
    if (minAge != null || maxAge != null) {
      filter = filter.yearOfBirthIsNotNull();
    }
    var now = DateTime.now();
    if (minAge != null) {
      var value = now.year - minAge!;
      logger.info('Min year: $value');
      filter = filter.yearOfBirthLessThan(value);
    }
    if (maxAge != null) {
      var value = now.year - maxAge!;
      logger.info('Max year: $value');
      filter = filter.yearOfBirthGreaterThan(value);
    }
    if (monthBirthday) {
      logger.info('Month birthday: ${now.day}/${now.month}');
      filter = filter.monthOfBirthIsNotNull().monthOfBirthEqualTo(now.month);
    }
    if (hasActivities) {
      logger.info('Has activity');
      filter = filter.activitiesIdLengthGreaterThan(0);
      for (var activity in activies!) {
        logger.info('Check if patient has activity ${activity.index} id');
        filter = filter.activitiesIdElementEqualTo(activity.index);
      }
    }
    if (!hasDistrict && !hasStreet) {
      return filter.nameContains('').sortByName();
    }
    return filter.address((q) {
      if (hasDistrict && hasStreet) {
        logger.info('Contains district and street');
        return q.districtContains(district!).streetContains(street!);
      } else if (hasDistrict) {
        logger.info('Contains district: $district');
        return q.districtContains(district!);
      } else {
        logger.info('Contains street: $street');
        return q.streetContains(street!);
      }
    }).sortByName();
  }
}
