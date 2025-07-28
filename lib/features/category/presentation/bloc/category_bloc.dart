import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/get_categories_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_events.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUsecase getCategories;
  final CreateCategoryUsecase createCategory;
  final UpdateCategoryUsecase updateCategory;
  final DeleteCategoryUsecase deleteCategory;

  CategoryBloc({
    required this.getCategories,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
  }) : super(CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await getCategories(event.userId);
      emit(CategoryLoaded(categories));
    } catch (e) {
      String errorMessage = 'Failed to load Categories';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to load Categories: ${e.toString()}';
      }
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await createCategory(event.category);
      add(LoadCategories(event.category.userId));
    } catch (e) {
      String errorMessage = 'Failed to create Category';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to create Category: ${e.toString()}';
      }
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await updateCategory(event.category);
      add(LoadCategories(event.category.userId));
    } catch (e) {
      String errorMessage = 'Failed to update Category';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to update Category: ${e.toString()}';
      }

      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await deleteCategory(event.categoryId, event.userId);
      add(LoadCategories(event.userId));
    } catch (e) {
      String errorMessage = 'Failed to delete Category';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to delete Category: ${e.toString()}';
      }

      emit(CategoryError(errorMessage));
    }
  }
}
