import 'dart:async';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/ui/components/index.dart';
import 'package:mala_front/ui/protocols/modal/show_modal.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';

/// Executes the given function [func] and if it errors, an modal is shown.
Future<bool> runMonitoredFunction({
  required BuildContext context,
  required Future<void> Function() func,
  required String errorModalTitle,
}) async {
  try {
    await func();
    return true;
  } catch (e, stack) {
    var msg = getErrorMessage(e) ?? 'Erro desconhecido';
    logger.error(msg);
    unawaited(insertRemoteLog(
      message: msg,
      context: errorModalTitle,
      stack: stack.toString(),
      level: 'error',
    ));
    await showModal(
      context: context,
      title: errorModalTitle,
      contentBuilder: (context) {
        return MalaText(msg);
      },
      actions: [
        Button(
          child: const Text('Ok'),
          onPressed: () => Navigator.pop(context, 'Ok'),
        ),
      ],
    );
    return false;
  }
}
