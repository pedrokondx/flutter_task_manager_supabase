import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
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
    final result = await getCategories(event.userId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (categories) => emit(CategoryLoaded(categories)),
    );
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await createCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(event.category.userId)),
    );
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await updateCategory(event.category);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(event.category.userId)),
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    final result = await deleteCategory(event.categoryId, event.userId);
    result.fold(
      (failure) => emit(CategoryError(failure.message)),
      (_) => add(LoadCategories(event.userId)),
    );
  }
}
