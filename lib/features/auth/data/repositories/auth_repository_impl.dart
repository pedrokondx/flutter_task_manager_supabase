import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<Either<AuthException, UserEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final dto = await remote.login(email, password);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(AuthException.loginFailure(e));
    }
  }

  @override
  Future<Either<AuthException, UserEntity?>> hasSession() async {
    try {
      final dto = await remote.hasSession();
      if (dto == null) {
        return Right(null);
      }
      return Right(dto.toEntity());
    } catch (e) {
      return Left(AuthException.sessionCheckFailure(e));
    }
  }

  @override
  Future<Either<AuthException, Unit>> logout() async {
    try {
      await remote.logout();
      return const Right(unit);
    } catch (e) {
      return Left(AuthException.logoutFailure(e));
    }
  }

  @override
  Future<Either<AuthException, UserEntity>> register(
    String email,
    String password,
  ) async {
    try {
      final dto = await remote.register(email, password);
      return Right(dto.toEntity());
    } catch (e) {
      return Left(AuthException.registrationFailure(e));
    }
  }
}
