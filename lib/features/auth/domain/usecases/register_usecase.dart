import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<UserEntity> call(String email, String password) =>
      repository.register(email, password);
}
