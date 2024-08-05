import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';

class OnlinePatientRepository extends PatientInterface<String> {
  @override
  Future<int> count([PatientQuery? query]) {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  Future<void> delete(Patient patient) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<void> deleteById(String id) {
    // TODO: implement deleteById
    throw UnimplementedError();
  }

  @override
  Future<Patient?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Patient>> list(PatientQuery query, {int? skip, int? limit}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Patient>> listByCreation(Iterable<DateTime> createdAts) {
    // TODO: implement listByCreation
    throw UnimplementedError();
  }

  @override
  Future<Patient> upsert(Patient patient) {
    // TODO: implement upsert
    throw UnimplementedError();
  }
}
