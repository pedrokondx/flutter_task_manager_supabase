import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';

import '../../../../core/fakes.dart';
import '../../mocks.dart';

void main() {
  late MockCategoryRepository mockRepository;
  late UpdateCategoryUsecase usecase;

  const userId = 'user1';
  final now = DateTime.now();
  final category = CategoryEntity(
    id: 'c1',
    name: 'updated',
    userId: userId,
    createdAt: now,
    updatedAt: now,
  );
  final failure = CategoryException.categoryUpdateFailure('inner');

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    usecase = UpdateCategoryUsecase(mockRepository);
  });

  test('returns Right(Unit) when update succeeds', () async {
    when(
      () => mockRepository.updateCategory(category),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.call(category);

    expect(result.isRight(), true);
    verify(() => mockRepository.updateCategory(category)).called(1);
  });

  test('returns Left when update fails', () async {
    when(
      () => mockRepository.updateCategory(category),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.call(category);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_UPDATE_FAILED');
      expect(err.message, 'Failed to update category');
    }, (_) => fail('Expected failure'));
    verify(() => mockRepository.updateCategory(category)).called(1);
  });
}
