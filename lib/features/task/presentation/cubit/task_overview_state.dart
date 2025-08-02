part of 'task_overview_cubit.dart';

class TaskOverviewState extends Equatable {
  final List<TaskEntity> tasks;
  final List<CategoryEntity> categories;
  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
  final String? errorMessage;
  final String? lastSuccessMessage;

  const TaskOverviewState({
    this.tasks = const [],
    this.categories = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.lastSuccessMessage,
  });

  TaskOverviewState copyWith({
    List<TaskEntity>? tasks,
    List<CategoryEntity>? categories,
    bool? isLoading,
    bool? isSaving,
    bool? isDeleting,
    String? errorMessage,
    String? lastSuccessMessage,
  }) {
    return TaskOverviewState(
      tasks: tasks ?? this.tasks,
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
    tasks,
    categories,
    isLoading,
    isSaving,
    isDeleting,
    errorMessage,
    lastSuccessMessage,
  ];
}
