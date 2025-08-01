import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/core/domain/repositories/category_preview_repository.dart';

class GetCategoriesUsecase {
  final CategoryPreviewRepository repository;
  GetCategoriesUsecase(this.repository);

  Future<Either<CategoryException, List<CategoryEntity>>> call(String userId) {
    return repository.getCategories(userId);
  }
}
