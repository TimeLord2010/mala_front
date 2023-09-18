import 'package:mala_front/models/patient.dart';

class PatientChangesResponse {
  ChangedPatients changed;

  PatientChangesResponse({
    required this.changed,
  });

  factory PatientChangesResponse.fromMap(Map<String, dynamic> map) {
    return PatientChangesResponse(
      changed: ChangedPatients.fromMap(map['changed']),
    );
  }
}

class ChangedPatients {
  List<String> inserted;
  List<Patient> updated;

  ChangedPatients({
    required this.inserted,
    required this.updated,
  });

  factory ChangedPatients.fromMap(Map<String, dynamic> map) {
    List inserted = map['inserted'];
    List updated = map['updated'];
    return ChangedPatients(
      inserted: inserted.map((x) => x as String).toList(),
      updated: updated.map((x) => Patient.fromMap(x)).toList(),
    );
  }
}
