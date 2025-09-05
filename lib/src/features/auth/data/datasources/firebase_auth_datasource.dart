// lib/src/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  FirebaseAuthDataSource(this._auth);

  Future<User> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = cred.user;
    if (user == null) throw FirebaseAuthException(code: 'user-null', message: 'Utilisateur introuvable.');
    return user;
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
