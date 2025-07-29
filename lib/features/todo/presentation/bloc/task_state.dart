import 'package:equatable/equatable.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskOverviewLoaded extends TaskState {
  final List<TaskEntity> tasks;
  final List<CategoryEntity> categories;
  TaskOverviewLoaded(this.tasks, this.categories);

  @override
  List<Object?> get props => [tasks, categories];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
