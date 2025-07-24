import 'package:supabase_todo/features/todo/domain/repositories/task_repository.dart';

class DeleteTaskUsecase {
  final TaskRepository repository;
  DeleteTaskUsecase(this.repository);

  Future<void> call(String taskId) {
    return repository.deleteTask(taskId);
  }
}
