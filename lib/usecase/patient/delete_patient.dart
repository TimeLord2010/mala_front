import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/factories/operation_permission.dart';
import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/ui/protocols/modal/run_monitored_function.dart';
import 'package:mala_front/usecase/patient/api/background/send_deletion_in_background.dart';
import 'package:mala_front/usecase/patient/find_patient_by_id.dart';
import 'package:vit/vit.dart';

Future<void> deletePatient(
  int patientId, {
  required BuildContext? context,
  bool sendDeletionToServer = false,
}) async {
  if (!operationPermission.deletePatient) {
    logWarn('Aborted patient deletion due to operation permission');
    return;
  }

  logWarn('Deleting patient $patientId');
  var stopWatch = StopWatch('deletePatient');
  try {
    var rep = await createPatientRepository();
    var patient = await findPatientById(patientId);
    if (patient == null) {
      return;
    }
    var remoteId = patient.remoteId;
    if (remoteId != null && sendDeletionToServer) {
      if (context != null) {
        await runMonitoredFunction(
          context: context,
          func: () => sendDeletionInBackground(
            remoteId,
            throwOnError: true,
          ),
          errorModalTitle: 'Error ao deletar paciente no servidor',
        );
      } else {
        unawaited(sendDeletionInBackground(remoteId));
      }
      // await postPatientsChanges(
      //   deleted: [remoteId],
      // );
    }
    await rep.delete(patientId);
  } finally {
    stopWatch.stop();
  }
}
