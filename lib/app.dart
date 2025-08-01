import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/core/di/injector.dart' as di;
import 'package:supabase_todo/core/router/router.dart';
import 'package:supabase_todo/core/ui/theme/theme.dart';
import 'package:supabase_todo/features/attachment/presentation/bloc/attachment_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/task/presentation/bloc/task_bloc.dart';

class MyApp extends StatelessWidget {
  final AuthBloc authBloc;

  const MyApp({super.key, required this.authBloc});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider(
          create: (_) => TaskBloc(
            getTasks: di.sl(),
            createTask: di.sl(),
            updateTask: di.sl(),
            deleteTask: di.sl(),
            getCategories: di.sl(),
          ),
        ),
        BlocProvider(
          create: (_) => AttachmentBloc(
            createAttachment: di.sl(),
            getAttachments: di.sl(),
            deleteAttachment: di.sl(),
          ),
        ),
        BlocProvider(
          create: (_) => CategoryBloc(
            getCategories: di.sl(),
            createCategory: di.sl(),
            updateCategory: di.sl(),
            deleteCategory: di.sl(),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Supabase Todo',
        theme: AppTheme.light,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
