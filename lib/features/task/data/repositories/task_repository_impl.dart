import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/task/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/task/data/dtos/task_dto.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/exceptions/task_exception.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskDatasource datasource;

  TaskRepositoryImpl(this.datasource);

  @override
  Future<Either<TaskException, List<TaskEntity>>> getTasks(
    String userId,
  ) async {
    try {
      final dtos = await datasource.getTasks(userId);
      return Right(dtos.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(TaskException.taskRetrievalFailed(e));
    }
  }

  @override
  Future<Either<TaskException, Unit>> createTask(TaskEntity task) async {
    try {
      final dto = TaskDTO.fromEntity(task);

      await datasource.createTask(dto);

      return Right(unit);
    } catch (e) {
      return Left(TaskException.taskCreationFailed(e));
    }
  }

  @override
  Future<Either<TaskException, Unit>> updateTask(TaskEntity task) async {
    try {
      final dto = TaskDTO.fromEntity(task);
      await datasource.updateTask(dto);
      return Right(unit);
    } catch (e) {
      return Left(TaskException.taskUpdateFailed(e));
    }
  }

  @override
  Future<Either<TaskException, Unit>> deleteTask(
    String taskId,
    String userId,
  ) async {
    try {
      await datasource.deleteTask(taskId, userId);
      return Right(unit);
    } catch (e) {
      return Left(TaskException.taskDeletionFailed(e));
    }
  }
}
