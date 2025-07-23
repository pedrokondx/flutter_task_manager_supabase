import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckSessionUseCase checkSessionUseCase;
  final LogoutUsecase logoutUsecase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkSessionUseCase,
    required this.logoutUsecase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await loginUseCase(event.email, event.password);
      emit(AuthAuthenticated());
    } catch (e, stackTrace) {
      debugPrint('Login error: $e - StackTrace: $stackTrace');
      emit(AuthError('Failed to login'));
    }
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final hasSession = await checkSessionUseCase();
    emit(hasSession ? AuthAuthenticated() : AuthUnauthenticated());
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await logoutUsecase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to logout'));
    }
  }
}
