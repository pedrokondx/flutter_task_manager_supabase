import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/domain/repositories/task_repository.dart';

class UpdateTaskUsecase {
  final TaskRepository repository;
  UpdateTaskUsecase(this.repository);

  Future<void> call(TaskEntity task) {
    return repository.updateTask(task);
  }
}
