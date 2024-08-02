import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/data/factories/operation_permission.dart';
import 'package:mala_front/ui/protocols/modal/run_monitored_function.dart';
import 'package:mala_front/usecase/patient/api/background/send_deletion_in_background.dart';
import 'package:mala_front/usecase/patient/find_patient_by_id.dart';
import 'package:vit_logger/vit_logger.dart';

Future<void> deletePatient(
  int patientId, {
  required BuildContext? context,
  bool sendDeletionToServer = false,
}) async {
  if (!operationPermission.deletePatient) {
    logger.warn('Aborted patient deletion due to operation permission');
    return;
  }

  logger.warn('Deleting patient $patientId');
  var stopWatch = VitStopWatch('deletePatient');
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
