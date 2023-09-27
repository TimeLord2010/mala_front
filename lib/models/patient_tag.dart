import 'package:mala_front/models/address.dart';

class PatientTag {
  String name;
  Address? address;

  PatientTag({
    required this.name,
    required this.address,
  }) {
    assert(name.isNotEmpty);
  }
}
