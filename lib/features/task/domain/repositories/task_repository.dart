import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';

abstract class TaskRepository {
  Future<Either<TaskException, List<TaskEntity>>> getTasks(String userId);
  Future<Either<TaskException, Unit>> createTask(TaskEntity task);
  Future<Either<TaskException, Unit>> updateTask(TaskEntity task);
  Future<Either<TaskException, Unit>> deleteTask(String taskId, String userId);
}
