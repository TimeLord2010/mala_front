import 'package:isar/isar.dart';
import 'package:mala_front/models/activities.dart';
import 'package:mala_front/models/address.dart';
import 'package:mala_front/models/patient.dart';
import 'package:vit/vit.dart';

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
    var r = isar.patients.where().nameStartsWith(name ?? '');
    if (isEmptyQuery) {
      return r.sortByName();
    }
    var filter = r.filter();
    if (minAge != null || maxAge != null) {
      filter = filter.yearOfBirthIsNotNull();
    }
    var now = DateTime.now();
    if (minAge != null) {
      var value = now.year - minAge!;
      logInfo('Min year: $value');
      filter = filter.yearOfBirthLessThan(value);
    }
    if (maxAge != null) {
      var value = now.year - maxAge!;
      logInfo('Max year: $value');
      filter = filter.yearOfBirthGreaterThan(value);
    }
    if (monthBirthday) {
      logInfo('Month birthday: ${now.day}/${now.month}');
      filter = filter.monthOfBirthIsNotNull().monthOfBirthEqualTo(now.month);
    }
    if (hasActivities) {
      logInfo('Has activity');
      filter = filter.activitiesIdLengthGreaterThan(0);
      for (var activity in activies!) {
        filter = filter.activitiesIdElementEqualTo(activity.index);
      }
    }
    return filter.address((q) {
      if (hasDistrict && hasStreet) {
        logInfo('Contains district and street');
        return q.districtContains(district!).streetContains(street!);
      } else if (hasDistrict) {
        logInfo('Container district');
        return q.districtContains(district!);
      } else {
        logInfo('Contains street');
        return q.streetContains(street!);
      }
    }).sortByName();
  }
}
