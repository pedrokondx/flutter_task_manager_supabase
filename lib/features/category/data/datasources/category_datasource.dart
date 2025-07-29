import 'package:supabase_todo/core/data/dtos/category_dto.dart';

abstract class CategoryDatasource {
  Future<void> createCategory(CategoryDTO category);
  Future<void> updateCategory(CategoryDTO category);
  Future<void> deleteCategory(String categoryId, String userId);
}
