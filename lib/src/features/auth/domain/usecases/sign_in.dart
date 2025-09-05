// lib/src/features/auth/domain/usecases/sign_in.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository _repo;
  SignIn(this._repo);

  Future<UserEntity> call(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      throw AuthException('invalid-input', 'Email et mot de passe requis.');
    }
    return _repo.signIn(email: email.trim(), password: password);
  }
}
