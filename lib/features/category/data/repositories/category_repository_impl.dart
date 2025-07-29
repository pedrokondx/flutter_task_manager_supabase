import 'package:supabase_todo/features/category/data/datasources/category_datasource.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryDatasource datasource;

  CategoryRepositoryImpl(this.datasource);

  @override
  Future<void> createCategory(CategoryEntity category) {
    final dto = CategoryDTO.fromEntity(category);
    return datasource.createCategory(dto);
  }

  @override
  Future<void> updateCategory(CategoryEntity category) {
    final dto = CategoryDTO.fromEntity(category);
    return datasource.updateCategory(dto);
  }

  @override
  Future<void> deleteCategory(String categoryId, String userId) {
    return datasource.deleteCategory(categoryId, userId);
  }
}
