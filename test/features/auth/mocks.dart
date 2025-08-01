import 'package:mocktail/mocktail.dart';
import 'package:supabase_todo/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_todo/features/auth/domain/usecases/login_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/check_session_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/logout_usecase.dart';
import 'package:supabase_todo/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockCheckSessionUsecase extends Mock implements CheckSessionUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}
