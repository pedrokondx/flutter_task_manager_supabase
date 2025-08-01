import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/category/data/datasources/category_datasource.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';

class CategorySupabaseDatasource implements CategoryDatasource {
  final SupabaseClient supabase;

  CategorySupabaseDatasource(this.supabase);

  @override
  Future<void> createCategory(CategoryDTO dto) async {
    try {
      final categoryData = dto.toMap();
      categoryData.remove('id');
      final response = await supabase
          .from('categories')
          .insert(categoryData)
          .select();
      if (response.isEmpty) {
        throw CategoryException.categoryCreationFailure(
          'Failed to create category',
        );
      }
    } catch (e) {
      throw CategoryException.categoryCreationFailure(e);
    }
  }

  @override
  Future<void> updateCategory(CategoryDTO dto) async {
    try {
      final response = await supabase
          .from('categories')
          .update(dto.toMap())
          .eq('id', dto.id)
          .eq('user_id', dto.userId)
          .select();

      if (response.isEmpty) {
        throw CategoryException.categoryNotFound(dto.id, dto.userId);
      }
    } catch (e) {
      throw CategoryException.categoryUpdateFailure(e);
    }
  }

  @override
  Future<void> deleteCategory(String id, String userId) async {
    try {
      final response = await supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('user_id', userId)
          .select();

      if (response.isEmpty) {
        throw CategoryException.categoryNotFound(id, userId);
      }
    } catch (e) {
      throw CategoryException.categoryDeletionFailure(e);
    }
  }
}
