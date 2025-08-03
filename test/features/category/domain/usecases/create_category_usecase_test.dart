import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';

import '../../../../core/fakes.dart';
import '../../../../core/mocks.dart';
import '../../mocks.dart';

CategoryEntity makeCategory({
  String id = 'c1',
  String userId = 'user1',
  String name = 'name',
}) {
  final now = DateTime.now();
  return CategoryEntity(
    id: id,
    userId: userId,
    name: name,
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockCategoryRepository mockRepository;
  late MockCategoryPreviewRepository mockPreviewRepository;
  late CreateCategoryUsecase usecase;

  const userId = 'user1';
  final category = makeCategory(userId: userId, name: 'name');
  final duplicate = makeCategory(id: 'c2', userId: userId, name: 'name');
  final creationFailure = CategoryException.categoryCreationFailure('inner');

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    mockPreviewRepository = MockCategoryPreviewRepository();
    usecase = CreateCategoryUsecase(mockRepository, mockPreviewRepository);
  });

  test('returns Right(Unit) when creation succeeds (no duplicate)', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right(<CategoryEntity>[]));
    when(
      () => mockRepository.createCategory(category),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.call(category);

    expect(result.isRight(), true);
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verify(() => mockRepository.createCategory(category)).called(1);
  });

  test('returns Left when underlying create fails', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right(<CategoryEntity>[]));
    when(
      () => mockRepository.createCategory(category),
    ).thenAnswer((_) async => Left(creationFailure));

    final result = await usecase.call(category);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_CREATION_FAILED');
      expect(err.message, 'Failed to create category');
    }, (_) => fail('Expected failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verify(() => mockRepository.createCategory(category)).called(1);
  });

  test('returns Left when duplicate name exists', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right([duplicate]));

    final result = await usecase.call(category);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_ALREADY_EXISTS');
      expect(err.message, contains(category.name));
    }, (_) => fail('Expected duplicate failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verifyNever(() => mockRepository.createCategory(category));
  });

  test('returns Left when preview getCategories fails', () async {
    when(() => mockPreviewRepository.getCategories(userId)).thenAnswer(
      (_) async => left(CategoryException.getCategoriesFailure('err')),
    );

    final result = await usecase.call(category);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.message.toLowerCase(), contains('failed'));
    }, (_) => fail('Expected failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verifyNever(() => mockRepository.createCategory(category));
  });
}
