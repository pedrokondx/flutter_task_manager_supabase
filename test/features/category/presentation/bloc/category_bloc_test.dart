import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_events.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_state.dart';

import '../../../../core/fakes.dart';
import '../../../../core/mocks.dart';
import '../../mocks.dart';

void main() {
  late GetCategoriesUsecase getUsecase;
  late CreateCategoryUsecase createUsecase;
  late UpdateCategoryUsecase updateUsecase;
  late DeleteCategoryUsecase deleteUsecase;
  late CategoryBloc bloc;

  final now = DateTime.now();

  const userId = 'user1';
  final category = CategoryEntity(
    id: 'c1',
    name: 'name',
    userId: userId,
    createdAt: now,
    updatedAt: now,
  );
  final categoriesList = [category];
  final failure = CategoryException(message: 'error');

  setUpAll(() {
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    getUsecase = GetCategoriesUsecase(MockCategoryPreviewRepository());
    createUsecase = CreateCategoryUsecase(MockCategoryRepository());
    updateUsecase = UpdateCategoryUsecase(MockCategoryRepository());
    deleteUsecase = DeleteCategoryUsecase(MockCategoryRepository());

    bloc = CategoryBloc(
      getCategories: getUsecase,
      createCategory: createUsecase,
      updateCategory: updateUsecase,
      deleteCategory: deleteUsecase,
    );
  });

  blocTest<CategoryBloc, CategoryState>(
    'emits [CategoryLoading, CategoryLoaded] when loading succeeds',
    setUp: () {
      when(
        () => getUsecase.call(userId),
      ).thenAnswer((_) async => Right(categoriesList));
    },
    build: () => bloc,
    act: (b) => b.add(LoadCategories(userId)),
    expect: () => [CategoryLoading(), CategoryLoaded(categoriesList)],
    verify: (_) {
      verify(() => getUsecase.call(userId)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits [CategoryLoading, CategoryError] when loading fails',
    setUp: () {
      when(
        () => getUsecase.call(userId),
      ).thenAnswer((_) async => Left(failure));
    },
    build: () => bloc,
    act: (b) => b.add(LoadCategories(userId)),
    expect: () => [CategoryLoading(), CategoryError(failure.message)],
  );

  blocTest<CategoryBloc, CategoryState>(
    'after create emits load again on success',
    setUp: () {
      final mockGet = MockCategoryPreviewRepository();
      final mockCreate = MockCategoryRepository();
      getUsecase = GetCategoriesUsecase(mockGet);
      createUsecase = CreateCategoryUsecase(mockCreate);
      bloc = CategoryBloc(
        getCategories: getUsecase,
        createCategory: createUsecase,
        updateCategory: updateUsecase,
        deleteCategory: deleteUsecase,
      );

      when(
        () => createUsecase.call(category),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => getUsecase.call(userId),
      ).thenAnswer((_) async => Right(categoriesList));
    },
    build: () => bloc,
    act: (b) => b.add(CreateCategoryEvent(category)),
    expect: () => [
      // after successful creation it adds LoadCategories internally
      CategoryLoading(),
      CategoryLoaded(categoriesList),
    ],
    verify: (_) {
      verify(() => createUsecase.call(category)).called(1);
      verify(() => getUsecase.call(userId)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits error when create fails',
    setUp: () {
      when(
        () => createUsecase.call(category),
      ).thenAnswer((_) async => Left(failure));
    },
    build: () => bloc,
    act: (b) => b.add(CreateCategoryEvent(category)),
    expect: () => [CategoryError(failure.message)],
    verify: (_) {
      verify(() => createUsecase.call(category)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'after update emits load again on success',
    setUp: () {
      final mockGet = MockCategoryPreviewRepository();
      final mockUpdate = MockCategoryRepository();
      getUsecase = GetCategoriesUsecase(mockGet);
      updateUsecase = UpdateCategoryUsecase(mockUpdate);
      bloc = CategoryBloc(
        getCategories: getUsecase,
        createCategory: createUsecase,
        updateCategory: updateUsecase,
        deleteCategory: deleteUsecase,
      );

      when(
        () => updateUsecase.call(category),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => getUsecase.call(userId),
      ).thenAnswer((_) async => Right(categoriesList));
    },
    build: () => bloc,
    act: (b) => b.add(UpdateCategoryEvent(category)),
    expect: () => [CategoryLoading(), CategoryLoaded(categoriesList)],
    verify: (_) {
      verify(() => updateUsecase.call(category)).called(1);
      verify(() => getUsecase.call(userId)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits error when update fails',
    setUp: () {
      when(
        () => updateUsecase.call(category),
      ).thenAnswer((_) async => Left(failure));
    },
    build: () => bloc,
    act: (b) => b.add(UpdateCategoryEvent(category)),
    expect: () => [CategoryError(failure.message)],
    verify: (_) {
      verify(() => updateUsecase.call(category)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'after delete emits load again on success',
    setUp: () {
      final mockGet = MockCategoryPreviewRepository();
      final mockDelete = MockCategoryRepository();
      getUsecase = GetCategoriesUsecase(mockGet);
      deleteUsecase = DeleteCategoryUsecase(mockDelete);
      bloc = CategoryBloc(
        getCategories: getUsecase,
        createCategory: createUsecase,
        updateCategory: updateUsecase,
        deleteCategory: deleteUsecase,
      );

      when(
        () => deleteUsecase.call(category.id, userId),
      ).thenAnswer((_) async => const Right(unit));
      when(
        () => getUsecase.call(userId),
      ).thenAnswer((_) async => Right(categoriesList));
    },
    build: () => bloc,
    act: (b) => b.add(DeleteCategoryEvent(category.id, userId)),
    expect: () => [CategoryLoading(), CategoryLoaded(categoriesList)],
    verify: (_) {
      verify(() => deleteUsecase.call(category.id, userId)).called(1);
      verify(() => getUsecase.call(userId)).called(1);
    },
  );

  blocTest<CategoryBloc, CategoryState>(
    'emits error when delete fails',
    setUp: () {
      when(
        () => deleteUsecase.call(category.id, userId),
      ).thenAnswer((_) async => Left(failure));
    },
    build: () => bloc,
    act: (b) => b.add(DeleteCategoryEvent(category.id, userId)),
    expect: () => [CategoryError(failure.message)],
    verify: (_) {
      verify(() => deleteUsecase.call(category.id, userId)).called(1);
    },
  );
}
