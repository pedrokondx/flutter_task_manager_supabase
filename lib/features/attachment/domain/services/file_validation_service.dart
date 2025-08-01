abstract class FileValidationService {
  Future<void> validateFile({
    required String filePath,
    required String type,
    required String fileName,
  });
}
