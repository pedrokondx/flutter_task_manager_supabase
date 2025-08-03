import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/task/presentation/cubit/task_cubit.dart';
import 'package:supabase_todo/features/task/presentation/widgets/due_date_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/title_validator.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_bloc.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_events.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_state.dart';
import 'package:supabase_todo/features/attachment/presentation/widgets/attachment_add_modal.dart';
import 'package:supabase_todo/features/attachment/presentation/widgets/attachment_header.dart';
import 'package:supabase_todo/features/attachment/presentation/widgets/attachment_preview.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/core/ui/widgets/async_button.dart';

class TaskFormPage extends StatefulWidget {
  final String userId;
  final TaskEntity? task;

  const TaskFormPage({super.key, required this.userId, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  TaskStatus _status = TaskStatus.toDo;
  String _category = '';
  bool _categoryInitialized = false;
  DateTime? _dueDate;

  final List<XFile> _pendingFiles = [];
  List<AttachmentEntity> _lastAttachments = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _status = widget.task?.status ?? TaskStatus.toDo;
    _dueDate = widget.task?.dueDate;

    if (widget.task != null) {
      context.read<AttachmentBloc>().add(LoadAttachmentsEvent(widget.task!.id));
    } else {
      context.read<AttachmentBloc>().add(ClearAttachmentsEvent());
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final newTask = TaskEntity(
      id: widget.task?.id ?? _uuid.v4(),
      userId: widget.userId,
      title: _titleController.text.trim(),
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      dueDate: _dueDate,
      categoryId: _category.isEmpty ? null : _category,
      status: _status,
      createdAt: widget.task?.createdAt ?? now,
      updatedAt: now,
    );

    if (widget.task == null) {
      context.read<TaskCubit>().create(newTask);
    } else {
      context.read<TaskCubit>().update(newTask);
    }

    for (final file in _pendingFiles) {
      final fileName = file.name;
      final type =
          fileName.toLowerCase().contains(RegExp(r'\.(jpg|jpeg|png|gif)$'))
          ? 'image'
          : 'video';

      context.read<AttachmentBloc>().add(
        CreateAttachmentEvent(
          userId: widget.userId,
          taskId: newTask.id,
          file: File(file.path),
          type: type,
          fileName: fileName,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskCubit, TaskState>(
      listenWhen: (previous, current) {
        if (previous.errorMessage != current.errorMessage) return true;
        if (previous.lastSuccessMessage != current.lastSuccessMessage) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state.errorMessage != null) {
          SnackbarUtils.showError(context, state.errorMessage!);
        } else if (state.lastSuccessMessage != null) {
          SnackbarUtils.showSuccess(context, state.lastSuccessMessage!);
          final returned = widget.task == null
              ? state.tasks.first
              : state.tasks.firstWhere(
                  (t) => t.id == widget.task!.id,
                  orElse: () => state.tasks.first,
                );
          context.pop(returned);
        }
      },
      buildWhen: (previous, current) {
        if (previous.tasks == current.tasks &&
            previous.categories == current.categories &&
            previous.isSaving == current.isSaving &&
            previous.isDeleting == current.isDeleting &&
            previous.errorMessage == current.errorMessage) {
          return false;
        }
        return true;
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
        final isSaving = state.isSaving;

        if (state.isLoading && state.tasks.isEmpty) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state.errorMessage != null && state.tasks.isEmpty) {
          return Scaffold(
            body: Center(child: Text('Erro: ${state.errorMessage}')),
          );
        }

        final categories = state.categories;
        if (!_categoryInitialized) {
          final exists = categories.any((c) => c.id == widget.task?.categoryId);
          _category = exists ? widget.task!.categoryId! : '';
          _categoryInitialized = true;
        }

        return Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        widget.task == null ? 'New Task' : 'Edit Task',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: TitleValidator.validate,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(
                      labelText: 'Description (optional)',
                    ),
                    maxLines: 3,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _status.value,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: TaskStatus.toMap()
                        .map(
                          (key, value) => MapEntry(
                            key,
                            DropdownMenuItem(value: key, child: Text(value)),
                          ),
                        )
                        .values
                        .toList(),

                    onChanged: isLoading
                        ? null
                        : (v) => setState(
                            () => _status = TaskStatus.fromString(v!),
                          ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String?>(
                    value: _category.isEmpty ? null : _category,
                    decoration: const InputDecoration(
                      labelText: 'Category (optional)',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('No category'),
                      ),
                      ...categories.map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      ),
                    ],
                    onChanged: isLoading
                        ? null
                        : (v) => setState(() => _category = v ?? ''),
                  ),
                  const SizedBox(height: 16),
                  DueDatePicker(
                    dueDate: _dueDate,
                    isLoading: isLoading,
                    onDateSelected: (date) => setState(() => _dueDate = date),
                    onClear: () => setState(() => _dueDate = null),
                  ),
                  const SizedBox(height: 24),
                  BlocConsumer<AttachmentBloc, AttachmentState>(
                    listener: (context, state) {
                      if (state is AttachmentOperationSuccess) {
                        SnackbarUtils.showSuccess(context, state.message);
                      } else if (state is AttachmentError) {
                        SnackbarUtils.showError(context, state.message);
                      }
                    },
                    builder: (context, attachState) {
                      if (attachState is AttachmentsLoaded) {
                        _lastAttachments = attachState.attachments;
                      }

                      final isLoaded = attachState is AttachmentsLoaded;
                      final isLoadingAttachments =
                          attachState is AttachmentsLoading;

                      final attachmentsToShow = isLoaded
                          ? attachState.attachments
                          : _lastAttachments;

                      return Column(
                        children: [
                          AttachmentHeader(
                            onAddAttachment: isLoaded ? _addAttachment : () {},
                          ),
                          const SizedBox(height: 8),
                          if (attachmentsToShow.isEmpty && isLoadingAttachments)
                            const Row(
                              children: [
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Loading attachments...'),
                              ],
                            )
                          else
                            AttachmentPreview(
                              attachments: attachmentsToShow,
                              pendingFiles: _pendingFiles,
                              onDeletePendingFile: (file) =>
                                  setState(() => _pendingFiles.remove(file)),
                              onDeleteAttachment: (att) =>
                                  DialogUtils.showDeleteDialog(
                                    context,
                                    'Delete Attachment',
                                    'Are you sure?',
                                    () {
                                      context.read<AttachmentBloc>().add(
                                        DeleteAttachmentEvent(
                                          taskId: widget.task?.id ?? '',
                                          attachmentId: att.id,
                                        ),
                                      );
                                    },
                                  ),
                              onViewAttachment: (att) => context.push(
                                '/attachment-viewer',
                                extra: att,
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),
                  AsyncButton(
                    label: widget.task == null ? 'Create Task' : 'Update Task',
                    isLoading: isSaving,
                    onPressed: _saveTask,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _addAttachment() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentAddModal(
        onTakePhoto: () async {
          context.pop();
          final photo = await _picker.pickImage(source: ImageSource.camera);
          if (photo != null) setState(() => _pendingFiles.add(photo));
        },
        onChooseFromGallery: () async {
          context.pop();
          final images = await _picker.pickMultipleMedia();
          if (images.isNotEmpty) setState(() => _pendingFiles.addAll(images));
        },
        onRecordVideo: () async {
          context.pop();
          final video = await _picker.pickVideo(source: ImageSource.camera);
          if (video != null) setState(() => _pendingFiles.add(video));
        },
      ),
    );
  }
}
