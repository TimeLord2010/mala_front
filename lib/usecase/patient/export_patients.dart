import 'dart:convert';
import 'dart:io';

import 'package:mala_front/models/patient_query.dart';
import 'package:mala_front/usecase/patient/count_patients.dart';
import 'package:mala_front/usecase/patient/list_patients.dart';

Future<void> exportPatients({
  required PatientQuery query,
  required String filename,
  required void Function(int total, int processed) onProgress,
  int step = 200,
}) async {
  var file = File(filename);
  await file.create(recursive: true);
  var total = await countPatients(query);
  var stream = file.openWrite();
  stream.write('[');
  int processed = 0;
  for (int page = 0; processed < total; page++) {
    var toBeProcessed = total - (page * step);
    var hasNextPage = toBeProcessed > step;
    var items = await listPatients(
      patientQuery: query,
      limit: step,
      skip: page * step,
    );
    var maps = items.map((x) => jsonEncode(x.toMap)).join(',');
    if (hasNextPage) {
      stream.write('$maps,');
    } else {
      stream.write(maps);
    }
    processed += items.length;
    onProgress(total, processed);
    await Future.delayed(const Duration(milliseconds: 10));
  }
  stream.write(']');
  await stream.close();
}
