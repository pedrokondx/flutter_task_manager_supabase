import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
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
  final GetCategoriesUsecase getCategories;

  TaskBloc({
    required this.getTasks,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
    required this.getCategories,
  }) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<CreateTaskEvent>(_onCreateTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final categories = await getCategories(event.userId);
      final tasks = await getTasks(event.userId);
      emit(TaskOverviewLoaded(tasks, categories));
    } catch (e) {
      String errorMessage = 'Failed to load tasks';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to load tasks: ${e.toString()}';
      }
      emit(TaskError(errorMessage));
    }
  }

  Future<void> _onCreateTask(
    CreateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await createTask(event.task);
      add(LoadTasks(event.task.userId));
    } catch (e) {
      String errorMessage = 'Failed to create task';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to create task: ${e.toString()}';
      }
      emit(TaskError(errorMessage));
    }
  }

  Future<void> _onUpdateTask(
    UpdateTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await updateTask(event.task);
      add(LoadTasks(event.task.userId));
    } catch (e) {
      String errorMessage = 'Failed to update task';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to update task: ${e.toString()}';
      }

      emit(TaskError(errorMessage));
    }
  }

  Future<void> _onDeleteTask(
    DeleteTaskEvent event,
    Emitter<TaskState> emit,
  ) async {
    try {
      await deleteTask(event.taskId, event.userId);
      add(LoadTasks(event.userId));
    } catch (e) {
      String errorMessage = 'Failed to delete task';
      if (e is PostgrestException) {
        errorMessage = 'Database error: ${e.message}';
      } else if (e is Exception) {
        errorMessage = 'Failed to delete task: ${e.toString()}';
      }

      emit(TaskError(errorMessage));
    }
  }
}
