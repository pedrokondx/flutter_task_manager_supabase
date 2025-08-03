import 'package:dartz/dartz.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/core/domain/repositories/category_preview_repository.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';

class UpdateCategoryUsecase {
  final CategoryRepository repository;
  final CategoryPreviewRepository previewRepository;

  UpdateCategoryUsecase(this.repository, this.previewRepository);

  Future<Either<CategoryException, Unit>> call(CategoryEntity category) async {
    try {
      // check duplicate
      final getResult = await previewRepository.getCategories(category.userId);
      if (getResult.isLeft()) {
        return Left(
          CategoryException.getCategoriesFailure(
            'Failed to retrieve categories',
          ),
        );
      }
      final existing = getResult.getOrElse(() => []);

      final hasConflict = existing.any(
        (entity) =>
            entity.name.toLowerCase() == category.name.toLowerCase() &&
            entity.id != category.id,
      );
      if (hasConflict) {
        return Left(CategoryException.categoryAlreadyExists(category.name));
      }

      return repository.updateCategory(category);
    } catch (e) {
      if (e is CategoryException) return Left(e);

      return Left(CategoryException.categoryUpdateFailure(e));
    }
  }
}
