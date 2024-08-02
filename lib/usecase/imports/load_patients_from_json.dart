import 'dart:convert';
import 'dart:io';

import '../../data/entities/patient.dart';

Future<List<Patient>> loadPatientsFromJson({
  required String filename,
}) async {
  var file = File(filename);
  var exists = file.existsSync();
  if (!exists) {
    return [];
  }
  var content = await file.readAsString();
  List data = json.decode(content);
  var patients = data.map((x) => Patient.fromMap(x));
  return patients.toList();
}
