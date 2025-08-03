import 'package:supabase_todo/core/domain/exceptions/app_exception.dart';

class AttachmentException extends AppException {
  const AttachmentException({required super.message, super.code, super.inner});

  factory AttachmentException.fileTooLarge() => const AttachmentException(
    message: 'File size exceeds 50MB limit',
    code: 'FILE_TOO_LARGE',
  );

  factory AttachmentException.invalidExtension(String ext, String type) =>
      AttachmentException(
        message: 'File extension $ext not allowed for type $type',
        code: 'INVALID_EXTENSION',
      );

  factory AttachmentException.fileEmpty() =>
      const AttachmentException(message: 'File is empty', code: 'FILE_EMPTY');

  factory AttachmentException.unsupportedType(String type) =>
      AttachmentException(
        message: 'Unsupported file type: $type',
        code: 'UNSUPPORTED_TYPE',
      );

  factory AttachmentException.notFound() => const AttachmentException(
    message: 'Attachment not found',
    code: 'NOT_FOUND',
  );

  factory AttachmentException.attachmentFetchFailure(Object inner) =>
      AttachmentException(
        message: 'Failed to fetch attachments.',
        code: 'FETCH_FAILURE',
        inner: inner,
      );

  factory AttachmentException.attachmentCreationFailure(Object inner) =>
      AttachmentException(
        message: 'Failed to create attachment.',
        code: 'CREATION_FAILURE',
        inner: inner,
      );

  factory AttachmentException.attachmentDeletionFailure(Object inner) =>
      AttachmentException(
        message: 'Failed to delete attachment.',
        code: 'DELETION_FAILURE',
        inner: inner,
      );
}
