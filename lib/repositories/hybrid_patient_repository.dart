import 'dart:async';

import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/entities/patient_query.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/repositories/local_patient_repository.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';

class HybridPatientRepository extends PatientInterface {
  final LocalPatientRepository localRepository;

  HybridPatientRepository({
    required this.localRepository,
  });

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
  Future<Iterable<Patient>> list(PatientQuery query, {int? skip, int? limit}) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<Patient> upsert(Patient patient) {
    // TODO: implement upsert
    throw UnimplementedError();
  }

  Future<void> sendAllToApi() async {
    var limit = 100;
    while (true) {
      var patients = await localRepository.findLocalPatients(skip: 0, limit: limit);
      if (patients.isEmpty) break;
      await postPatientsChanges(
        changed: patients,
        updateFromServer: false,
        modalContext: context,
      );
      unawaited(insertRemoteLog(
        message: 'Sending ${patients.length} local patients',
        context: 'Send local patients to server',
        extras: {
          'creationDates': patients.map((x) => x.createdAt).toList(),
        },
      ));
    }
  }
}
