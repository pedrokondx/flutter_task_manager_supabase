import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:supabase_todo/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:supabase_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Supabase client
  final supabase = Supabase.instance.client;

  // Data sources
  sl.registerLazySingleton<AuthDataSource>(
    () => AuthRemoteDataSourceImpl(supabase),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // UseCases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => CheckSessionUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
}
