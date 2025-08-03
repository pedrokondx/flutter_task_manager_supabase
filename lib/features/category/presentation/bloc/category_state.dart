part of 'category_cubit.dart';

class CategoryState extends Equatable {
  final List<CategoryEntity> categories;
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final String? lastSuccessMessage;

  const CategoryState({
    this.categories = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.lastSuccessMessage,
  });

  CategoryState copyWith({
    List<CategoryEntity>? categories,
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    String? lastSuccessMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isDeleting: isDeleting ?? this.isDeleting,
      errorMessage: errorMessage,
      lastSuccessMessage: lastSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
    categories,
    isLoading,
    isSaving,
    isDeleting,
    errorMessage,
    lastSuccessMessage,
  ];
}
