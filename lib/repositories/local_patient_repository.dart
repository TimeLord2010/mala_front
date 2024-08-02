import 'package:isar/isar.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:vit_logger/vit_logger.dart';

class LocalPatientRepository extends PatientInterface {
  final Isar isar;

  LocalPatientRepository(this.isar);

  @override
  Future<int> count(PatientQuery query) {
    // TODO: implement count
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future<Iterable<Patient>> list(
    PatientQuery query, {
    int? skip,
    int? limit,
  }) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Patient> upsert(Patient patient) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  /// Fetches the patients who do not have the "remoteId" field set.
  Future<List<Patient>> findLocalPatients({
    required int skip,
    required int limit,
  }) {
    var stopWatch = VitStopWatch('findLocalPatients');
    var query = isar.patients.where();
    var patients = query.remoteIdIsNull().offset(skip).limit(limit).findAll();
    stopWatch.stop();
    return patients;
  }
}
