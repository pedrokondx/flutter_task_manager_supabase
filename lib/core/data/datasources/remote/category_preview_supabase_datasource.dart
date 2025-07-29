import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/data/datasources/category_preview_datasource.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';

class CategoryPreviewSupabaseDatasource implements CategoryPreviewDatasource {
  final SupabaseClient supabase;

  CategoryPreviewSupabaseDatasource(this.supabase);

  @override
  Future<List<CategoryDTO>> getCategories(String userId) async {
    final data = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return data.map((map) => CategoryDTO.fromMap(map)).toList();
  }
}
