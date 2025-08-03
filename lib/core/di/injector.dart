import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/core/data/datasources/category_preview_datasource.dart';
import 'package:supabase_todo/core/data/datasources/remote/category_preview_supabase_datasource.dart';
import 'package:supabase_todo/core/data/repositories/category_preview_repository_impl.dart';
import 'package:supabase_todo/core/domain/repositories/category_preview_repository.dart';
import 'package:supabase_todo/features/attachment/data/services/attachment_validator_service.dart';
import 'package:supabase_todo/features/attachment/domain/services/file_validation_service.dart';
import 'package:supabase_todo/features/auth/data/datasources/remote/auth_supabase_datasource.dart';
import 'package:supabase_todo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';
import 'package:supabase_todo/features/category/data/datasources/category_datasource.dart';
import 'package:supabase_todo/features/category/data/datasources/remote/category_supabase_datasource.dart';
import 'package:supabase_todo/features/category/data/repositories/category_repository_impl.dart';
import 'package:supabase_todo/features/category/domain/repositories/category_repository.dart';
import 'package:supabase_todo/features/category/domain/usecases/create_category_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:supabase_todo/core/domain/usecases/get_categories_usecase.dart';
import 'package:supabase_todo/features/category/domain/usecases/update_category_usecase.dart';
import 'package:supabase_todo/features/attachment/data/datasources/attachment_datasource.dart';
import 'package:supabase_todo/features/attachment/data/datasources/remote/attachment_supabase_datasource.dart';
import 'package:supabase_todo/features/attachment/data/repositories/attachment_repository_impl.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/create_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/delete_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/get_attachment_usecase.dart';
import 'package:supabase_todo/features/task/data/datasources/remote/task_supabase_datasource.dart';
import 'package:supabase_todo/features/task/data/datasources/task_datasource.dart';
import 'package:supabase_todo/features/task/data/repositories/task_repository_impl.dart';
import 'package:supabase_todo/features/task/domain/repositories/task_repository.dart';
import 'package:supabase_todo/features/task/domain/usecases/create_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/delete_task_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/get_tasks_usecase.dart';
import 'package:supabase_todo/features/task/domain/usecases/update_task_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase client
  final supabase = Supabase.instance.client;

  // Services
  sl.registerLazySingleton<FileValidationService>(
    () => AttachmentValidationService(),
  );

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthSupabaseDatasource(supabase),
  );
  sl.registerLazySingleton<TaskDatasource>(
    () => TaskSupabaseDatasource(supabase),
  );
  sl.registerLazySingleton<CategoryDatasource>(
    () => CategorySupabaseDatasource(supabase),
  );
  sl.registerLazySingleton<CategoryPreviewDatasource>(
    () => CategoryPreviewSupabaseDatasource(supabase),
  );
  sl.registerLazySingleton<AttachmentDatasource>(
    () => AttachmentSupabaseDatasource(supabase),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepositoryImpl(sl()));
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CategoryPreviewRepository>(
    () => CategoryPreviewRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AttachmentRepository>(
    () => AttachmentRepositoryImpl(sl()),
  );

  // UseCases
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => CheckSessionUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));

  sl.registerLazySingleton(() => GetTasksUsecase(sl()));
  sl.registerLazySingleton(() => CreateTaskUsecase(sl()));
  sl.registerLazySingleton(() => UpdateTaskUsecase(sl()));
  sl.registerLazySingleton(() => DeleteTaskUsecase(sl()));

  sl.registerLazySingleton(() => GetCategoriesUsecase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUsecase(sl(), sl()));
  sl.registerLazySingleton(() => UpdateCategoryUsecase(sl(), sl()));
  sl.registerLazySingleton(() => DeleteCategoryUsecase(sl()));

  sl.registerLazySingleton(() => GetAttachmentsUsecase(sl()));
  sl.registerLazySingleton(() => CreateAttachmentUsecase(sl(), sl()));
  sl.registerLazySingleton(() => DeleteAttachmentUsecase(sl()));
}
