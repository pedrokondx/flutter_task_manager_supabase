import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class CreateTaskUsecase {
  final TaskRepository repository;
  CreateTaskUsecase(this.repository);

  Future<Either<TaskException, Unit>> call(TaskEntity task) {
    return repository.createTask(task);
  }
}
