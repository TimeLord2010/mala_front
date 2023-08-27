import 'package:mala_front/models/address.dart';

class Patient {
  String? name;
  Address? address;
  List<String>? phones;
  String? motherName;
  String? cpf;
  String? observation;

  Patient({
    this.name,
    this.address,
    this.cpf,
    this.motherName,
    this.observation,
    this.phones,
  });
}
