import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart';

import '../repositories/auth_repository.dart';

class CheckSessionUsecase {
  final AuthRepository repository;

  CheckSessionUsecase(this.repository);

  Future<Either<AuthException, UserEntity?>> call() => repository.hasSession();
}
