import 'package:mala_front/data/entities/address.dart';
import 'package:mala_front/data/entities/patient.dart';

class PatientTag {
  String name;
  Address? address;

  PatientTag({
    required this.name,
    required this.address,
  });

  factory PatientTag.fromPatient(Patient patient) {
    return PatientTag(
      name: patient.name ?? '',
      address: patient.address.value,
    );
  }
}
