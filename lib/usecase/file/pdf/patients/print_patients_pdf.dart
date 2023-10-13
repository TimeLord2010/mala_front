import 'package:mala_front/usecase/file/pdf/patients/create_patients_pdf.dart';
import 'package:printing/printing.dart';

import '../../../../models/patient.dart';

Future<void> printPatientsPdf({
  required List<Patient> patients,
}) async {
  var bytes = await createPatientsPdf(patients: patients);
  await Printing.sharePdf(
    bytes: bytes,
    filename: 'Pacientes.pdf',
  );
}
