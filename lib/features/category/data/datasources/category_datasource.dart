import 'package:supabase_todo/features/category/data/dtos/category_dto.dart';

abstract class CategoryDatasource {
  Future<List<CategoryDTO>> getCategories(String userId);
  Future<void> createCategory(CategoryDTO category);
  Future<void> updateCategory(CategoryDTO category);
  Future<void> deleteCategory(String categoryId, String userId);
}
