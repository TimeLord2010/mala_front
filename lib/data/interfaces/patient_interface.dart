import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';

abstract class PatientInterface<T> {
  Future<Patient> upsert(Patient patient);

  Future<void> delete(Patient patient);

  Future<void> deleteById(T id);

  Future<Patient?> getById(T id);

  Future<Iterable<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  });

  Future<Iterable<Patient>> listByCreation(Iterable<DateTime> createdAts);

  Future<int> count([PatientQuery? query]);
}
