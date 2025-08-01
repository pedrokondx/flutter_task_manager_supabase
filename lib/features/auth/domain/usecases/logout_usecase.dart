import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final AuthRepository repository;

  LogoutUsecase(this.repository);

  Future<Either<AuthException, Unit>> call() => repository.logout();
}
