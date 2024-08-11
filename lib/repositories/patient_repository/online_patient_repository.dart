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

  Future<void> postPatientsChanges({
    List<Patient>? changed,
    List<String>? deleted,
  }) async {
    var api = PatientApiRepository();
    var response = await api.postChanges(
      changed: changed,
      deleted: deleted,
    );
    if (changed == null) return; // TODO: Remove picture from disk if deleted
    var insertedIds = response.changed?.inserted ?? [];
    List<Patient> newPatients = changed.where((x) => x.remoteId == null).toList();
    if (insertedIds.length != newPatients.length) {
      throw Exception('Api did respond with right number of inserted ids');
    }
    for (var i = 0; i < insertedIds.length; i++) {
      var remoteId = insertedIds[i];
      var patient = newPatients[i];
      await assignRemoteIdToPatient(patient, remoteId);
      if (patient.hasPicture == true) {
        await updateRemotePatientPicture(patient);
      }
    }
    var oldPatients = changed.where((x) => x.remoteId != null);
    for (var patient in oldPatients) {
      patient.uploadedAt = DateTime.now();
      await upsertPatient(
        patient,
        ignorePicture: true,
        syncWithServer: false,
        context: null,
      );
      await updateRemotePatientPicture(patient);
    }
    if (changed.isNotEmpty) {
      var last = changed.lastWhere(
        (x) => x.uploadedAt != null,
        orElse: () => Patient(),
      );
      if (last.isEmpty) {
        return;
      }
    }
  }
}
