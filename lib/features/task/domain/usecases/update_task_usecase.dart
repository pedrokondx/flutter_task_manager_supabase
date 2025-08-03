import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class UpdateTaskUsecase {
  final TaskRepository repository;
  UpdateTaskUsecase(this.repository);

  Future<Either<TaskException, Unit>> call(TaskEntity task) async {
    try {
      // check duplicate
      final getResult = await repository.getTasks(task.userId);
      if (getResult.isLeft()) {
        return Left(
          TaskException.taskRetrievalFailed('Failed to retrieve tasks'),
        );
      }
      final existing = getResult.getOrElse(() => []);

      final hasConflict = existing.any(
        (entity) =>
            entity.title.toLowerCase() == task.title.toLowerCase() &&
            entity.id != task.id,
      );
      if (hasConflict) {
        return Left(TaskException.taskAlreadyExists(task.title));
      }

      await repository.updateTask(task);
      return Right(unit);
    } catch (e) {
      if (e is TaskException) return Left(e);

      return Left(TaskException.taskCreationFailed(e));
    }
  }
}
