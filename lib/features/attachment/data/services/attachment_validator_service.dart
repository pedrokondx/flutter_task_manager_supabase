import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/services/file_validation_service.dart';

class AttachmentValidationService implements FileValidationService {
  static int maxFileSizeBytes = 50 * 1024 * 1024; // 50MB
  static Map<String, List<String>> allowedExtensions = {
    'image': ['.jpg', '.jpeg', '.png', '.gif', '.webp'],
    'video': ['.mp4', '.mov', '.avi', '.mkv', '.webm'],
  };

  @override
  Future<void> validateFile({
    required String filePath,
    required String type,
    required String fileName,
  }) async {
    // Validate file size
    final file = File(filePath);
    final fileSize = await file.length();

    if (fileSize > maxFileSizeBytes) {
      throw AttachmentException.fileTooLarge();
    }

    if (fileSize == 0) {
      throw AttachmentException.fileEmpty();
    }

    // Validate file type
    if (!allowedExtensions.containsKey(type)) {
      throw AttachmentException.unsupportedType(type);
    }

    // Validate file extension
    final extension = path.extension(fileName).toLowerCase();
    final validExtensions = allowedExtensions[type]!;

    if (!validExtensions.contains(extension)) {
      throw AttachmentException.invalidExtension(extension, type);
    }

    // Validate file exists and is readable
    if (!await file.exists()) {
      throw AttachmentException.notFound();
    }
  }
}
