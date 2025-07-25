import 'package:equatable/equatable.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';

abstract class TaskEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTasks extends TaskEvent {
  final String userId;
  LoadTasks(this.userId);

  @override
  List<Object?> get props => [userId];
}

class CreateTaskEvent extends TaskEvent {
  final TaskEntity task;
  CreateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class UpdateTaskEvent extends TaskEvent {
  final TaskEntity task;
  UpdateTaskEvent(this.task);

  @override
  List<Object?> get props => [task];
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;
  final String userId;
  DeleteTaskEvent(this.taskId, this.userId);

  @override
  List<Object?> get props => [taskId, userId];
}
