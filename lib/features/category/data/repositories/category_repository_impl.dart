import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/data/datasources/category_datasource.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<Either<CategoryException, Unit>> createCategory(
    CategoryEntity category,
  ) async {
    try {
      final dto = CategoryDTO.fromEntity(category);
      await datasource.createCategory(dto);
      return Right(unit);
    } catch (e) {
      return Left(CategoryException.categoryCreationFailure(e));
    }
  }

  @override
  Future<Either<CategoryException, Unit>> updateCategory(
    CategoryEntity category,
  ) async {
    try {
      final dto = CategoryDTO.fromEntity(category);
      await datasource.updateCategory(dto);
      return Right(unit);
    } catch (e) {
      return Left(CategoryException.categoryUpdateFailure(e));
    }
  }

  @override
  Future<Either<CategoryException, Unit>> deleteCategory(
    String categoryId,
    String userId,
  ) async {
    try {
      await datasource.deleteCategory(categoryId, userId);
      return Right(unit);
    } catch (e) {
      return Left(CategoryException.categoryDeletionFailure(e));
    }
  }
}
