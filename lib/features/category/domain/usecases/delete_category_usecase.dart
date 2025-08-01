import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class DeleteCategoryUsecase {
  final CategoryRepository repository;
  DeleteCategoryUsecase(this.repository);

  Future<Either<CategoryException, Unit>> call(
    String categoryId,
    String userId,
  ) {
    return repository.deleteCategory(categoryId, userId);
  }
}
