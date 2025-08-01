import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';

import '../../../../core/fakes.dart';
import '../../mocks.dart';

void main() {
  late MockCategoryRepository mockRepository;
  late DeleteCategoryUsecase usecase;

  const userId = 'user1';
  const categoryId = 'cat1';
  final failure = CategoryException.categoryDeletionFailure('inner');

  setUpAll(() {
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    usecase = DeleteCategoryUsecase(mockRepository);
  });

  test('returns Right(Unit) when deletion succeeds', () async {
    when(
      () => mockRepository.deleteCategory(categoryId, userId),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.call(categoryId, userId);

    expect(result.isRight(), true);
    verify(() => mockRepository.deleteCategory(categoryId, userId)).called(1);
  });

  test('returns Left when deletion fails', () async {
    when(
      () => mockRepository.deleteCategory(categoryId, userId),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.call(categoryId, userId);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_DELETION_FAILED');
      expect(err.message, 'Failed to delete category');
    }, (_) => fail('Expected failure'));
    verify(() => mockRepository.deleteCategory(categoryId, userId)).called(1);
  });
}
