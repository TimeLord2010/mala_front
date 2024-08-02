import 'dart:io';

import 'package:mala_front/usecase/file/pdf/tags/create_tags_pdf.dart';
import 'package:printing/printing.dart';

import '../../../../data/entities/patient_tag.dart';

Future<void> printTagsPdf({
  required Iterable<PatientTag> tags,
}) async {
  var bytes = await createTagsPdf(tags: tags);
  if (Platform.isMacOS) {
    await Printing.layoutPdf(
      onLayout: (format) {
        return bytes;
      },
      dynamicLayout: false,
    );
  } else {
    await Printing.sharePdf(
      bytes: bytes,
      filename: 'etiquetas.pdf',
    );
  }
}
