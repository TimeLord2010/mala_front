import 'dart:io';

import 'package:mala_front/usecase/file/pdf/patients/create_patients_pdf.dart';

import '../../../../models/patient.dart';
import '../../pick_directory.dart';

Future<void> savePatientsPdf({
  required List<Patient> patients,
}) async {
  var dir = await pickDirectory();
  if (dir == null) return;
  var filename = '${dir.path}/Lista de pacientes.pdf';
  var file = File(filename);
  var bytes = await createPatientsPdf(patients: patients);
  await file.writeAsBytes(bytes);
}
