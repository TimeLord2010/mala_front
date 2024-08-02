import 'package:mala_front/data/factories/create_patient_repository.dart';

import '../../data/entities/patient.dart';

Future<Iterable<Patient>> listPatientsByCreation({
  required Iterable<DateTime> createdAts,
}) async {
  if (createdAts.isEmpty) return [];
  var rep = await createPatientRepository();
  var patients = await rep.listUsingCreatedAts(
    createdAts: createdAts,
  );
  return patients;
}
