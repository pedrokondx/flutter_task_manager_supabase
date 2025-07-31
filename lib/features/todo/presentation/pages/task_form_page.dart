import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/title_validator.dart';
import 'package:supabase_todo/features/todo/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/attachment_bloc.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/attachment_events.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/attachment_state.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_bloc.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_events.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_state.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/attachment_add_modal.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/attachment_preview.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/due_date_picker.dart';
import 'package:supabase_todo/shared/widgets/async_button.dart';

class TaskFormPage extends StatefulWidget {
  final String userId;
  final TaskEntity? task;

  const TaskFormPage({super.key, required this.userId, this.task});

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  String _status = 'to_do';
  String _category = '';
  bool _categoryInitialized = false;
  DateTime? _dueDate;

  final List<XFile> _pendingFiles = [];
  final ImagePicker _picker = ImagePicker();

  bool get isLoading => context.watch<TaskBloc>().state is TaskLoading;
  bool get isAttachmentLoading =>
      context.watch<AttachmentBloc>().state is AttachmentOperationLoading;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _status = widget.task?.status ?? 'to_do';
    _dueDate = widget.task?.dueDate;

    if (widget.task != null) {
      context.read<AttachmentBloc>().add(LoadAttachmentsEvent(widget.task!.id));
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
      id: widget.task?.id ?? '',
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
      context.read<TaskBloc>().add(CreateTaskEvent(newTask));
    } else {
      context.read<TaskBloc>().add(UpdateTaskEvent(newTask));
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
    setState(() => _pendingFiles.clear());
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskError) {
          SnackbarUtils.showError(context, state.message);
        } else if (state is TaskOverviewLoaded) {
          final action = widget.task == null ? 'created' : 'updated';
          SnackbarUtils.showSuccess(context, 'Task $action successfully!');
          context.pop();
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (state is TaskOverviewLoaded) {
          final categories = state.categories;
          if (!_categoryInitialized) {
            final exists = categories.any(
              (c) => c.id == widget.task?.categoryId,
            );
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
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: TitleValidator.validate,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        labelText: 'Description (optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      enabled: !isLoading,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: _status,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'to_do', child: Text('To Do')),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text('In Progress'),
                        ),
                        DropdownMenuItem(value: 'done', child: Text('Done')),
                      ],
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _status = v!),
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String?>(
                      value: _category.isEmpty ? null : _category,
                      decoration: const InputDecoration(
                        labelText: 'Category (optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('No category'),
                        ),
                        ...categories.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
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

                    BlocBuilder<AttachmentBloc, AttachmentState>(
                      builder: (context, attachState) {
                        List<AttachmentEntity> existing = [];
                        if (attachState is AttachmentsLoaded) {
                          existing = attachState.attachments;
                        }
                        return AttachmentPreview(
                          attachments: existing,
                          pendingFiles: _pendingFiles,
                          onAddAttachment: _addAttachment,
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
                          onViewAttachment: (att) =>
                              context.push('/attachment-viewer', extra: att),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    if (isAttachmentLoading) ...[
                      const Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Uploading attachments...'),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],

                    AsyncButton(
                      label: widget.task == null
                          ? 'Create Task'
                          : 'Update Task',
                      isLoading: isLoading || isAttachmentLoading,
                      onPressed: _saveTask,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
