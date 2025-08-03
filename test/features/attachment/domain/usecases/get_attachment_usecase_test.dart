import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/get_attachment_usecase.dart';

import '../../mocks.dart';

void main() {
  late MockAttachmentRepository repository;
  late GetAttachmentsUsecase usecase;

  setUp(() {
    repository = MockAttachmentRepository();
    usecase = GetAttachmentsUsecase(repository);
  });

  final taskId = 'task123';
  final attachments = [
    AttachmentEntity(
      id: 'a1',
      taskId: taskId,
      fileUrl: 'url1',
      type: 'image',
      fileName: 'f1.jpg',
      createdAt: DateTime.now(),
    ),
  ];

  test('should return list when successful', () async {
    when(
      () => repository.getAttachments(taskId),
    ).thenAnswer((_) async => Right(attachments));

    final result = await usecase.call(taskId);

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Esperava sucesso'),
      (list) => expect(list, attachments),
    );
  });

  test('should return Left when repository fails', () async {
    when(() => repository.getAttachments(taskId)).thenAnswer(
      (_) async => Left(AttachmentException.attachmentFetchFailure('erro')),
    );

    final result = await usecase.call(taskId);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, 'FETCH_FAILURE'),
      (_) => fail('Esperava falha'),
    );
  });
}
