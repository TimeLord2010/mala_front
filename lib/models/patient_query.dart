import 'package:isar/isar.dart';
import 'package:mala_front/models/patient.dart';

class PatientQuery {
  String? name;
  PatientQuery({
    this.name,
  });

  QueryBuilder<Patient, Patient, QAfterWhereClause> buildWhere(Isar isar) {
    return isar.patients.where().nameStartsWith(name ?? '');
  }
}
