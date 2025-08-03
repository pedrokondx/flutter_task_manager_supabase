import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/usecases/create_task_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

TaskEntity makeTask({
  String id = 'task1',
  String userId = 'user1',
  String title = 'Test Task',
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

void main() {
  late MockTaskRepository repository;
  late CreateTaskUsecase usecase;
  late TaskEntity task;

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeTaskException());
  });

  setUp(() {
    repository = MockTaskRepository();
    usecase = CreateTaskUsecase(repository);
    task = makeTask();
  });

  group('CreateTaskUsecase', () {
    test('returns right(Unit) when repository succeeds', () async {
      when(
        () => repository.createTask(task),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(task);

      expect(result.isRight(), true);
      verify(() => repository.createTask(task)).called(1);
    });

    test('returns left TaskException when repository fails', () async {
      final exception = TaskException.taskCreationFailed('inner');
      when(
        () => repository.createTask(task),
      ).thenAnswer((_) async => left(exception));

      final result = await usecase(task);

      expect(result.isLeft(), true);
      expect(result.swap().getOrElse(() => throw ''), exception);
      verify(() => repository.createTask(task)).called(1);
    });
  });
}
