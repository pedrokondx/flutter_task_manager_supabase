import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';

import '../repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<UserEntity?> call() => repository.hasSession();
}
