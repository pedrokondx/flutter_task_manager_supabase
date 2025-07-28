import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/theme/theme.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_event.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/todo/presentation/bloc/task_bloc.dart';
import 'core/di/injector.dart' as di;
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://himoxskkepawhegsskwm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbW94c2trZXBhd2hlZ3Nza3dtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjQ3ODUsImV4cCI6MjA2ODcwMDc4NX0.7y5TkbhCja_EFsmP_Md2pxWil_Bv7Sh4rCOggVinsEA',
  );

  await di.init();

  final authBloc = AuthBloc(
    loginUseCase: di.sl(),
    checkSessionUseCase: di.sl(),
    logoutUsecase: di.sl(),
    registerUseCase: di.sl(),
  )..add(AuthCheckSession());

  AppRouter.init(authBloc);

  runApp(MyApp(authBloc: authBloc));
}

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
