import 'package:supabase_todo/features/category/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class GetCategoriesUsecase {
  final CategoryRepository repository;
  GetCategoriesUsecase(this.repository);

  Future<List<CategoryEntity>> call(String userId) {
    return repository.getCategories(userId);
  }
}
