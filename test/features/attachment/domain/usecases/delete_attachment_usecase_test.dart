import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/delete_attachment_usecase.dart';

import '../../mocks.dart';

void main() {
  late MockAttachmentRepository repository;
  late DeleteAttachmentUsecase usecase;

  setUp(() {
    repository = MockAttachmentRepository();
    usecase = DeleteAttachmentUsecase(repository);
  });

  final attachmentId = 'att-1';

  test('should succeed when repository returns Right', () async {
    when(
      () => repository.deleteAttachment(attachmentId),
    ).thenAnswer((_) async => const Right(null));

    final result = await usecase.call(attachmentId: attachmentId);

    expect(result.isRight(), true);
  });

  test('should return Left when repository fails', () async {
    when(() => repository.deleteAttachment(attachmentId)).thenAnswer(
      (_) async => Left(AttachmentException.attachmentDeletionFailure('x')),
    );

    final result = await usecase.call(attachmentId: attachmentId);

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.code, 'DELETION_FAILURE'),
      (_) => fail('Esperava falha'),
    );
  });
}
