import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/todo/domain/usecases/create_task_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/delete_task_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/get_tasks_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/update_task_usecase.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_events.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksUsecase getTasks;
  final CreateTaskUsecase createTask;
  final UpdateTaskUsecase updateTask;
  final DeleteTaskUsecase deleteTask;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(TaskInitial()) {
    on<LoadTasks>((event, emit) async {
      emit(TaskLoading());
      try {
        final tasks = await getTasks(event.userId);
        emit(TaskLoaded(tasks));
      } catch (_) {
        emit(TaskError('Failed to load tasks'));
      }
    });

    on<CreateTaskEvent>((event, emit) async {
      await createTask(event.task);
      add(LoadTasks(event.task.userId));
    });

    on<UpdateTaskEvent>((event, emit) async {
      await updateTask(event.task);
      add(LoadTasks(event.task.userId));
    });

    on<DeleteTaskEvent>((event, emit) async {
      await deleteTask(event.taskId);
      // make reload
    });
  }
}
