import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';

abstract class PatientInterface {
  Future<Patient> upsert(Patient patient);

  Future<void> delete(String id);

  Future<Iterable<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  });

  Future<int> count(PatientQuery query);
}
