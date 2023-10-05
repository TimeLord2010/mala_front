import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:vit/vit.dart';

import '../../factories/http_client.dart';

Future<void> insertRemoteLog(String context, String message, [String level = 'info']) async {
  try {
    await dio.post(
      '/log',
      data: {
        "context": context,
        "message": message,
        "level": level,
      },
    );
  } catch (e) {
    logError(getErrorMessage(e) ?? 'Falha ao enviar logs');
  }
}
