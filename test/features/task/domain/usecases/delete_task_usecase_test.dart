import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/usecases/delete_task_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  late MockTaskRepository repository;
  late DeleteTaskUsecase usecase;

  const taskId = 'task123';
  const userId = 'userABC';

  setUpAll(() {
    registerFallbackValue(FakeTaskException());
  });

  setUp(() {
    repository = MockTaskRepository();
    usecase = DeleteTaskUsecase(repository);
  });

  group('DeleteTaskUsecase', () {
    test('returns right(Unit) when deletion succeeds', () async {
      when(
        () => repository.deleteTask(taskId, userId),
      ).thenAnswer((_) async => right(unit));

      final result = await usecase(taskId, userId);

      expect(result.isRight(), true);
      verify(() => repository.deleteTask(taskId, userId)).called(1);
    });

    test('returns left TaskException when deletion fails', () async {
      final exception = TaskException.taskDeletionFailed('why');
      when(
        () => repository.deleteTask(taskId, userId),
      ).thenAnswer((_) async => left(exception));

      final result = await usecase(taskId, userId);

      expect(result.isLeft(), true);
      expect(result.swap().getOrElse(() => throw ''), exception);
      verify(() => repository.deleteTask(taskId, userId)).called(1);
    });
  });
}
