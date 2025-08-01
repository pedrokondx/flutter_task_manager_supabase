import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_events.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_state.dart';

import '../../mocks.dart';
import '../../fakes.dart';

void main() {
  late MockLoginUsecase loginUseCase;
  late MockCheckSessionUsecase checkSessionUseCase;
  late MockLogoutUsecase logoutUsecase;
  late MockRegisterUsecase registerUseCase;
  late AuthBloc bloc;

  const email = 'me@x.com';
  const password = 'secret';
  final user = UserEntity(id: 'u1', email: email);
  final loginFailure = AuthException.loginFailure('bad creds');

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeAuthException());
  });

  setUp(() {
    loginUseCase = MockLoginUsecase();
    checkSessionUseCase = MockCheckSessionUsecase();
    logoutUsecase = MockLogoutUsecase();
    registerUseCase = MockRegisterUsecase();

    bloc = AuthBloc(
      loginUsecase: loginUseCase,
      checkSessionUsecase: checkSessionUseCase,
      logoutUsecase: logoutUsecase,
      registerUsecase: registerUseCase,
    );
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthAuthenticated] when login succeeds',
    setUp: () {
      when(
        () => loginUseCase.call(email, password),
      ).thenAnswer((_) async => Right(user));
    },
    build: () => bloc,
    act: (b) => b.add(AuthLoginRequested(email, password)),
    expect: () => [AuthLoading(), AuthAuthenticated(user.id)],
    verify: (_) {
      verify(() => loginUseCase.call(email, password)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] when login fails',
    setUp: () {
      when(
        () => loginUseCase.call(email, password),
      ).thenAnswer((_) async => Left(loginFailure));
    },
    build: () => bloc,
    act: (b) => b.add(AuthLoginRequested(email, password)),
    expect: () => [AuthLoading(), AuthError(loginFailure.message)],
    verify: (_) {
      verify(() => loginUseCase.call(email, password)).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthUnauthenticated when check session returns null',
    setUp: () {
      when(
        () => checkSessionUseCase.call(),
      ).thenAnswer((_) async => const Right(null));
    },
    build: () => bloc,
    act: (b) => b.add(AuthCheckSession()),
    expect: () => [AuthUnauthenticated()],
  );

  blocTest<AuthBloc, AuthState>(
    'emits AuthAuthenticated when check session returns user',
    setUp: () {
      when(
        () => checkSessionUseCase.call(),
      ).thenAnswer((_) async => Right(user));
    },
    build: () => bloc,
    act: (b) => b.add(AuthCheckSession()),
    expect: () => [AuthAuthenticated(user.id)],
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthUnauthenticated] on logout success',
    setUp: () {
      when(
        () => logoutUsecase.call(),
      ).thenAnswer((_) async => const Right(unit));
    },
    build: () => bloc,
    act: (b) => b.add(AuthLogoutRequested()),
    expect: () => [AuthLoading(), AuthUnauthenticated()],
    verify: (_) {
      verify(() => logoutUsecase.call()).called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthError] on logout failure',
    setUp: () {
      when(
        () => logoutUsecase.call(),
      ).thenAnswer((_) async => Left(AuthException.logoutFailure('fail')));
    },
    build: () => bloc,
    act: (b) => b.add(AuthLogoutRequested()),
    expect: () => [AuthLoading(), isA<AuthError>()],
    verify: (_) {
      verify(() => logoutUsecase.call()).called(1);
    },
  );
}
