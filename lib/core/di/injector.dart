import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/auth/data/datasources/remote/auth_supabase_datasource.dart';
import 'package:supabase_todo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';
import 'package:supabase_todo/features/todo/data/datasources/remote/task_supabase_datasource.dart';
import 'package:supabase_todo/features/todo/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/todo/data/repositories/task_repository_impl.dart';
import 'package:supabase_todo/features/todo/domain/repositories/task_repository.dart';
import 'package:supabase_todo/features/todo/domain/usecases/create_task_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/delete_task_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/get_tasks_usecase.dart';
import 'package:supabase_todo/features/todo/domain/usecases/update_task_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase client
  final supabase = Supabase.instance.client;

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthSupabaseDatasource(supabase),
  );
  sl.registerLazySingleton<TaskDatasource>(
    () => TaskSupabaseDatasource(supabase),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));

  sl.registerLazySingleton(() => GetTasksUsecase(sl()));
  sl.registerLazySingleton(() => CreateTaskUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUsecase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUsecase(sl()));
}
