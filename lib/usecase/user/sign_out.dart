import 'dart:async';

import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/usecase/logs/insert_remote_log.dart';
import 'package:mala_front/usecase/user/update_last_sync.dart';

import 'update_jwt.dart';

Future<void> signout() async {
  logger.debug('Signing out');
  // if (kDebugMode) {
  //   //await deleteUserFiles();
  // } else {
  // }
  try {
    await updateLastSync(DateTime(2020));
  } on Exception catch (_) {}
  logger.debug('Insering remote log "signed out"');
  unawaited(insertRemoteLog(
    message: 'Signing out',
    context: 'Sign out',
  ));
  logger.debug('Removing jwt');
  await updateJwt(null);
}
