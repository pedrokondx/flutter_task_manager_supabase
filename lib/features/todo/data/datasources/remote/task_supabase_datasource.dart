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
    await supabase.from('tasks').insert(dto.toMap());
  }

  @override
  Future<void> updateTask(TaskDTO dto) async {
    await supabase.from('tasks').update(dto.toMap()).eq('id', dto.id);
  }

  @override
  Future<void> deleteTask(String id) async {
    await supabase.from('tasks').delete().eq('id', id);
  }
}
