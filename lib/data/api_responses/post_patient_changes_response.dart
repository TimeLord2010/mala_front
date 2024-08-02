import 'package:mala_front/data/entities/patient.dart';

class PostPatientChangesResponse {
  ChangedPatients? changed;

  PostPatientChangesResponse({
    required this.changed,
  });

  factory PostPatientChangesResponse.fromMap(Map<String, dynamic> map) {
    var changed = map['changed'];
    return PostPatientChangesResponse(
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
    updated = updated.where((x) => x != null).toList();
    return ChangedPatients(
      inserted: inserted.map((x) => x as String).toList(),
      updated: updated.map((x) {
        return Patient.fromMap(x);
      }).toList(),
    );
  }
}
