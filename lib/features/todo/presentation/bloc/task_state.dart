import 'package:equatable/equatable.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';

abstract class TaskState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TaskInitial extends TaskState {}

class TaskLoading extends TaskState {}

class TaskLoaded extends TaskState {
  final List<TaskEntity> tasks;
  TaskLoaded(this.tasks);

  @override
  List<Object?> get props => [tasks];
}

class TaskError extends TaskState {
  final String message;
  TaskError(this.message);

  @override
  List<Object?> get props => [message];
}
