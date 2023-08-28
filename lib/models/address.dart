import 'package:isar/isar.dart';

part 'address.g.dart';

@collection
class Address {
  Id id = Isar.autoIncrement;

  String? zipCode;
  String? state;
  String? city;

  @Index()
  String? district;

  @Index()
  String? street;

  String? number;
  String? complement;

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
