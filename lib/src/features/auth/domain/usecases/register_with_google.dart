// lib/src/features/auth/domain/usecases/register_with_google.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterWithGoogle {
  final AuthRepository _repo;
  RegisterWithGoogle(this._repo);

  Future<UserEntity> call() {
    return _repo.registerWithGoogle();
  }
}
