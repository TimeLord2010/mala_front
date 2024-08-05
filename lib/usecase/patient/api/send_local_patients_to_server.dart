import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mala_front/data/interfaces/patient_interface.dart';
import 'package:mala_front/repositories/patient_repository/hybrid_patient_repository.dart';
import 'package:mala_front/ui/components/index.dart';
import 'package:mala_front/ui/protocols/modal/show_modal.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';

///
Future<void> sendLocalPatientsToServer({
  required PatientInterface rep,
  BuildContext? context,
}) async {
  if (rep is HybridPatientRepository) {
    try {
      await rep.sendAllToApi();
    } on Exception catch (e) {
      var msg = getErrorMessage(e) ?? 'Falha na sincronização';
      if (context != null) {
        await showModal(
          context: context,
          title: 'Falha no envio de patientes locais para a API',
          contentBuilder: (context) {
            return MalaText(msg);
          },
        );
      }
    }
  }
}
