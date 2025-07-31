import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class DeleteTaskUsecase {
  final TaskRepository repository;
  DeleteTaskUsecase(this.repository);

  Future<void> call(String taskId, String userId) {
    return repository.deleteTask(taskId, userId);
  }
}
