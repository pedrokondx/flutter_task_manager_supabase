import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/domain/repositories/task_repository.dart';

class GetTasksUsecase {
  final TaskRepository repository;
  GetTasksUsecase(this.repository);

  Future<List<TaskEntity>> call(String userId) {
    return repository.getTasks(userId);
  }
}
