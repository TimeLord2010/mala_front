import 'dart:convert';
import 'dart:io';

import '../../models/patient.dart';

Future<List<Patient>> importPatients({
  required String filename,
}) async {
  var file = File(filename);
  var exists = await file.exists();
  if (!exists) {
    return [];
  }
  var content = await file.readAsString();
  List data = json.decode(content);
  var patients = data.map((x) => Patient.fromMap(x));
  return patients.toList();
}
