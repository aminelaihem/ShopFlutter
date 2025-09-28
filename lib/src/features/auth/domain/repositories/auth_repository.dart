// lib/src/features/auth/domain/repositories/auth_repository.dart
import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserEntity> signIn({required String email, required String password});
  Future<UserEntity> register({
    required String email,
    required String password,
  });
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> registerWithGoogle();
  Future<void> signOut();
  Stream<UserEntity?> watchAuthState();
}

class AuthException implements Exception {
  final String code;
  final String message;
  AuthException(this.code, this.message);
  @override
  String toString() => message;
}
