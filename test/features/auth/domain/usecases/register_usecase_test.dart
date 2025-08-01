import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late RegisterUsecase useCase;

  const email = 'new@user.com';
  const password = 'strongpass';
  final user = UserEntity(id: 'u1', email: email);
  final registerFailure = AuthException.registrationFailure('conflict');

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeAuthException());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUsecase(mockRepository);
  });

  test('returns Right(UserEntity) when repository succeeds', () async {
    when(
      () => mockRepository.register(email, password),
    ).thenAnswer((_) async => Right(user));

    final result = await useCase.call(email, password);

    expect(result.isRight(), true);
    result.fold((_) => fail('Expected success'), (u) => expect(u.id, user.id));
    verify(() => mockRepository.register(email, password)).called(1);
  });

  test('returns Left when repository fails', () async {
    when(
      () => mockRepository.register(email, password),
    ).thenAnswer((_) async => Left(registerFailure));

    final result = await useCase.call(email, password);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, registerFailure.code),
      (_) => fail('Expected failure'),
    );
    verify(() => mockRepository.register(email, password)).called(1);
  });
}
