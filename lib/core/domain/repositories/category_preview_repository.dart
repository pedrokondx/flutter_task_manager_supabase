import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';

abstract class CategoryPreviewRepository {
  Future<Either<CategoryException, List<CategoryEntity>>> getCategories(
    String userId,
  );
}
