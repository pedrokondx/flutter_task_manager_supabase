import 'package:supabase_todo/core/data/dtos/category_dto.dart';

abstract class CategoryPreviewDatasource {
  Future<List<CategoryDTO>> getCategories(String userId);
}
