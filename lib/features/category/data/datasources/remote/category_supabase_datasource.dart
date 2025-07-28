import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/category/data/datasources/category_datasource.dart';
import 'package:supabase_todo/features/category/data/dtos/category_dto.dart';

class CategorySupabaseDatasource implements CategoryDatasource {
  final SupabaseClient supabase;

  CategorySupabaseDatasource(this.supabase);

  @override
  Future<List<CategoryDTO>> getCategories(String userId) async {
    final data = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return data.map((map) => CategoryDTO.fromMap(map)).toList();
  }

  @override
  Future<void> createCategory(CategoryDTO dto) async {
    final categoryData = dto.toMap();
    categoryData.remove('id');

    await supabase.from('categories').insert(categoryData).select();
  }

  @override
  Future<void> updateCategory(CategoryDTO dto) async {
    final response = await supabase
        .from('categories')
        .update(dto.toMap())
        .eq('id', dto.id)
        .eq('user_id', dto.userId)
        .select();

    if (response.isEmpty) {
      throw Exception(
        'No category found with ID ${dto.id} for user ${dto.userId}',
      );
    }
  }

  @override
  Future<void> deleteCategory(String id, String userId) async {
    final response = await supabase
        .from('categories')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select();

    if (response.isEmpty) {
      throw Exception('No category found with ID $id for user $userId');
    }
  }
}
