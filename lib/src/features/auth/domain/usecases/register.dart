// lib/src/features/auth/domain/usecases/register.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Register {
  final AuthRepository _repo;
  Register(this._repo);

  Future<UserEntity> call(String email, String password) {
    if (email.trim().isEmpty || password.length < 6) {
      throw AuthException('invalid-input', 'Mot de passe min. 6 caractères.');
    }
    return _repo.register(email: email.trim(), password: password);
  }
}
