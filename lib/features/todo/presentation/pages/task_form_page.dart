import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/title_validator.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_bloc.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_events.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_state.dart';
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
  bool get isLoading => context.watch<TaskBloc>().state is TaskLoading;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descController = TextEditingController(
      text: widget.task?.description ?? '',
    );
    _status = widget.task?.status ?? 'to_do';
    _dueDate = widget.task?.dueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
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
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _dueDate = picked);
    }
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
        if (state is TaskOverviewLoaded) {
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
                          : (value) {
                              if (value != null) {
                                setState(() => _status = value);
                              }
                            },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String?>(
                      value: _category.isEmpty ? null : _category,
                      decoration: const InputDecoration(
                        labelText: 'Categoria (opcional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Sem categoria'),
                        ),
                        ...categories.map(
                          (category) => DropdownMenuItem(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: isLoading
                          ? null
                          : (value) {
                              setState(() => _category = value ?? '');
                            },
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _dueDate == null
                                  ? 'No due date selected'
                                  : 'Due: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading ? null : _pickDueDate,
                            child: const Text('Pick Date'),
                          ),
                          if (_dueDate != null)
                            IconButton(
                              onPressed: isLoading
                                  ? null
                                  : () => setState(() => _dueDate = null),
                              icon: const Icon(Icons.clear),
                              tooltip: 'Clear date',
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    AsyncButton(
                      label: widget.task == null
                          ? 'Create Task'
                          : 'Update Task',
                      isLoading: isLoading,
                      onPressed: _saveTask,
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
