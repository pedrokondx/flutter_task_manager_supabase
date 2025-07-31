import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_events.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/task/presentation/bloc/task_bloc.dart';
import 'package:supabase_todo/features/task/presentation/bloc/task_events.dart';
import 'package:supabase_todo/features/task/presentation/bloc/task_state.dart';
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
  String selectedFilter = 'all';
  String selectedCategory = 'Select category';
  String selectedCategoryId = '';
  String textFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(widget.userId));
  }

  List<TaskEntity> _applyFilters(List<TaskEntity> tasks) {
    return tasks.where((task) {
      final matchesStatus =
          selectedFilter == 'all' || task.status == selectedFilter;
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
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is TaskOverviewLoaded) {
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
                              context.push(
                                '/tasks/form',
                                extra: {'userId': widget.userId, 'task': null},
                              );
                            },
                            onCategoryPressed: () {
                              context.push('/categories').then((_) {
                                if (context.mounted) {
                                  context.read<TaskBloc>().add(
                                    LoadTasks(widget.userId),
                                  );
                                }
                              });
                            },
                            onLogoutPressed: () {
                              context.read<AuthBloc>().add(
                                AuthLogoutRequested(),
                              );
                            },
                          ),

                          TextField(
                            onChanged: (value) {
                              setState(
                                () => textFilter = value.trim().toLowerCase(),
                              );
                            },
                            decoration: const InputDecoration(
                              hintText: 'Search by title or description...',
                              prefixIcon: Icon(Icons.search),
                            ),
                          ),
                          const SizedBox(height: 16),

                          FilterDropdowns(
                            selectedCategory: selectedCategory,
                            selectedStatus: selectedFilter,
                            categories: [
                              "Select category",
                              ...categories.map((cat) => cat.name),
                            ],
                            statusOptions: {
                              'all': 'All',
                              'to_do': 'To Do',
                              'in_progress': 'In Progress',
                              'done': 'Done',
                            },
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
                                setState(() => selectedFilter = val),
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
                                  onTap: () => context.push(
                                    '/tasks/form',
                                    extra: {
                                      'userId': widget.userId,
                                      'task': task,
                                    },
                                  ),
                                  onDelete: () => DialogUtils.showDeleteDialog(
                                    context,
                                    'Delete Task',
                                    'Are you sure you want to delete "${task.title}"?',
                                    () {
                                      context.read<TaskBloc>().add(
                                        DeleteTaskEvent(task.id, widget.userId),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              } else if (state is TaskError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${state.message}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<TaskBloc>().add(
                          LoadTasks(widget.userId),
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text("No tasks found"));
            },
          ),
        ),
      ),
    );
  }
}
