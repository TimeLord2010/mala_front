import 'dart:io';

import 'package:mala_front/usecase/file/pdf/tags/create_tags_pdf.dart';

import '../../../../models/patient_tag.dart';
import '../../../date/get_current_date_numbers.dart';
import '../../pick_directory.dart';

Future<File?> saveTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var dir = await pickDirectory();
  if (dir == null) return null;
  var bytes = await createTagsPdf(tags: tags);
  var filename = '${dir.path}/entiquetas ${getCurrentDateNumbers()}.pdf';
  final file = File(filename);
  await file.writeAsBytes(bytes);
  return file;
}
