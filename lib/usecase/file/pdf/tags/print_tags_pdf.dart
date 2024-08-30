import 'dart:io';

import 'package:mala_api/mala_api.dart';
import 'package:printing/printing.dart';

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
