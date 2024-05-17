import 'dart:io';

import 'package:mala_front/factories/logger.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:system_info2/system_info2.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

import '../../factories/http_client.dart';

Future<void> insertRemoteLog({
  required String message,
  String? stack,
  String? context,
  Map<String, dynamic>? extras,
  String level = 'info',
}) async {
  try {
    var freeVMem = SysInfo.getFreeVirtualMemory();
    var totalVMem = SysInfo.getTotalVirtualMemory();
    var freePMemory = SysInfo.getFreePhysicalMemory();
    var totalPMemory = SysInfo.getTotalPhysicalMemory();
    await dio.post(
      '/log',
      data: {
        'context': context,
        'message': message,
        'level': level,
        'stack': stack,
        'pcName': SysInfo.userName,
        'extras': {
          'cpus': Platform.numberOfProcessors,
          'platform': Platform.operatingSystem,
          'ram': {
            'virtual': _usage(freeVMem, totalVMem),
            'physical': _usage(freePMemory, totalPMemory),
            'v_used': SysInfo.getVirtualMemorySize(),
          },
          if (extras != null) ...extras,
        },
      },
    );
  } catch (e) {
    logger.error(getErrorMessage(e) ?? 'Falha ao enviar logs');
  }
}

Map<String, dynamic> _usage(int free, int total) {
  return {
    'free': free.readableByteSize(),
    'total': total.readableByteSize(),
    '% free': ((free / total) * 100).toStringAsFixed(2),
  };
}
