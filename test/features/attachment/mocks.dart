import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';
import 'package:supabase_todo/features/attachment/domain/services/file_validation_service.dart';

class MockAttachmentRepository extends Mock implements AttachmentRepository {}

class MockFileValidationService extends Mock implements FileValidationService {}
