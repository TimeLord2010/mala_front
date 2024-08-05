import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/data/entities/patient.dart';
import 'package:mala_front/data/factories/create_patient_repository.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/data/factories/operation_permission.dart';
import 'package:mala_front/ui/protocols/modal/run_monitored_function.dart';
import 'package:mala_front/usecase/patient/api/background/send_deletion_in_background.dart';
import 'package:vit_logger/vit_logger.dart';

Future<void> deletePatient(
  Patient patient, {
  required BuildContext? context,
}) async {
  if (!operationPermission.deletePatient) {
    logger.warn('Aborted patient deletion due to operation permission');
    return;
  }

  var stopWatch = VitStopWatch('deletePatient');
  try {
    var rep = await createPatientRepository();
    var remoteId = patient.remoteId;
    if (remoteId != null) {
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
    await rep.delete(patient);
  } finally {
    stopWatch.stop();
  }
}
