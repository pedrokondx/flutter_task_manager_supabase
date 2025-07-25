import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/todo/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/todo/data/dtos/task_dto.dart';

class TaskSupabaseDatasource implements TaskDatasource {
  final SupabaseClient supabase;

  TaskSupabaseDatasource(this.supabase);

  @override
  Future<List<TaskDTO>> getTasks(String userId) async {
    final data = await supabase
        .from('tasks')
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return data.map((map) => TaskDTO.fromMap(map)).toList();
  }

  @override
  Future<void> createTask(TaskDTO dto) async {
    final taskData = dto.toMap();
    taskData.remove('id');

    await supabase.from('tasks').insert(taskData);
  }

  @override
  Future<void> updateTask(TaskDTO dto) async {
    final response = await supabase
        .from('tasks')
        .update(dto.toMap())
        .eq('id', dto.id)
        .eq('user_id', dto.userId)
        .select();

    if (response.isEmpty) {
      throw Exception('No task found with ID ${dto.id} for user ${dto.userId}');
    }
  }

  @override
  Future<void> deleteTask(String id, String userId) async {
    final response = await supabase
        .from('tasks')
        .delete()
        .eq('id', id)
        .eq('user_id', userId)
        .select();

    if (response.isEmpty) {
      throw Exception('No task found with ID $id for user $userId');
    }
  }
}
