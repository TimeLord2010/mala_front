import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:system_info2/system_info2.dart';
import 'package:vit/vit.dart' as vit;

import '../../factories/http_client.dart';

Future<void> insertRemoteLog({
  required String message,
  String? stack,
  String? context,
  Map<String, dynamic>? extras,
  String level = 'info',
}) async {
  try {
    var freeMem = SysInfo.getFreeVirtualMemory();
    var totalMem = SysInfo.getTotalVirtualMemory();
    await dio.post(
      '/log',
      data: {
        'context': context,
        'message': message,
        'level': level,
        'stack': stack,
        'pcName': SysInfo.userName,
        'extras': {
          'ram': {
            'free': freeMem.readableByteSize(),
            'total': totalMem.readableByteSize(),
            '%': ((freeMem / totalMem) * 100).toStringAsFixed(2),
          },
          'storage': {
            'free': SysInfo.getFreePhysicalMemory().readableByteSize(),
          },
          if (extras != null) ...extras,
        },
      },
    );
  } catch (e) {
    vit.logError(getErrorMessage(e) ?? 'Falha ao enviar logs');
  }
}
