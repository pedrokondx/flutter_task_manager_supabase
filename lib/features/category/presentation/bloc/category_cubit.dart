import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetCategoriesUsecase getCategories;
  final CreateCategoryUsecase createCategory;
  final UpdateCategoryUsecase updateCategory;
  final DeleteCategoryUsecase deleteCategory;

  CategoryCubit({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(const CategoryState());

  Future<void> load(String userId) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
    final result = await getCategories(userId);
    result.fold(
      (failure) {
        emit(state.copyWith(isLoading: false, errorMessage: failure.message));
      },
      (categories) {
        emit(state.copyWith(isLoading: false, categories: categories));
      },
    );
  }

  Future<void> create(CategoryEntity category) async {
    emit(
      state.copyWith(
        isSaving: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
    final result = await createCategory(category);
    result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (_) {
        final updated = [category, ...state.categories];
        emit(
          state.copyWith(
            categories: updated,
            isSaving: false,
            lastSuccessMessage: 'Category criada',
          ),
        );
      },
    );
  }

  Future<void> update(CategoryEntity category) async {
    emit(
      state.copyWith(
        isSaving: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
    final result = await updateCategory(category);
    result.fold(
      (failure) {
        emit(state.copyWith(isSaving: false, errorMessage: failure.message));
      },
      (_) {
        final updated = [
          category,
          ...state.categories.where((c) => c.id != category.id),
        ];
        emit(
          state.copyWith(
            categories: updated,
            isSaving: false,
            lastSuccessMessage: 'Category atualizada',
          ),
        );
      },
    );
  }

  Future<void> delete(String categoryId, String userId) async {
    emit(
      state.copyWith(
        isDeleting: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
    final result = await deleteCategory(categoryId, userId);
    result.fold(
      (failure) {
        emit(state.copyWith(isDeleting: false, errorMessage: failure.message));
      },
      (_) {
        final filtered = state.categories
            .where((c) => c.id != categoryId)
            .toList();
        emit(
          state.copyWith(
            categories: filtered,
            isDeleting: false,
            lastSuccessMessage: 'Category deletada',
          ),
        );
      },
    );
  }

  void upsertLocal(CategoryEntity category) {
    final updated = [
      category,
      ...state.categories.where((c) => c.id != category.id),
    ];
    emit(state.copyWith(categories: updated));
  }
}
