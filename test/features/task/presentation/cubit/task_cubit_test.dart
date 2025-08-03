import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/task/data/dtos/task_dto.dart';

import 'package:supabase_todo/features/task/presentation/cubit/task_cubit.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/core/domain/exceptions/category_exception.dart';
import 'package:supabase_todo/features/task/domain/usecases/create_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/update_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/get_tasks_usecase.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';

import '../../../../core/mocks.dart';
import '../../../../core/fakes.dart';
import '../../mocks.dart';
import '../../fakes.dart';

TaskEntity makeTask({
  String id = 't1',
  String userId = 'user1',
  String title = 'Task Title',
}) {
  final now = DateTime.now();
  return TaskEntity(
    id: id,
    userId: userId,
    title: title,
    description: 'desc',
    dueDate: now.add(const Duration(days: 1)),
    categoryId: 'cat1',
    status: TaskStatus.fromString('to_do'),
    createdAt: now,
    updatedAt: now,
  );
}

CategoryEntity makeCategory({String id = 'cat1', String name = 'General'}) {
  final now = DateTime.now();
  return CategoryEntity(
    id: id,
    name: name,
    userId: '',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late GetTasksUsecase getTasks;
  late GetCategoriesUsecase getCategories;
  late CreateTaskUsecase createTask;
  late UpdateTaskUsecase updateTask;
  late DeleteTaskUsecase deleteTask;
  late MockTaskRepository mockTaskRepository;
  late MockCategoryPreviewRepository mockCategoryPreviewRepository;
  late TaskCubit cubit;

  const userId = 'user1';
  final task = makeTask();
  final category = makeCategory();

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeCategoryEntity());
    registerFallbackValue(FakeTaskException());
    registerFallbackValue(FakeCategoryException());
  });

  setUp(() {
    mockTaskRepository = MockTaskRepository();
    mockCategoryPreviewRepository = MockCategoryPreviewRepository();
    getTasks = GetTasksUsecase(mockTaskRepository);
    getCategories = GetCategoriesUsecase(mockCategoryPreviewRepository);
    createTask = CreateTaskUsecase(mockTaskRepository);
    updateTask = UpdateTaskUsecase(mockTaskRepository);
    deleteTask = DeleteTaskUsecase(mockTaskRepository);

    cubit = TaskCubit(
      getTasks: getTasks,
      getCategories: getCategories,
      createTask: createTask,
      updateTask: updateTask,
      deleteTask: deleteTask,
    );
  });

  group('load', () {
    blocTest<TaskCubit, TaskState>(
      'emits loading then populated on success',
      build: () {
        when(
          () => mockTaskRepository.getTasks(userId),
        ).thenAnswer((_) async => right([task]));
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right([category]));
        return cubit;
      },
      act: (c) => c.load(userId),
      expect: () => [
        const TaskState(isLoading: true),
        TaskState(isLoading: false, tasks: [task], categories: [category]),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(userId)).called(1);
        verify(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).called(1);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'emits error when getTasks fails',
      build: () {
        when(() => mockTaskRepository.getTasks(userId)).thenAnswer(
          (_) async => left(TaskException.taskRetrievalFailed('fail')),
        );
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer((_) async => right([category]));
        return cubit;
      },
      act: (c) => c.load(userId),
      expect: () => [
        const TaskState(isLoading: true),
        TaskState(isLoading: false, errorMessage: 'Task retrieval failed'),
      ],
    );

    blocTest<TaskCubit, TaskState>(
      'emits error when getCategories fails',
      build: () {
        when(
          () => mockTaskRepository.getTasks(userId),
        ).thenAnswer((_) async => right([task]));
        when(
          () => mockCategoryPreviewRepository.getCategories(userId),
        ).thenAnswer(
          (_) async => left(CategoryException.getCategoriesFailure('err')),
        );
        return cubit;
      },
      act: (c) => c.load(userId),
      expect: () => [
        const TaskState(isLoading: true),
        TaskState(isLoading: false, errorMessage: 'Failed to get categories'),
      ],
    );
  });

  group('create', () {
    blocTest<TaskCubit, TaskState>(
      'adds task and shows success message on success',
      build: () {
        when(
          () => mockTaskRepository.getTasks(task.userId),
        ).thenAnswer((_) async => right(<TaskEntity>[]));
        when(
          () => mockTaskRepository.createTask(task),
        ).thenAnswer((_) async => right(unit));
        return cubit;
      },
      seed: () => const TaskState(),
      act: (c) => c.create(task),
      expect: () => [
        TaskState(isSaving: true),
        TaskState(
          tasks: [task],
          isSaving: false,
          lastSuccessMessage: 'Task criada',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(task.userId)).called(1);
        verify(() => mockTaskRepository.createTask(task)).called(1);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'shows error on generic creation failure',
      build: () {
        when(
          () => mockTaskRepository.getTasks(task.userId),
        ).thenAnswer((_) async => right(<TaskEntity>[]));
        when(() => mockTaskRepository.createTask(task)).thenAnswer(
          (_) async => left(TaskException.taskCreationFailed('bad')),
        );
        return cubit;
      },
      seed: () => const TaskState(),
      act: (c) => c.create(task),
      expect: () => [
        TaskState(isSaving: true),
        TaskState(
          tasks: [],
          isSaving: false,
          errorMessage: 'Task creation failed',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(task.userId)).called(1);
        verify(() => mockTaskRepository.createTask(task)).called(1);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'shows error when duplicate title (TASK_ALREADY_EXISTS)',
      build: () {
        final existing = makeTask(id: 'other', title: task.title);
        when(
          () => mockTaskRepository.getTasks(task.userId),
        ).thenAnswer((_) async => right([existing]));
        return cubit;
      },
      seed: () => const TaskState(),
      act: (c) => c.create(task),
      expect: () => [
        TaskState(isSaving: true),
        TaskState(
          tasks: [],
          isSaving: false,
          errorMessage: 'Task with name ${task.title} already exists',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(task.userId)).called(1);
        verifyNever(() => mockTaskRepository.createTask(task));
      },
    );
  });

  group('update', () {
    final updated = TaskDTO.fromEntity(
      task,
    ).copyWith(title: 'Changed Title').toEntity();

    blocTest<TaskCubit, TaskState>(
      'updates task and shows success message',
      build: () {
        when(
          () => mockTaskRepository.getTasks(updated.userId),
        ).thenAnswer((_) async => right(<TaskEntity>[]));
        when(
          () => mockTaskRepository.updateTask(updated),
        ).thenAnswer((_) async => right(unit));
        return cubit;
      },
      seed: () => TaskState(tasks: [task]),
      act: (c) => c.update(updated),
      expect: () => [
        TaskState(tasks: [task], isSaving: true),
        TaskState(
          tasks: [updated],
          isSaving: false,
          lastSuccessMessage: 'Task atualizada',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(updated.userId)).called(1);
        verify(() => mockTaskRepository.updateTask(updated)).called(1);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'shows error on generic update failure',
      build: () {
        when(
          () => mockTaskRepository.getTasks(updated.userId),
        ).thenAnswer((_) async => right(<TaskEntity>[]));
        when(
          () => mockTaskRepository.updateTask(updated),
        ).thenAnswer((_) async => left(TaskException.taskUpdateFailed('fail')));
        return cubit;
      },
      seed: () => TaskState(tasks: [task]),
      act: (c) => c.update(updated),
      expect: () => [
        TaskState(tasks: [task], isSaving: true),
        TaskState(
          tasks: [task],
          isSaving: false,
          errorMessage: 'Task update failed',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(updated.userId)).called(1);
        verify(() => mockTaskRepository.updateTask(updated)).called(1);
      },
    );

    blocTest<TaskCubit, TaskState>(
      'shows error when duplicate title (TASK_ALREADY_EXISTS) on update',
      build: () {
        final existing = makeTask(id: 'other', title: updated.title);
        when(
          () => mockTaskRepository.getTasks(updated.userId),
        ).thenAnswer((_) async => right([existing]));
        return cubit;
      },
      seed: () => TaskState(tasks: [task]),
      act: (c) => c.update(updated),
      expect: () => [
        TaskState(tasks: [task], isSaving: true),
        TaskState(
          tasks: [task],
          isSaving: false,
          errorMessage: 'Task with name ${updated.title} already exists',
        ),
      ],
      verify: (_) {
        verify(() => mockTaskRepository.getTasks(updated.userId)).called(1);
        verifyNever(() => mockTaskRepository.updateTask(updated));
      },
    );
  });

  group('delete', () {
    blocTest<TaskCubit, TaskState>(
      'removes and shows success',
      build: () {
        when(
          () => deleteTask(task.id, userId),
        ).thenAnswer((_) async => right(unit));
        return cubit;
      },
      seed: () => TaskState(tasks: [task]),
      act: (c) => c.delete(task.id, userId),
      expect: () => [
        TaskState(tasks: [task], isDeleting: true),
        TaskState(
          tasks: [],
          isDeleting: false,
          lastSuccessMessage: 'Task deletada',
        ),
      ],
    );

    blocTest<TaskCubit, TaskState>(
      'shows error when deletion fails',
      build: () {
        when(() => deleteTask(task.id, userId)).thenAnswer(
          (_) async => left(TaskException.taskDeletionFailed('oops')),
        );
        return cubit;
      },
      seed: () => TaskState(tasks: [task]),
      act: (c) => c.delete(task.id, userId),
      expect: () => [
        TaskState(tasks: [task], isDeleting: true),
        TaskState(
          tasks: [task],
          isDeleting: false,
          errorMessage: 'Task deletion failed',
        ),
      ],
    );
  });

  group('upsertLocal', () {
    final existing = makeTask(id: 't2');
    final newTask = makeTask(id: 't3');

    test('adds new task to front without calling usecase', () {
      final initial = TaskState(tasks: [existing]);
      cubit.emit(initial);
      cubit.upsertLocal(newTask);
      expect(cubit.state.tasks.first, newTask);
      expect(cubit.state.tasks.length, 2);
    });

    test('replaces existing with same id', () {
      final modified = makeTask(id: 't2', title: 'changed');
      final initial = TaskState(tasks: [existing]);
      cubit.emit(initial);
      cubit.upsertLocal(modified);
      expect(cubit.state.tasks.first.title, 'changed');
      expect(cubit.state.tasks.length, 1);
    });
  });
}
