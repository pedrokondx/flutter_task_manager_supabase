import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/category/presentation/bloc/category_cubit.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';

import '../../../../core/mocks.dart';
import '../../../../core/fakes.dart';
import '../../mocks.dart';

CategoryEntity makeCategory({
  String id = 'c1',
  String userId = 'user1',
  String name = 'General',
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
  late GetCategoriesUsecase getCategories;
  late CreateCategoryUsecase createCategory;
  late UpdateCategoryUsecase updateCategory;
  late DeleteCategoryUsecase deleteCategory;
  late MockCategoryRepository mockCategoryRepository;
  late MockCategoryPreviewRepository mockCategoryPreviewRepository;
  late CategoryCubit cubit;

  const userId = 'user1';
  final category = makeCategory();

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    mockCategoryPreviewRepository = MockCategoryPreviewRepository();
    getCategories = GetCategoriesUsecase(mockCategoryPreviewRepository);
    createCategory = CreateCategoryUsecase(
      mockCategoryRepository,
      mockCategoryPreviewRepository,
    );
    updateCategory = UpdateCategoryUsecase(
      mockCategoryRepository,
      mockCategoryPreviewRepository,
    );
    deleteCategory = DeleteCategoryUsecase(mockCategoryRepository);

    cubit = CategoryCubit(
      getCategories: getCategories,
      createCategory: createCategory,
      updateCategory: updateCategory,
      deleteCategory: deleteCategory,
    );
  });

  group('load', () {
    blocTest<CategoryCubit, CategoryState>(
      'emits loading then populated on success',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right([category]));
        return cubit;
      },
      act: (c) => c.load(userId),
      expect: () => [
        const CategoryState(isLoading: true),
        CategoryState(isLoading: false, categories: [category]),
      ],
      verify: (_) {
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'emits error when getCategories fails',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer(
          (_) async => left(CategoryException.getCategoriesFailure('fail')),
        );
        return cubit;
      },
      act: (c) => c.load(userId),
      expect: () => [
        const CategoryState(isLoading: true),
        const CategoryState(
          isLoading: false,
          errorMessage: 'Failed to get categories',
        ),
      ],
    );
  });

  group('create', () {
    blocTest<CategoryCubit, CategoryState>(
      'adds category and shows success message on success',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right(<CategoryEntity>[]));
        when(
          () => mockCategoryRepository.createCategory(category),
        ).thenAnswer((_) async => const Right(unit));
        return cubit;
      },
      seed: () => const CategoryState(),
      act: (c) => c.create(category),
      expect: () => [
        CategoryState(isSaving: true),
        CategoryState(
          categories: [category],
          isSaving: false,
          lastSuccessMessage: 'Category criada',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
        verify(() => mockCategoryRepository.createCategory(category)).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'shows error on creation failure',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right(<CategoryEntity>[]));
        when(() => mockCategoryRepository.createCategory(category)).thenAnswer(
          (_) async => left(CategoryException.categoryCreationFailure('err')),
        );
        return cubit;
      },
      seed: () => const CategoryState(),
      act: (c) => c.create(category),
      expect: () => [
        CategoryState(isSaving: true),
        CategoryState(
          isSaving: false,
          errorMessage: 'Failed to create category',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
        verify(() => mockCategoryRepository.createCategory(category)).called(1);
      },
    );
  });

  group('update', () {
    final updated = makeCategory(name: 'Changed');

    blocTest<CategoryCubit, CategoryState>(
      'updates category and shows success message',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right(<CategoryEntity>[]));
        when(
          () => mockCategoryRepository.updateCategory(updated),
        ).thenAnswer((_) async => const Right(unit));
        return cubit;
      },
      seed: () => CategoryState(categories: [category]),
      act: (c) => c.update(updated),
      expect: () => [
        CategoryState(categories: [category], isSaving: true),
        CategoryState(
          categories: [updated],
          isSaving: false,
          lastSuccessMessage: 'Category atualizada',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
        verify(() => mockCategoryRepository.updateCategory(updated)).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'shows error on update failure',
      build: () {
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right(<CategoryEntity>[]));
        when(() => mockCategoryRepository.updateCategory(updated)).thenAnswer(
          (_) async => left(CategoryException.categoryUpdateFailure('err')),
        );
        return cubit;
      },
      seed: () => CategoryState(categories: [category]),
      act: (c) => c.update(updated),
      expect: () => [
        CategoryState(categories: [category], isSaving: true),
        CategoryState(
          categories: [category],
          isSaving: false,
          errorMessage: 'Failed to update category',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
        verify(() => mockCategoryRepository.updateCategory(updated)).called(1);
      },
    );
  });

  group('delete', () {
    blocTest<CategoryCubit, CategoryState>(
      'removes category and shows success',
      build: () {
        when(
          () => mockCategoryRepository.deleteCategory(category.id, userId),
        ).thenAnswer((_) async => const Right(unit));
        return cubit;
      },
      seed: () => CategoryState(categories: [category]),
      act: (c) => c.delete(category.id, userId),
      expect: () => [
        CategoryState(categories: [category], isDeleting: true),
        CategoryState(
          categories: [],
          isDeleting: false,
          lastSuccessMessage: 'Category deletada',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryRepository.deleteCategory(category.id, userId),
        ).called(1);
      },
    );

    blocTest<CategoryCubit, CategoryState>(
      'shows error when deletion fails',
      build: () {
        when(
          () => mockCategoryRepository.deleteCategory(category.id, userId),
        ).thenAnswer(
          (_) async => left(CategoryException.categoryDeletionFailure('err')),
        );
        return cubit;
      },
      seed: () => CategoryState(categories: [category]),
      act: (c) => c.delete(category.id, userId),
      expect: () => [
        CategoryState(categories: [category], isDeleting: true),
        CategoryState(
          categories: [category],
          isDeleting: false,
          errorMessage: 'Failed to delete category',
        ),
      ],
      verify: (_) {
        verify(
          () => mockCategoryRepository.deleteCategory(category.id, userId),
        ).called(1);
      },
    );
  });

  group('upsertLocal', () {
    final existing = makeCategory(id: 'c2');
    final newCategory = makeCategory(id: 'c3');

    test('adds new category to front without calling usecase', () {
      final initial = CategoryState(categories: [existing]);
      cubit.emit(initial);
      cubit.upsertLocal(newCategory);
      expect(cubit.state.categories.first, newCategory);
      expect(cubit.state.categories.length, 2);
    });

    test('replaces existing with same id', () {
      final modified = makeCategory(id: 'c2', name: 'changed');
      final initial = CategoryState(categories: [existing]);
      cubit.emit(initial);
      cubit.upsertLocal(modified);
      expect(cubit.state.categories.first.name, 'changed');
      expect(cubit.state.categories.length, 1);
    });
  });
}
