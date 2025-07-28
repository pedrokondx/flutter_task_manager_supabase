import 'package:equatable/equatable.dart';
import 'package:supabase_todo/features/category/domain/entities/category_entity.dart';

abstract class CategoryEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadCategories extends CategoryEvent {
  final String userId;
  LoadCategories(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  CreateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final CategoryEntity category;
  UpdateCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String categoryId;
  final String userId;
  DeleteCategoryEvent(this.categoryId, this.userId);

  @override
  List<Object?> get props => [categoryId, userId];
}
