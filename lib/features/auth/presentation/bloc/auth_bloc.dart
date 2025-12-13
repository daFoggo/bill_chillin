import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthGoogleSignInEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signInWithGoogle();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthAuthenticated(user)),
      );
    });

    on<AuthSignInEvent>((event, emit) async {
      emit(AuthLoading());

      final result = await authRepository.signInWithEmailPassword(
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

    on<AuthSignOutEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await authRepository.signOut();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (_) => emit(AuthUnauthenticated()),
      );
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
