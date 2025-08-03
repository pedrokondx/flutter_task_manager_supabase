import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';

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
  late UpdateCategoryUsecase usecase;

  const userId = 'user1';
  final updated = makeCategory(id: 'c1', userId: userId, name: 'new name');
  final conflicting = makeCategory(
    id: 'other',
    userId: userId,
    name: 'new name',
  );
  final updateFailure = CategoryException.categoryUpdateFailure('inner');

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    mockPreviewRepository = MockCategoryPreviewRepository();
    usecase = UpdateCategoryUsecase(mockRepository, mockPreviewRepository);
  });

  test('returns Right(Unit) when update succeeds (no conflict)', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right(<CategoryEntity>[]));
    when(
      () => mockRepository.updateCategory(updated),
    ).thenAnswer((_) async => const Right(unit));

    final result = await usecase.call(updated);

    expect(result.isRight(), true);
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verify(() => mockRepository.updateCategory(updated)).called(1);
  });

  test('returns Left when underlying update fails', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right(<CategoryEntity>[]));
    when(
      () => mockRepository.updateCategory(updated),
    ).thenAnswer((_) async => Left(updateFailure));

    final result = await usecase.call(updated);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_UPDATE_FAILED');
      expect(err.message, 'Failed to update category');
    }, (_) => fail('Expected failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verify(() => mockRepository.updateCategory(updated)).called(1);
  });

  test('returns Left when duplicate name exists on different id', () async {
    when(
      () => mockPreviewRepository.getCategories(userId),
    ).thenAnswer((_) async => right([conflicting]));

    final conflictAttempt = CategoryDTO.fromEntity(
      updated,
    ).copyWith(name: conflicting.name).toEntity();

    final result = await usecase.call(conflictAttempt);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.code, 'CATEGORY_ALREADY_EXISTS');
      expect(err.message, contains(conflictAttempt.name));
    }, (_) => fail('Expected duplicate conflict'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verifyNever(() => mockRepository.updateCategory(conflictAttempt));
  });

  test('returns Left when preview getCategories fails', () async {
    when(() => mockPreviewRepository.getCategories(userId)).thenAnswer(
      (_) async => left(CategoryException.getCategoriesFailure('err')),
    );

    final result = await usecase.call(updated);

    expect(result.isLeft(), true);
    result.fold((err) {
      expect(err.message.toLowerCase(), contains('failed'));
    }, (_) => fail('Expected failure'));
    verify(() => mockPreviewRepository.getCategories(userId)).called(1);
    verifyNever(() => mockRepository.updateCategory(updated));
  });
}
