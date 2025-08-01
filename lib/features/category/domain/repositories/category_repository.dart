import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';

abstract class CategoryRepository {
  Future<Either<CategoryException, Unit>> createCategory(
    CategoryEntity category,
  );
  Future<Either<CategoryException, Unit>> updateCategory(
    CategoryEntity category,
  );
  Future<Either<CategoryException, Unit>> deleteCategory(
    String categoryId,
    String userId,
  );
}
