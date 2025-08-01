import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late CheckSessionUsecase useCase;

  final user = UserEntity(id: 'user123', email: 'me@example.com');
  final sessionFailure = AuthException.sessionCheckFailure('oops');

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeAuthException());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckSessionUsecase(mockRepository);
  });

  test('returns Right(UserEntity?) when repository returns user', () async {
    when(
      () => mockRepository.hasSession(),
    ).thenAnswer((_) async => Right(user));

    final result = await useCase.call();

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected success'),
      (maybeUser) => expect(maybeUser?.id, user.id),
    );
    verify(() => mockRepository.hasSession()).called(1);
  });

  test('returns Right(null) when repository returns null session', () async {
    when(
      () => mockRepository.hasSession(),
    ).thenAnswer((_) async => const Right(null));

    final result = await useCase.call();

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected success with null'),
      (maybeUser) => expect(maybeUser, isNull),
    );
    verify(() => mockRepository.hasSession()).called(1);
  });

  test('returns Left when repository fails', () async {
    when(
      () => mockRepository.hasSession(),
    ).thenAnswer((_) async => Left(sessionFailure));

    final result = await useCase.call();

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, sessionFailure.code),
      (_) => fail('Expected failure'),
    );
    verify(() => mockRepository.hasSession()).called(1);
  });
}
