import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class DeleteTaskUsecase {
  final TaskRepository repository;
  DeleteTaskUsecase(this.repository);

  Future<Either<TaskException, Unit>> call(String taskId, String userId) {
    return repository.deleteTask(taskId, userId);
  }
}
