import 'package:supabase_todo/features/task/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/task/data/dtos/task_dto.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource datasource;

  TaskRepositoryImpl(this.datasource);

  @override
  Future<List<TaskEntity>> getTasks(String userId) async {
    final dtos = await datasource.getTasks(userId);
    return dtos.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> createTask(TaskEntity task) {
    final dto = TaskDTO.fromEntity(task);
    return datasource.createTask(dto);
  }

  @override
  Future<void> updateTask(TaskEntity task) {
    final dto = TaskDTO.fromEntity(task);
    return datasource.updateTask(dto);
  }

  @override
  Future<void> deleteTask(String taskId, String userId) {
    return datasource.deleteTask(taskId, userId);
  }
}
