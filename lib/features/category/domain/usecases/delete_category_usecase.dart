import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class DeleteCategoryUsecase {
  final CategoryRepository repository;
  DeleteCategoryUsecase(this.repository);

  Future<void> call(String categoryId, String userId) {
    return repository.deleteCategory(categoryId, userId);
  }
}
