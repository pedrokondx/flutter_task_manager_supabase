import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

abstract class AuthRepository {
  Future<Either<AuthException, UserEntity>> login(
    String email,
    String password,
  );
  Future<Either<AuthException, UserEntity?>> hasSession();
  Future<Either<AuthException, Unit>> logout();
  Future<Either<AuthException, UserEntity>> register(
    String email,
    String password,
  );
}
