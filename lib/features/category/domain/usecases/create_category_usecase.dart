import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class CreateCategoryUsecase {
  final CategoryRepository repository;
  CreateCategoryUsecase(this.repository);

  Future<void> call(CategoryEntity category) {
    return repository.createCategory(category);
  }
}
