import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final CheckSessionUseCase checkSessionUseCase;
  final LogoutUsecase logoutUsecase;
  final RegisterUseCase registerUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.checkSessionUseCase,
    required this.logoutUsecase,
    required this.registerUseCase,
  }) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLogin);
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthRegisterRequested>(_onRegister);
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await loginUseCase(event.email, event.password);
      emit(AuthAuthenticated(user.id));
    } catch (e) {
      emit(AuthError('Failed to login - ${(e as AuthException).message}'));
    }
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final hasSession = await checkSessionUseCase();
    emit(
      hasSession != null
          ? AuthAuthenticated(hasSession.id)
          : AuthUnauthenticated(),
    );
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
      emit(AuthError('Failed to logout - ${(e as AuthException).message}'));
    }
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await registerUseCase(event.email, event.password);
      emit(AuthAuthenticated(user.id));
    } catch (e) {
      emit(AuthError('Failed to register - ${(e as AuthException).message}'));
    }
  }
}
