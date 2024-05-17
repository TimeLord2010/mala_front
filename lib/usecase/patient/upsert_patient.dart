import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:mala_front/factories/patient_repository.dart';
import 'package:mala_front/models/patient.dart';
import 'package:mala_front/ui/protocols/modal/run_monitored_function.dart';
import 'package:mala_front/usecase/patient/api/background/send_changes_in_background.dart';
import 'package:mala_front/usecase/patient/profile_picture/save_or_remove_profile_picture.dart';
import 'package:vit_logger/vit_logger.dart';

Future<Patient> upsertPatient(
  Patient patient, {
  required BuildContext? context,
  Uint8List? pictureData,
  bool syncWithServer = true,
  bool ignorePicture = false,
}) async {
  var patientId = patient.id;
  var stopWatch = VitStopWatch('upsertPatient:$patientId');
  var rep = await createPatientRepository();
  var result = await rep.insert(patient);
  if (!ignorePicture) {
    await saveOrRemoveProfilePicture(
      patientId: result.id,
      data: pictureData,
    );
  }
  if (syncWithServer) {
    stopWatch.lap(tag: 'local done');
    if (context != null) {
      unawaited(runMonitoredFunction(
        context: context,
        func: () async {
          await sendChangesInBackground(patient, throwOnError: true);
        },
        errorModalTitle: 'Erro ao atualizar paciente no servidor',
      ));
    } else {
      unawaited(sendChangesInBackground(patient));
    }
    // await postPatientsChanges(
    //   changed: [patient],
    // );
  }
  stopWatch.stop();
  return result;
}
