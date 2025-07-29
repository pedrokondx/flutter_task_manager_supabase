import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class UpdateCategoryUsecase {
  final CategoryRepository repository;
  UpdateCategoryUsecase(this.repository);

  Future<void> call(CategoryEntity category) {
    return repository.updateCategory(category);
  }
}
