// lib/src/features/auth/domain/usecases/sign_in_with_google.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  final AuthRepository _repo;
  SignInWithGoogle(this._repo);

  Future<UserEntity> call() {
    return _repo.signInWithGoogle();
  }
}
