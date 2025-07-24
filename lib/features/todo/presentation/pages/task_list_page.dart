import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_bloc.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_events.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_state.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/filter_tabs.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/task_card.dart';
import 'package:supabase_todo/features/todo/presentation/widgets/task_header.dart';

class TaskListPage extends StatefulWidget {
  final String userId;
  const TaskListPage({required this.userId, super.key});

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  String selectedFilter = 'all';
  String textFilter = '';

  @override
  void initState() {
    super.initState();
    context.read<TaskBloc>().add(LoadTasks(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            if (state is TaskLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TaskLoaded) {
              final tasks = _applyFilters(state.tasks);
              final countMap = {
                'all': state.tasks.length,
                'to_do': state.tasks.where((t) => t.status == 'to_do').length,
                'in_progress': state.tasks
                    .where((t) => t.status == 'in_progress')
                    .length,
                'done': state.tasks.where((t) => t.status == 'done').length,
              };

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TaskHeader(
                          onNewTask: () {},
                          onCategoryPressed: () {},
                          onLogoutPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
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
                        const SizedBox(height: 8),
                        FilterTabs(
                          selected: selectedFilter,
                          counts: countMap,
                          onChanged: (value) {
                            setState(() => selectedFilter = value);
                          },
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
                              return TaskCard(task: task);
                            },
                          ),
                  ),
                ],
              );
            }

            return const Center(child: Text("No tasks found"));
          },
        ),
      ),
    );
  }

  List<TaskEntity> _applyFilters(List<TaskEntity> tasks) {
    return tasks.where((task) {
      final matchesStatus =
          selectedFilter == 'all' || task.status == selectedFilter;
      final matchesText =
          task.title.toLowerCase().contains(textFilter) ||
          (task.description ?? '').toLowerCase().contains(textFilter);

      return matchesStatus && matchesText;
    }).toList();
  }
}
