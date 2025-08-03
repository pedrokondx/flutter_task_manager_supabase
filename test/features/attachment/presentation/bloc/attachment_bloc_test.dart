import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/create_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/delete_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/get_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_bloc.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_events.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_state.dart';

import '../../fakes.dart';
import '../../mocks.dart';

void main() {
  group('AttachmentBloc (new behavior)', () {
    late MockAttachmentRepository mockRepository;
    late MockFileValidationService mockValidationService;
    late CreateAttachmentUsecase createUsecase;
    late GetAttachmentsUsecase getUsecase;
    late DeleteAttachmentUsecase deleteUsecase;
    late AttachmentBloc bloc;

    const taskId = 'task1';
    const userId = 'user1';
    const attachmentId = 'a1';
    const fileName = 'test-file.jpg';
    const fileType = 'image';

    final testFile = File('test-path');
    final sampleAttachment = AttachmentEntity(
      id: attachmentId,
      taskId: taskId,
      fileUrl: 'https://example.com/file.jpg',
      type: fileType,
      fileName: fileName,
      createdAt: DateTime.now(),
    );
    final attachmentsList = [sampleAttachment];

    setUpAll(() {
      registerFallbackValue(FakeFile());
    });

    setUp(() {
      mockRepository = MockAttachmentRepository();
      mockValidationService = MockFileValidationService();

      getUsecase = GetAttachmentsUsecase(mockRepository);
      createUsecase = CreateAttachmentUsecase(
        mockRepository,
        mockValidationService,
      );
      deleteUsecase = DeleteAttachmentUsecase(mockRepository);

      bloc = AttachmentBloc(
        getAttachments: getUsecase,
        createAttachment: createUsecase,
        deleteAttachment: deleteUsecase,
      );
    });

    group('LoadAttachmentsEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'emits [AttachmentsLoading, AttachmentsLoaded] when loading succeeds',
        setUp: () {
          when(
            () => mockRepository.getAttachments(taskId),
          ).thenAnswer((_) async => Right(attachmentsList));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(LoadAttachmentsEvent(taskId)),
        expect: () => [
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, attachmentsList),
        ],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits [AttachmentsLoading, AttachmentError] when loading fails',
        setUp: () {
          when(() => mockRepository.getAttachments(taskId)).thenAnswer(
            (_) async => Left(
              AttachmentException.attachmentFetchFailure(
                'Failed to fetch attachments',
              ),
            ),
          );
        },
        build: () => bloc,
        act: (bloc) => bloc.add(LoadAttachmentsEvent(taskId)),
        expect: () => [
          AttachmentsLoading(),
          AttachmentError('Failed to fetch attachments.'),
        ],
      );
    });

    group('CreateAttachmentEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'appends new attachment when creation succeeds from empty state',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async {});

          when(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async => Right(sampleAttachment));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: fileName,
          ),
        ),
        expect: () => [
          AttachmentOperationSuccess('Attachment added successfully'),
          AttachmentsLoaded(taskId, [sampleAttachment]),
        ],
        verify: (bloc) {
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);
          verify(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: testFile,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);

          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'appends new attachment when creation succeeds from existing loaded state',
        seed: () => AttachmentsLoaded(taskId, attachmentsList),
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async {});

          final another = AttachmentEntity(
            id: 'a2',
            taskId: taskId,
            fileUrl: 'https://example.com/file2.jpg',
            type: fileType,
            fileName: 'other.jpg',
            createdAt: DateTime.now(),
          );

          when(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async => Right(another));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: fileName,
          ),
        ),
        expect: () => [
          AttachmentOperationSuccess('Attachment added successfully'),
          isA<AttachmentsLoaded>().having(
            (s) => s.attachments.map((a) => a.id).toList(),
            'attachment ids',
            ['a1', 'a2'],
          ),
        ],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits [AttachmentError] when creation fails after successful validation',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async {});

          when(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer(
            (_) async => Left(
              AttachmentException.attachmentCreationFailure(
                'Failed to create attachment.',
              ),
            ),
          );
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: fileName,
          ),
        ),
        expect: () => [AttachmentError('Failed to create attachment.')],
        verify: (bloc) {
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);
          verify(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: testFile,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);
          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when validation fails (file too large)',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenThrow(AttachmentException.fileTooLarge());
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: fileName,
          ),
        ),
        expect: () => [AttachmentError('File size exceeds 50MB limit')],
        verify: (bloc) {
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);
          verifyNever(
            () => mockRepository.createAttachment(
              userId: any(named: 'userId'),
              taskId: any(named: 'taskId'),
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          );
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when validation fails (invalid extension)',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenThrow(AttachmentException.invalidExtension('.exe', 'image'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: 'malware.exe',
          ),
        ),
        expect: () => [
          AttachmentError('File extension .exe not allowed for type image'),
        ],
        verify: (bloc) {
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: 'malware.exe',
            ),
          ).called(1);
          verifyNever(
            () => mockRepository.createAttachment(
              userId: any(named: 'userId'),
              taskId: any(named: 'taskId'),
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          );
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when validation fails (empty file)',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenThrow(AttachmentException.fileEmpty());
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: fileType,
            fileName: fileName,
          ),
        ),
        expect: () => [AttachmentError('File is empty')],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when validation fails (unsupported type)',
        setUp: () {
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenThrow(AttachmentException.unsupportedType('audio'));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          CreateAttachmentEvent(
            userId: userId,
            taskId: taskId,
            file: testFile,
            type: 'audio',
            fileName: 'song.mp3',
          ),
        ),
        expect: () => [AttachmentError('Unsupported file type: audio')],
      );
    });

    group('DeleteAttachmentEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'removes attachment when deletion succeeds from loaded state',
        seed: () => AttachmentsLoaded(taskId, attachmentsList),
        setUp: () {
          when(
            () => mockRepository.deleteAttachment(attachmentId),
          ).thenAnswer((_) async => const Right(null));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [
          AttachmentOperationSuccess('Attachment deleted successfully'),
          AttachmentsLoaded(taskId, const []),
        ],
        verify: (bloc) {
          verify(() => mockRepository.deleteAttachment(attachmentId)).called(1);
          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when deletion fails',
        seed: () => AttachmentsLoaded(taskId, attachmentsList),
        setUp: () {
          when(() => mockRepository.deleteAttachment(attachmentId)).thenAnswer(
            (_) async =>
                Left(AttachmentException.attachmentDeletionFailure("fail")),
          );
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [AttachmentError('Failed to delete attachment.')],
        verify: (bloc) {
          verify(() => mockRepository.deleteAttachment(attachmentId)).called(1);
          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'emits error when attachment not found during deletion',
        seed: () => AttachmentsLoaded(taskId, attachmentsList),
        setUp: () {
          when(
            () => mockRepository.deleteAttachment(attachmentId),
          ).thenAnswer((_) async => Left(AttachmentException.notFound()));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [AttachmentError('Attachment not found')],
      );
    });

    group('ClearAttachmentsEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'clears attachments regardless of previous state',
        seed: () => AttachmentsLoaded(taskId, attachmentsList),
        build: () => bloc,
        act: (bloc) => bloc.add(ClearAttachmentsEvent()),
        expect: () => [AttachmentsLoaded("", [])],
      );
    });

    group('Edge Cases', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'handles multiple rapid LoadAttachmentsEvent correctly',
        setUp: () {
          when(
            () => mockRepository.getAttachments(taskId),
          ).thenAnswer((_) async => Right(attachmentsList));
        },
        build: () => bloc,
        act: (bloc) {
          bloc.add(LoadAttachmentsEvent(taskId));
          bloc.add(LoadAttachmentsEvent(taskId));
        },
        expect: () => [
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, attachmentsList),
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, attachmentsList),
        ],
      );
    });

    tearDown(() {
      bloc.close();
    });
  });
}
