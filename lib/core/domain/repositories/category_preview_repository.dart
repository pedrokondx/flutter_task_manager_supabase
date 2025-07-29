import 'package:supabase_todo/core/domain/entities/category_entity.dart';

abstract class CategoryPreviewRepository {
  Future<List<CategoryEntity>> getCategories(String userId);
}
