import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call(String email, String password) =>
      repository.login(email, password);
}
