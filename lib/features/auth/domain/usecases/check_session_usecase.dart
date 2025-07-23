import '../repositories/auth_repository.dart';

class CheckSessionUseCase {
  final AuthRepository repository;

  CheckSessionUseCase(this.repository);

  Future<bool> call() => repository.hasSession();
}
