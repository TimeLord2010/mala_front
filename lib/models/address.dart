import 'package:isar/isar.dart';
import 'package:mala_front/models/patient.dart';

part 'address.g.dart';

@collection
class Address {
  Id id = Isar.autoIncrement;

  String? zipCode;
  String? state;
  String? city;

  @Index(
    type: IndexType.value,
  )
  String? district;

  @Index(
    type: IndexType.value,
  )
  String? street;

  String? number;
  String? complement;

  @Backlink(to: 'address')
  final patient = IsarLink<Patient>();

  Address({
    this.city,
    this.district,
    this.number,
    this.state,
    this.street,
    this.zipCode,
    this.complement,
  });
}
