import '../entities/user.dart';

class LoginResponse {
  final User user;
  final String jwt;
  LoginResponse({
    required this.user,
    required this.jwt,
  });
}
