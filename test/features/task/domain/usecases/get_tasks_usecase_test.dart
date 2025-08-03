import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/usecases/get_tasks_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

TaskEntity makeTask({
  required String id,
  required String userId,
  String title = 'Fetch Task',
}) {
  final now = DateTime.now();
  return TaskEntity(
    id: id,
    userId: userId,
    title: title,
    description: null,
    dueDate: null,
    categoryId: null,
    status: TaskStatus.fromString('done'),
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  late MockTaskRepository repository;
  late GetTasksUsecase usecase;

  const userId = 'user42';

  setUpAll(() {
    registerFallbackValue(FakeTaskEntity());
    registerFallbackValue(FakeTaskException());
  });

  setUp(() {
    repository = MockTaskRepository();
    usecase = GetTasksUsecase(repository);
  });

  group('GetTasksUsecase', () {
    final tasks = [
      makeTask(id: 't1', userId: userId),
      makeTask(id: 't2', userId: userId),
    ];

    test('returns list when repository succeeds', () async {
      when(
        () => repository.getTasks(userId),
      ).thenAnswer((_) async => right(tasks));

      final result = await usecase(userId);

      expect(result.isRight(), true);
      expect(result.getOrElse(() => []), tasks);
      verify(() => repository.getTasks(userId)).called(1);
    });

    test('returns exception when repository fails', () async {
      final exception = TaskException.taskRetrievalFailed('nope');
      when(
        () => repository.getTasks(userId),
      ).thenAnswer((_) async => left(exception));

      final result = await usecase(userId);

      expect(result.isLeft(), true);
      expect(result.swap().getOrElse(() => throw ''), exception);
      verify(() => repository.getTasks(userId)).called(1);
    });
  });
}
