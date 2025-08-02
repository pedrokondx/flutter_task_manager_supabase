import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/task/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/task/data/dtos/task_dto.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';

class TaskSupabaseDatasource implements TaskDatasource {
  final SupabaseClient supabase;

  TaskSupabaseDatasource(this.supabase);

  @override
  Future<List<TaskDTO>> getTasks(String userId) async {
    try {
      final data = await supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return data.map((map) => TaskDTO.fromMap(map)).toList();
    } catch (e) {
      throw TaskException.taskRetrievalFailed(e);
    }
  }

  @override
  Future<void> createTask(TaskDTO dto) async {
    try {
      final taskData = dto.toMap();
      taskData.remove('id');
      await supabase.from('tasks').insert(taskData);
    } catch (e) {
      throw TaskException.taskCreationFailed(e);
    }
  }

  @override
  Future<void> updateTask(TaskDTO dto) async {
    try {
      final response = await supabase
          .from('tasks')
          .update(dto.toMap())
          .eq('id', dto.id)
          .eq('user_id', dto.userId)
          .select();

      if (response.isEmpty) {
        throw TaskException.taskNotFound(dto.id);
      }
    } catch (e) {
      throw TaskException.taskUpdateFailed(e);
    }
  }

  @override
  Future<void> deleteTask(String id, String userId) async {
    try {
      final response = await supabase
          .from('tasks')
          .delete()
          .eq('id', id)
          .eq('user_id', userId)
          .select();

      if (response.isEmpty) {
        throw TaskException.taskNotFound(id);
      }
    } catch (e) {
      throw TaskException.taskDeletionFailed(e);
    }
  }
}
