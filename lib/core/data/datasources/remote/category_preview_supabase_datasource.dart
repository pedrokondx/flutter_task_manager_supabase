import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/data/datasources/category_preview_datasource.dart';
import 'package:supabase_todo/core/data/dtos/category_dto.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';

class CategoryPreviewSupabaseDatasource implements CategoryPreviewDatasource {
  final SupabaseClient supabase;

  CategoryPreviewSupabaseDatasource(this.supabase);

  @override
  Future<List<CategoryDTO>> getCategories(String userId) async {
    try {
      final data = await supabase
          .from('categories')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return data.map((map) => CategoryDTO.fromMap(map)).toList();
    } catch (e) {
      throw CategoryException.getCategoriesFailure(e);
    }
  }
}
