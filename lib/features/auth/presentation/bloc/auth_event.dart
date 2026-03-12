part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}
final class Login extends AuthEvent {
  final String email;
  final String password;

  const Login({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

final class Register extends AuthEvent {
  final RegisterRequest registerRequest;
  final UserPreferenceRequest userPreferenceRequest;
  final bool isEdit;

  const Register({required this.registerRequest, required this.userPreferenceRequest, required this.isEdit});

  @override
  List<Object> get props => [registerRequest, userPreferenceRequest, isEdit];
}

final class UserPreferenceUpdate extends AuthEvent {
  final UserPreferenceRequest request;

  const UserPreferenceUpdate({required this.request});

  @override
  List<Object> get props => [request];
}



