import '../../../../main.dart';

class RegisterRequest {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String phone;
  final String zipcode;

  const RegisterRequest({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.zipcode,
  });

  Map<String, dynamic> toJson() => {
    'email': email,
    'phone': phone,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'zipcode': zipcode,
    'domainId': domainId,
  }..removeWhere((key, value) => value == null || value == '');
}
