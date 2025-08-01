import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class CreateCategoryUsecase {
  final CategoryRepository repository;
  CreateCategoryUsecase(this.repository);

  Future<Either<CategoryException, Unit>> call(CategoryEntity category) {
    return repository.createCategory(category);
  }
}
