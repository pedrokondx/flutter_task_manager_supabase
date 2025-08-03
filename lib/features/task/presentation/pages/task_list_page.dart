import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/utils/debouncer.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_events.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';
import 'package:supabase_todo/features/task/presentation/cubit/task_cubit.dart';
import 'package:supabase_todo/features/task/presentation/widgets/filter_dropdowns.dart';
import 'package:supabase_todo/features/task/presentation/widgets/task_card.dart';
import 'package:supabase_todo/features/task/presentation/widgets/task_header.dart';

class TaskListPage extends StatefulWidget {
  final String userId;
  const TaskListPage({required this.userId, super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  TaskStatus? selectedStatus; // null = all
  String selectedCategory = 'Select category';
  String selectedCategoryId = '';
  String textFilter = '';
  final _debouncer = Debouncer(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().load(widget.userId);
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  List<TaskEntity> _applyFilters(List<TaskEntity> tasks) {
    return tasks.where((task) {
      final matchesStatus =
          selectedStatus == null || task.status == selectedStatus;
      final matchesText =
          task.title.toLowerCase().contains(textFilter) ||
          (task.description ?? '').toLowerCase().contains(textFilter);
      final matchesCategory =
          selectedCategory == 'Select category' && selectedCategoryId.isEmpty
          ? true
          : task.categoryId == selectedCategoryId;

      return matchesStatus && matchesText && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: BlocBuilder<TaskCubit, TaskState>(
            builder: (context, state) {
              if (state.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.errorMessage != null && state.tasks.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.errorMessage}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            context.read<TaskCubit>().load(widget.userId),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final tasks = _applyFilters(state.tasks);
              final categories = state.categories;

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskHeader(
                          onNewTask: () {
                            context
                                .push(
                                  '/tasks/form',
                                  extra: {
                                    'userId': widget.userId,
                                    'task': null,
                                  },
                                )
                                .then((returned) {
                                  if (returned != null &&
                                      returned is TaskEntity) {
                                    if (context.mounted) {
                                      context.read<TaskCubit>().upsertLocal(
                                        returned,
                                      );
                                    }
                                  }
                                });
                          },
                          onCategoryPressed: () {
                            context.push('/categories').then((_) {
                              if (context.mounted) {
                                context.read<TaskCubit>().load(widget.userId);
                              }
                            });
                          },
                          onLogoutPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                        TextField(
                          onChanged: (value) {
                            _debouncer(() {
                              setState(
                                () => textFilter = value.trim().toLowerCase(),
                              );
                            });
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search by title or description...',
                            prefixIcon: Icon(Icons.search),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FilterDropdowns(
                          selectedCategory: selectedCategory,
                          selectedStatus: selectedStatus,
                          categories: [
                            "Select category",
                            ...categories.map((cat) => cat.name),
                          ],
                          statusOptions: TaskStatus.toMap(),
                          onCategoryChanged: (val) => setState(() {
                            selectedCategory = val;
                            selectedCategoryId = categories
                                .firstWhere(
                                  (cat) => cat.name == val,
                                  orElse: () => CategoryEntity(
                                    id: '',
                                    name: '',
                                    userId: '',
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                                )
                                .id;
                          }),
                          onStatusChanged: (val) =>
                              setState(() => selectedStatus = val),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: tasks.isEmpty
                        ? const Center(child: Text("No tasks found"))
                        : ListView.builder(
                            itemCount: tasks.length,
                            itemBuilder: (_, i) {
                              final task = tasks[i];
                              final category = categories.firstWhere(
                                (cat) => cat.id == task.categoryId,
                                orElse: () => CategoryEntity(
                                  id: '',
                                  name: '',
                                  userId: '',
                                  createdAt: DateTime.now(),
                                  updatedAt: DateTime.now(),
                                ),
                              );
                              final categoryName = category.name.isNotEmpty
                                  ? category.name
                                  : null;

                              return TaskCard(
                                task: task,
                                categoryName: categoryName,
                                onTap: () => context
                                    .push(
                                      '/tasks/form',
                                      extra: {
                                        'userId': widget.userId,
                                        'task': task,
                                      },
                                    )
                                    .then((returned) {
                                      if (returned != null &&
                                          returned is TaskEntity) {
                                        if (context.mounted) {
                                          context.read<TaskCubit>().upsertLocal(
                                            returned,
                                          );
                                        }
                                      }
                                    }),
                                onDelete: () => DialogUtils.showDeleteDialog(
                                  context,
                                  'Delete Task',
                                  'Are you sure you want to delete "${task.title}"?',
                                  () {
                                    context.read<TaskCubit>().delete(
                                      task.id,
                                      widget.userId,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
