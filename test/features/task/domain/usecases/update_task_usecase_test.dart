import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/usecases/update_task_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

TaskEntity makeTask({
  String id = 'task1',
  String userId = 'user1',
  String title = 'Updated Task',
}) {
  final now = DateTime.now();
  return TaskEntity(
    id: id,
    userId: userId,
    title: title,
    description: 'desc',
    dueDate: now.add(const Duration(days: 2)),
    categoryId: 'cat2',
    status: TaskStatus.fromString('in_progress'),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTaskRepository repository;
  late UpdateTaskUsecase usecase;
  late TaskEntity task;

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeTaskException());
  });

  setUp(() {
    repository = MockTaskRepository();
    usecase = UpdateTaskUsecase(repository);
    task = makeTask();
  });

  group('UpdateTaskUsecase', () {
    test('returns right(Unit) when update succeeds', () async {
      when(
        () => repository.getTasks(task.userId),
      ).thenAnswer((_) async => right(<TaskEntity>[]));
      when(
        () => repository.updateTask(task),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(task);

      expect(result.isRight(), true);
      verify(() => repository.getTasks(task.userId)).called(1);
      verify(() => repository.updateTask(task)).called(1);
    });

    test('returns left TaskException when update fails', () async {
      when(
        () => repository.getTasks(task.userId),
      ).thenAnswer((_) async => right(<TaskEntity>[]));
      final exception = TaskException.taskUpdateFailed('err');
      when(
        () => repository.updateTask(task),
      ).thenAnswer((_) async => left(exception));

      final result = await usecase(task);

      expect(result.isLeft(), true);
      expect(result.swap().getOrElse(() => throw ''), exception);
      verify(() => repository.getTasks(task.userId)).called(1);
      verify(() => repository.updateTask(task)).called(1);
    });

    test(
      'returns left TaskAlreadyExists when a different task has same title',
      () async {
        final existingTask = makeTask(id: 'other', title: task.title);

        when(
          () => repository.getTasks(task.userId),
        ).thenAnswer((_) async => right([existingTask]));

        final result = await usecase(task);

        expect(result.isLeft(), true);
        final leftException = result.swap().getOrElse(() => throw '');
        expect(leftException.code, 'TASK_ALREADY_EXISTS');
        expect(leftException.message, contains(task.title));
        verify(() => repository.getTasks(task.userId)).called(1);
        verifyNever(() => repository.updateTask(task));
      },
    );
  });
}
