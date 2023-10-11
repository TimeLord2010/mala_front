import 'package:mala_front/usecase/file/pdf/tags/create_tags_pdf.dart';
import 'package:printing/printing.dart';

import '../../../../models/patient_tag.dart';

Future<void> printTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var bytes = await createTagsPdf(tags: tags);
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'etiquetas.pdf',
  );
}
