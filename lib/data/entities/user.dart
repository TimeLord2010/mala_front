import 'package:vit_dart_extensions/vit_dart_extensions.dart';

class User {
  final String id;
  final String email;
  DateTime? lastSync;
  User({
    required this.id,
    required this.email,
    this.lastSync,
  });
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      lastSync: map.getMaybeDateTime('lastSync'),
    );
  }
}
