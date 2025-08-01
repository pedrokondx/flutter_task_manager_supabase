import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import '../repositories/auth_repository.dart';

class LoginUsecase {
  final AuthRepository repository;

  LoginUsecase(this.repository);

  Future<Either<AuthException, UserEntity>> call(
    String email,
    String password,
  ) {
    if (email.isEmpty || password.isEmpty) {
      throw AuthException.invalidCredentials();
    }
    return repository.login(email, password);
  }
}
