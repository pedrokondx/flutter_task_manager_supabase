import 'package:supabase_todo/core/domain/exceptions/app_exception.dart';

class TaskException extends AppException {
  const TaskException({required super.message, super.code, super.inner});

  factory TaskException.taskCreationFailed(Object inner) => TaskException(
    message: 'Task creation failed',
    code: 'TASK_CREATION_FAILED',
    inner: inner,
  );

  factory TaskException.taskUpdateFailed(Object inner) => TaskException(
    message: 'Task update failed',
    code: 'TASK_UPDATE_FAILED',
    inner: inner,
  );

  factory TaskException.taskDeletionFailed(Object inner) => TaskException(
    message: 'Task deletion failed',
    code: 'TASK_DELETION_FAILED',
    inner: inner,
  );

  factory TaskException.taskRetrievalFailed(Object inner) => TaskException(
    message: 'Task retrieval failed',
    code: 'TASK_RETRIEVAL_FAILED',
    inner: inner,
  );

  factory TaskException.taskNotFound(String taskId) => TaskException(
    message: 'Task with ID $taskId not found',
    code: 'TASK_NOT_FOUND',
  );

  factory TaskException.taskAlreadyExists(String taskName) => TaskException(
    message: 'Task with name $taskName already exists',
    code: 'TASK_ALREADY_EXISTS',
  );
}
