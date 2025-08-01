import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  late MockAuthRepository mockRepository;
  late LogoutUsecase useCase;

  final logoutFailure = AuthException.logoutFailure('bad');

  setUpAll(() {
    registerFallbackValue(FakeAuthException());
  });

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUsecase(mockRepository);
  });

  test('returns Right(Unit) on successful logout', () async {
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => const Right(unit));

    final result = await useCase.call();

    expect(result.isRight(), true);
    result.fold((_) => fail('Expected success'), (v) => expect(v, unit));
    verify(() => mockRepository.logout()).called(1);
  });

  test('returns Left when logout fails', () async {
    when(
      () => mockRepository.logout(),
    ).thenAnswer((_) async => Left(logoutFailure));

    final result = await useCase.call();

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, logoutFailure.code),
      (_) => fail('Expected failure'),
    );
    verify(() => mockRepository.logout()).called(1);
  });
}
