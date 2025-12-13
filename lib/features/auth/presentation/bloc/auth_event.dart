import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthLoginEvent extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginEvent({required this.email, required this.password});
}

class AuthSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  const AuthSignUpEvent({required this.email, required this.password});
}

class AuthLogoutEvent extends AuthEvent {}

class AuthCheckStatusEvent extends AuthEvent {}
