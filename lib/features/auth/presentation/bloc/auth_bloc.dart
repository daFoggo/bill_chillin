import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthLoginEvent>((event, emit) async {
      emit(AuthLoading()); // Bắt đầu xoay

      final result = await authRepository.loginWithEmailPassword(
        event.email,
        event.password,
      );

      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    on<AuthSignUpEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signUpWithEmailPassword(
        event.email,
        event.password,
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    on<AuthLogoutEvent>((event, emit) async {
      emit(AuthLoading());
      await authRepository.logout();
      emit(AuthUnauthenticated());
    });

    on<AuthCheckStatusEvent>((event, emit) async {
      final result = await authRepository.getCurrentUser();
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) => emit(AuthAuthenticated(user)),
      );
    });
  }
}
