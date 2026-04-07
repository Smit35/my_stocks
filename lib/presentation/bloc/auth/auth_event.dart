import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;

  const LoginRequested(this.email);

  @override
  List<Object?> get props => [email];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;

  const RegisterRequested(this.name, this.email);

  @override
  List<Object?> get props => [name, email];
}

class LogoutRequested extends AuthEvent {}