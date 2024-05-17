import 'package:vit_dart_extensions/vit_dart_extensions.dart';

import '../patient.dart';

class GetPatientChangesResponse {
  List<Patient> changed;
  List<DeletedUsersRecord> deleted;

  GetPatientChangesResponse({
    required this.changed,
    required this.deleted,
  });

  factory GetPatientChangesResponse.fromMap(Map<String, dynamic> map) {
    List changed = map['changed'];
    List deleted = map['deleted'];
    return GetPatientChangesResponse(
      changed: changed.map((x) => Patient.fromMap(x)).toList(),
      deleted: deleted.map((x) => DeletedUsersRecord.fromMap(x)).toList(),
    );
  }

  get length {
    return changed.length + deleted.length;
  }

  get isEmpty {
    return length == 0;
  }
}

class DeletedUsersRecord {
  List<String> patientIds;
  String userId;
  DateTime disabledAt;

  DeletedUsersRecord({
    required this.patientIds,
    required this.userId,
    required this.disabledAt,
  });

  factory DeletedUsersRecord.fromMap(Map<String, dynamic> map) {
    List ids = map['patientIds'];
    return DeletedUsersRecord(
      patientIds: ids.map((x) => x as String).toList(),
      userId: map['userId'],
      disabledAt: map.getDateTime('disabledAt'),
    );
  }
}
