import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUsecase loginUsecase;
  final CheckSessionUsecase checkSessionUsecase;
  final LogoutUsecase logoutUsecase;
  final RegisterUsecase registerUsecase;

  AuthBloc({
    required this.loginUsecase,
    required this.checkSessionUsecase,
    required this.logoutUsecase,
    required this.registerUsecase,
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
    final result = await loginUsecase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user.id)),
    );
  }

  Future<void> _onCheckSession(
    AuthCheckSession event,
    Emitter<AuthState> emit,
  ) async {
    final result = await checkSessionUsecase();
    result.fold((failure) => emit(AuthError(failure.message)), (hasSession) {
      if (hasSession == null) {
        emit(AuthUnauthenticated());
        return;
      }
      emit(AuthAuthenticated(hasSession.id));
    });
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logoutUsecase();
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }

  Future<void> _onRegister(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await registerUsecase(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user.id)),
    );
  }
}
