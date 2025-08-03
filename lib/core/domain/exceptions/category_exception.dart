import 'package:supabase_todo/core/domain/exceptions/app_exception.dart';

class CategoryException extends AppException {
  const CategoryException({required super.message, super.code, super.inner});

  factory CategoryException.categoryCreationFailure(Object inner) =>
      CategoryException(
        message: 'Failed to create category',
        code: 'CATEGORY_CREATION_FAILED',
        inner: inner,
      );
  factory CategoryException.categoryUpdateFailure(Object inner) =>
      CategoryException(
        message: 'Failed to update category',
        code: 'CATEGORY_UPDATE_FAILED',
        inner: inner,
      );
  factory CategoryException.categoryDeletionFailure(Object inner) =>
      CategoryException(
        message: 'Failed to delete category',
        code: 'CATEGORY_DELETION_FAILED',
        inner: inner,
      );
  factory CategoryException.getCategoriesFailure(Object inner) =>
      CategoryException(
        message: 'Failed to get categories',
        code: 'GET_CATEGORIES_FAILED',
        inner: inner,
      );

  factory CategoryException.categoryNotFound(String id, String userId) =>
      CategoryException(
        message: 'No category found with ID $id for user $userId',
        code: 'CATEGORY_NOT_FOUND',
      );

  factory CategoryException.categoryAlreadyExists(String name) =>
      CategoryException(
        message: 'Category with name "$name" already exists',
        code: 'CATEGORY_ALREADY_EXISTS',
      );
}
