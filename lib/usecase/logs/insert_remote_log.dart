import 'dart:io';

import 'package:mala_front/data/factories/logger.dart';
import 'package:mala_front/usecase/error/get_error_message.dart';
import 'package:system_info2/system_info2.dart';
import 'package:vit_dart_extensions/vit_dart_extensions.dart';

import '../../data/factories/http_client.dart';

Future<void> insertRemoteLog({
  required String message,
  String? stack,
  String? context,
  Map<String, dynamic>? extras,
  String level = 'info',
}) async {
  try {
    int getVirtualMemorySize() {
      try {
        return SysInfo.getVirtualMemorySize();
      } catch (_) {
        return -1;
      }
    }

    var freeVMem = SysInfo.getFreeVirtualMemory();
    var totalVMem = SysInfo.getTotalVirtualMemory();
    var freePMemory = SysInfo.getFreePhysicalMemory();
    var totalPMemory = SysInfo.getTotalPhysicalMemory();

    var virtualMemorySize = getVirtualMemorySize();
    await dio.post(
      '/log',
      data: {
        'context': context,
        'message': message,
        'level': level,
        if (stack != null) ...{'stack': stack},
        'pcName': SysInfo.userName,
        'extras': {
          'cpus': Platform.numberOfProcessors,
          'platform': Platform.operatingSystem,
          'ram': {
            'virtual': _usage(freeVMem, totalVMem),
            'physical': _usage(freePMemory, totalPMemory),
            'v_used': virtualMemorySize,
          },
          if (extras != null) ...extras,
        },
      },
    );
  } catch (e) {
    var msg = getErrorMessage(e) ?? 'Falha ao enviar logs';
    logger.error('(insertRemoteLog) $msg');
  }
}

Map<String, dynamic> _usage(int free, int total) {
  return {
    'free': free.readableByteSize(),
    'total': total.readableByteSize(),
    '% free': ((free / total) * 100).toStringAsFixed(2),
  };
}
