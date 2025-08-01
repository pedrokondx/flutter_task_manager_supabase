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
  group('AttachmentBloc', () {
    late MockAttachmentRepository mockRepository;
    late MockFileValidationService mockValidationService;
    late CreateAttachmentUsecase createUsecase;
    late GetAttachmentsUsecase getUsecase;
    late DeleteAttachmentUsecase deleteUsecase;
    late AttachmentBloc bloc;

    // Test data constants
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
        'should emit [AttachmentsLoading, AttachmentsLoaded] when loading attachments succeeds',
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
        'should emit [AttachmentsLoading, AttachmentError] when loading attachments fails',
        setUp: () {
          when(() => mockRepository.getAttachments(taskId)).thenAnswer(
            (_) async => Left(
              AttachmentException.datasourceError('Database connection failed'),
            ),
          );
        },
        build: () => bloc,
        act: (bloc) => bloc.add(LoadAttachmentsEvent(taskId)),
        expect: () => [
          AttachmentsLoading(),
          AttachmentError('Failed to load data from server.'),
        ],
      );
    });

    group('CreateAttachmentEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'should emit correct sequence when creating attachment succeeds and reloads',
        setUp: () {
          // Mock successful validation
          when(
            () => mockValidationService.validateFile(
              filePath: any(named: 'filePath'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async {});

          // Mock successful creation
          when(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: any(named: 'file'),
              type: any(named: 'type'),
              fileName: any(named: 'fileName'),
            ),
          ).thenAnswer((_) async => Right(sampleAttachment));

          // Mock successful reload
          when(
            () => mockRepository.getAttachments(taskId),
          ).thenAnswer((_) async => Right(attachmentsList));
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
          AttachmentOperationLoading(),
          AttachmentOperationSuccess('Attachment added successfully'),
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, attachmentsList),
        ],
        verify: (bloc) {
          // Verify validation was called
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);

          // Verify repository methods were called with correct parameters
          verify(
            () => mockRepository.createAttachment(
              userId: userId,
              taskId: taskId,
              file: testFile,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);

          verify(() => mockRepository.getAttachments(taskId)).called(1);
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'should emit [AttachmentOperationLoading, AttachmentError] when creating attachment fails',
        setUp: () {
          // Mock successful validation
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
            (_) async =>
                Left(AttachmentException.uploadFailed('Network timeout')),
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
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('Failed to upload file. Please try again.'),
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

          // Verify that getAttachments was NOT called on failure
          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );
    });

    group('DeleteAttachmentEvent', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'should emit correct sequence when deleting attachment succeeds and reloads',
        setUp: () {
          // Mock successful deletion
          when(
            () => mockRepository.deleteAttachment(attachmentId),
          ).thenAnswer((_) async => const Right(null));

          // Mock successful reload (empty list after deletion)
          when(
            () => mockRepository.getAttachments(taskId),
          ).thenAnswer((_) async => const Right([]));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentOperationSuccess('Attachment deleted successfully'),
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, const []),
        ],
        verify: (bloc) {
          verify(() => mockRepository.deleteAttachment(attachmentId)).called(1);
          verify(() => mockRepository.getAttachments(taskId)).called(1);
        },
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'should emit [AttachmentOperationLoading, AttachmentError] when deleting attachment fails',
        setUp: () {
          when(() => mockRepository.deleteAttachment(attachmentId)).thenAnswer(
            (_) async => Left(AttachmentException.storageDeletionFailed("")),
          );
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('Failed to delete file from storage.'),
        ],
        verify: (bloc) {
          verify(() => mockRepository.deleteAttachment(attachmentId)).called(1);

          // Verify that getAttachments was NOT called on failure
          verifyNever(() => mockRepository.getAttachments(any()));
        },
      );
    });

    group('Edge Cases and Validation', () {
      blocTest<AttachmentBloc, AttachmentState>(
        'should handle empty attachments list correctly',
        setUp: () {
          when(
            () => mockRepository.getAttachments(taskId),
          ).thenAnswer((_) async => const Right([]));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(LoadAttachmentsEvent(taskId)),
        expect: () => [
          AttachmentsLoading(),
          AttachmentsLoaded(taskId, const []),
        ],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'should handle multiple rapid events correctly',
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

      blocTest<AttachmentBloc, AttachmentState>(
        'should handle file too large validation error',
        setUp: () {
          // Mock validation service to throw file too large exception
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
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('File size exceeds 50MB limit'),
        ],
        verify: (bloc) {
          verify(
            () => mockValidationService.validateFile(
              filePath: testFile.path,
              type: fileType,
              fileName: fileName,
            ),
          ).called(1);

          // Verify repository was NOT called due to validation failure
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
        'should handle invalid file extension error',
        setUp: () {
          // Mock validation service to throw invalid extension exception
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
            fileName: 'malware.exe', // This will trigger the validation error
          ),
        ),
        expect: () => [
          AttachmentOperationLoading(),
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

          // Verify repository was NOT called due to validation failure
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
        'should handle empty file validation error',
        setUp: () {
          // Mock validation service to throw empty file exception
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
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('File is empty'),
        ],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'should handle unsupported file type validation error',
        setUp: () {
          // Mock validation service to throw unsupported type exception
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
            type: 'audio', // Unsupported type
            fileName: 'song.mp3',
          ),
        ),
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('Unsupported file type: audio'),
        ],
      );

      blocTest<AttachmentBloc, AttachmentState>(
        'should handle attachment not found error during deletion',
        setUp: () {
          when(
            () => mockRepository.deleteAttachment(attachmentId),
          ).thenAnswer((_) async => Left(AttachmentException.notFound()));
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
          DeleteAttachmentEvent(attachmentId: attachmentId, taskId: taskId),
        ),
        expect: () => [
          AttachmentOperationLoading(),
          AttachmentError('Attachment not found'),
        ],
      );
    });

    tearDown(() {
      bloc.close();
    });
  });
}
