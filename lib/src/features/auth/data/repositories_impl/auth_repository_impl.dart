// lib/src/features/auth/data/repositories_impl/auth_repository_impl.dart
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;
  AuthRepositoryImpl(this._ds);

  @override
  Future<UserEntity> signIn({required String email, required String password}) async {
    try {
      final u = await _ds.signIn(email, password);
      return UserModel.fromFirebaseUser(u).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, _mapCodeToMsg(e));
    }
  }

  @override
  Future<UserEntity> register({required String email, required String password}) async {
    try {
      final u = await _ds.register(email, password);
      return UserModel.fromFirebaseUser(u).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, _mapCodeToMsg(e));
    }
  }

  @override
  Future<UserEntity> signInWithGoogle() async {
    try {
      final u = await _ds.signInWithGoogle();
      return UserModel.fromFirebaseUser(u).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, _mapCodeToMsg(e));
    }
  }

  @override
  Future<UserEntity> registerWithGoogle() async {
    try {
      final u = await _ds.registerWithGoogle();
      return UserModel.fromFirebaseUser(u).toEntity();
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.code, _mapCodeToMsg(e));
    }
  }

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  Stream<UserEntity?> watchAuthState() =>
      _ds.watchAuthState().map((u) => u == null ? null : UserModel.fromFirebaseUser(u).toEntity());

  String _mapCodeToMsg(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Utilisateur introuvable.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'email-already-in-use':
        return 'Email déjà utilisé.';
      case 'weak-password':
        return 'Mot de passe trop faible.';
      case 'sign-in-cancelled':
        return 'Connexion Google annulée.';
      case 'network-request-failed':
        return 'Erreur de connexion réseau.';
      case 'invalid-credential':
        return 'Identifiants Google invalides.';
      default:
        return e.message ?? 'Erreur d\'authentification.';
    }
  }
}
