import 'package:mala_front/repositories/patient_api.dart';

import '../../../models/patient.dart';

Future<void> postPatientsChanges({
  List<Patient>? changed,
  List<String>? deleted,
}) async {
  var rep = PatientApiRepository();
  await rep.postChanges(
    changed: changed,
    deleted: deleted,
  );
}
