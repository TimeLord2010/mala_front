import 'package:mala_front/usecase/file/pdf/patients/create_patients_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../models/patient.dart';

Future<void> printPatientsPdf({
  required List<Patient> patients,
}) async {
  var bytes = await createPatientsPdf(patients: patients);
  await Printing.layoutPdf(
    onLayout: (format) {
      return bytes;
    },
    name: 'Pacientes.pdf',
    dynamicLayout: false,
    format: PdfPageFormat.a4,
  );
}
