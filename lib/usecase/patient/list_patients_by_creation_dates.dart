import 'package:mala_front/factories/patient_repository.dart';

import '../../models/patient.dart';

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
