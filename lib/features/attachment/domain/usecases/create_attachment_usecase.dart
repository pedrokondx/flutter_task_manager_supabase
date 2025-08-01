import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/services/file_validation_service.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class CreateAttachmentUsecase {
  final AttachmentRepository repository;
  final FileValidationService validationService;

  CreateAttachmentUsecase(this.repository, this.validationService);

  Future<Either<AttachmentException, AttachmentEntity>> call({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  }) async {
    try {
      await validationService.validateFile(
        filePath: file.path,
        type: type,
        fileName: fileName,
      );
    } on AttachmentException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AttachmentException(
          message: 'Validation failed',
          code: 'VALIDATION_FAILED',
          inner: e,
        ),
      );
    }

    return repository.createAttachment(
      userId: userId,
      taskId: taskId,
      file: file,
      type: type,
      fileName: fileName,
    );
  }
}
