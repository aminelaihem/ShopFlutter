// lib/src/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  FirebaseAuthDataSource(this._auth);

  Future<User> signIn(String email, String password) async {
    print('🔐 Tentative de connexion avec: $email');
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw FirebaseAuthException(code: 'timeout', message: 'Timeout de connexion');
        },
      );
      print('✅ Connexion réussie: ${cred.user?.email}');
      final user = cred.user;
      if (user == null) throw FirebaseAuthException(code: 'user-null', message: 'Utilisateur introuvable.');
      return user;
    } catch (e) {
      print('❌ Erreur de connexion: $e');
      rethrow;
    }
  }

  Future<User> register(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) throw FirebaseAuthException(code: 'user-null', message: 'Utilisateur introuvable.');
    return user;
  }

  Future<void> signOut() => _auth.signOut();

  Stream<User?> watchAuthState() => _auth.authStateChanges();
}
