import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';

import '../../mocks.dart';
import '../../fakes.dart';

void main() {
  late MockCategoryPreviewRepository mockPreviewRepository;
  late GetCategoriesUsecase usecase;

  const userId = 'user123';
  final now = DateTime.now();
  final categories = [
    CategoryEntity(
      id: 'c1',
      name: 'foo',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    ),
    CategoryEntity(
      id: 'c2',
      name: 'bar',
      userId: userId,
      createdAt: now,
      updatedAt: now,
    ),
  ];
  final failure = CategoryException.getCategoriesFailure('some inner');

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockPreviewRepository = MockCategoryPreviewRepository();
    usecase = GetCategoriesUsecase(mockPreviewRepository);
  });

  test(
    'returns Right(List<CategoryEntity>) when repository succeeds',
    () async {
      when(
        () => mockPreviewRepository.getCategories(userId),
      ).thenAnswer((_) async => Right(categories));

      final result = await usecase.call(userId);

      expect(result.isRight(), true);
      result.fold((_) => fail('Expected success'), (list) {
        expect(list, categories);
        expect(list.length, 2);
      });
      verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    },
  );

  test('returns Left when repository fails', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => Left(failure));

    final result = await usecase.call(userId);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'GET_CATEGORIES_FAILED');
      expect(err.message, 'Failed to get categories');
    }, (_) => fail('Expected failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
  });
}
