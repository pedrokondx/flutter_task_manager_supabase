import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';

abstract class TaskRepository {
  Future<List<TaskEntity>> getTasks(String userId);
  Future<void> createTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId, String userId);
}
