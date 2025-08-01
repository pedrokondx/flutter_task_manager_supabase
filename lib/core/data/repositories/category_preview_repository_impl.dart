import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/data/datasources/category_preview_datasource.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/core/domain/repositories/category_preview_repository.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';

class CategoryPreviewRepositoryImpl implements CategoryPreviewRepository {
  final CategoryPreviewDatasource datasource;

  CategoryPreviewRepositoryImpl(this.datasource);

  @override
  Future<Either<CategoryException, List<CategoryEntity>>> getCategories(
    String userId,
  ) async {
    try {
      final dtos = await datasource.getCategories(userId);
      return Right(dtos.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CategoryException.getCategoriesFailure(e));
    }
  }
}
