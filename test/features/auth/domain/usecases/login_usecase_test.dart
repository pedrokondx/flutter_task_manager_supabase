import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';

import '../../mocks.dart';
import '../../fakes.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LoginUsecase useCase;

  const email = 'test@example.com';
  const password = 'secret';
  final user = UserEntity(id: 'u1', email: email);
  final failure = AuthException.loginFailure('invalid');

  setUpAll(() {
    registerFallbackValue(FakeUserEntity());
    registerFallbackValue(FakeAuthException());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUsecase(mockRepository);
  });

  test('should return Right(UserEntity) when repository succeeds', () async {
    when(
      () => mockRepository.login(email, password),
    ).thenAnswer((_) async => Right(user));

    final result = await useCase.call(email, password);

    expect(result.isRight(), true);
    result.fold((_) => fail('Expected success'), (u) => expect(u.id, user.id));
    verify(() => mockRepository.login(email, password)).called(1);
  });

  test('should return Left(AuthException) when repository fails', () async {
    when(
      () => mockRepository.login(email, password),
    ).thenAnswer((_) async => Left(failure));

    final result = await useCase.call(email, password);

    expect(result.isLeft(), true);
    result.fold(
      (err) => expect(err.code, failure.code),
      (_) => fail('Expected failure'),
    );
    verify(() => mockRepository.login(email, password)).called(1);
  });
}
