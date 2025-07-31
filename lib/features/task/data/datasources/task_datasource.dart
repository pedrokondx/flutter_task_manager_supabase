import 'package:supabase_todo/features/task/data/dtos/task_dto.dart';

abstract class TaskDatasource {
  Future<List<TaskDTO>> getTasks(String userId);
  Future<void> createTask(TaskDTO task);
  Future<void> updateTask(TaskDTO task);
  Future<void> deleteTask(String taskId, String userId);
}
