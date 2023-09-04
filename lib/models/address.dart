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

  factory Address.fromMap(Map<String, dynamic> map) {
    var a = Address(
      zipCode: map['zipCode'],
      state: map['state'],
      city: map['city'],
      district: map['district'],
      street: map['street'],
      number: map['number'],
      complement: map['complement'],
    );
    map['id'] = map['id'];
    return a;
  }

  @ignore
  Map<String, dynamic> get toMap {
    return {
      'id': id,
      if (zipCode != null) ...{
        'zipCode': zipCode,
      },
      if (state != null) ...{
        'state': state,
      },
      if (city != null) ...{
        'city': city,
      },
      if (district != null) ...{
        'district': district,
      },
      if (street != null) ...{
        'street': street,
      },
      if (number != null) ...{
        'number': number,
      },
      if (complement != null) ...{
        'complement': complement,
      },
    };
  }
}
