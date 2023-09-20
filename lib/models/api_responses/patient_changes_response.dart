import 'package:mala_front/models/patient.dart';

class PatientChangesResponse {
  ChangedPatients? changed;

  PatientChangesResponse({
    required this.changed,
  });

  factory PatientChangesResponse.fromMap(Map<String, dynamic> map) {
    var changed = map['changed'];
    return PatientChangesResponse(
      changed: changed != null ? ChangedPatients.fromMap(changed) : null,
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
