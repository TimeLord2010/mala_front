import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/patient/api/post_patients_changes.dart';

Future<void> sendLocalPatientsToServer({
  BuildContext? context,
}) async {
  var patientsRep = await createPatientRepository();
  var limit = 100;
  while (true) {
    var patients = await patientsRep.findLocalPatients(skip: 0, limit: limit);
    if (patients.isEmpty) break;
    await postPatientsChanges(
      changed: patients,
      updateFromServer: false,
      modalContext: context,
    );
    unawaited(insertRemoteLog(
      message: 'Sending ${patients.length} local patients',
      context: 'Send local patients to server',
      extras: {
        'creationDates': patients.map((x) => x.createdAt).toList(),
      },
    ));
  }
}
