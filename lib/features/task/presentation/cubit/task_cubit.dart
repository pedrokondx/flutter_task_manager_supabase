import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';

import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/task/domain/usecases/get_tasks_usecase.dart';

import 'package:supabase_todo/features/task/domain/usecases/create_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/update_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';

part 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final GetTasksUsecase getTasks;
  final GetCategoriesUsecase getCategories;
  final CreateTaskUsecase createTask;
  final UpdateTaskUsecase updateTask;
  final DeleteTaskUsecase deleteTask;

  TaskCubit({
    required this.getTasks,
    required this.getCategories,
    required this.createTask,
    required this.updateTask,
    required this.deleteTask,
  }) : super(const TaskState());

  Future<void> load(String userId) async {
    emit(
      state.copyWith(
        isLoading: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
    final results = await Future.wait([
      getTasks(userId),
      getCategories(userId),
    ]);

    final taskResult = results[0] as Either<TaskException, List<TaskEntity>>;
    final categoriesResult =
        results[1] as Either<CategoryException, List<CategoryEntity>>;

    if (taskResult.isLeft()) {
      final msg = taskResult
          .swap()
          .getOrElse(() => TaskException.taskRetrievalFailed(''))
          .message;
      emit(state.copyWith(isLoading: false, errorMessage: msg));
      return;
    }

    if (categoriesResult.isLeft()) {
      final msg = categoriesResult
          .swap()
          .getOrElse(() => CategoryException.getCategoriesFailure(''))
          .message;
      emit(state.copyWith(isLoading: false, errorMessage: msg));
      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        tasks: taskResult.getOrElse(() => []),
        categories: categoriesResult.getOrElse(() => []),
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );
  }

  Future<void> create(TaskEntity task) async {
    emit(
      state.copyWith(
        isSaving: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );

    final result = await createTask(task);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.message,
            lastSuccessMessage: null,
          ),
        );
      },
      (_) {
        final updatedTasks = [task, ...state.tasks];
        emit(
          state.copyWith(
            tasks: updatedTasks,
            isSaving: false,
            errorMessage: null,
            lastSuccessMessage: 'Task criada',
          ),
        );
      },
    );
  }

  Future<void> update(TaskEntity task) async {
    emit(
      state.copyWith(
        isSaving: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );

    final result = await updateTask(task);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isSaving: false,
            errorMessage: failure.message,
            lastSuccessMessage: null,
          ),
        );
      },
      (_) {
        final updatedTasks = [
          task,
          ...state.tasks.where((t) => t.id != task.id),
        ];
        emit(
          state.copyWith(
            tasks: updatedTasks,
            isSaving: false,
            errorMessage: null,
            lastSuccessMessage: 'Task atualizada',
          ),
        );
      },
    );
  }

  Future<void> delete(String taskId, String userId) async {
    emit(
      state.copyWith(
        isDeleting: true,
        errorMessage: null,
        lastSuccessMessage: null,
      ),
    );

    final result = await deleteTask(taskId, userId);
    result.fold(
      (failure) {
        emit(
          state.copyWith(
            isDeleting: false,
            errorMessage: failure.message,
            lastSuccessMessage: null,
          ),
        );
      },
      (_) {
        final filtered = state.tasks.where((t) => t.id != taskId).toList();
        emit(
          state.copyWith(
            tasks: filtered,
            isDeleting: false,
            errorMessage: null,
            lastSuccessMessage: 'Task deletada',
          ),
        );
      },
    );
  }

  void upsertLocal(TaskEntity task) {
    final updated = [task, ...state.tasks.where((t) => t.id != task.id)];
    emit(state.copyWith(tasks: updated));
  }
}
