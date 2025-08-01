import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/create_attachment_usecase.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  late MockAttachmentRepository repository;
  late MockFileValidationService validationService;
  late CreateAttachmentUsecase usecase;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    repository = MockAttachmentRepository();
    validationService = MockFileValidationService();
    usecase = CreateAttachmentUsecase(repository, validationService);
  });

  final userId = 'user1';
  final taskId = 'task1';
  final file = File('some/path.jpg');
  const type = 'image';
  const fileName = 'photo.jpg';
  final now = DateTime.now();
  final expectedEntity = AttachmentEntity(
    id: 'att1',
    taskId: taskId,
    fileUrl: 'https://example.com/image.jpg',
    type: type,
    fileName: fileName,
    createdAt: now,
  );

  test('should return Left when validation fails', () async {
    when(
      () => validationService.validateFile(
        filePath: any(named: 'filePath'),
        type: any(named: 'type'),
        fileName: any(named: 'fileName'),
      ),
    ).thenThrow(AttachmentException.fileTooLarge());

    final result = await usecase.call(
      userId: userId,
      taskId: taskId,
      file: file,
      type: type,
      fileName: fileName,
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, 'FILE_TOO_LARGE'),
      (_) => fail('Esperava falha na validação'),
    );

    verifyNever(
      () => repository.createAttachment(
        userId: any(named: 'userId'),
        taskId: any(named: 'taskId'),
        file: any(named: 'file'),
        type: any(named: 'type'),
        fileName: any(named: 'fileName'),
      ),
    );
  });

  test(
    'should return Right when validation passes and repository succeeds',
    () async {
      when(
        () => validationService.validateFile(
          filePath: any(named: 'filePath'),
          type: any(named: 'type'),
          fileName: any(named: 'fileName'),
        ),
      ).thenAnswer((_) async {});
      when(
        () => repository.createAttachment(
          userId: userId,
          taskId: taskId,
          file: file,
          type: type,
          fileName: fileName,
        ),
      ).thenAnswer((_) async => Right(expectedEntity));

      final result = await usecase.call(
        userId: userId,
        taskId: taskId,
        file: file,
        type: type,
        fileName: fileName,
      );

      expect(result.isRight(), true);
      result.fold((_) => fail('Esperava sucesso'), (entity) {
        expect(entity.id, expectedEntity.id);
        expect(entity.fileUrl, expectedEntity.fileUrl);
      });

      verify(
        () => validationService.validateFile(
          filePath: file.path,
          type: type,
          fileName: fileName,
        ),
      ).called(1);
      verify(
        () => repository.createAttachment(
          userId: userId,
          taskId: taskId,
          file: file,
          type: type,
          fileName: fileName,
        ),
      ).called(1);
    },
  );
}
