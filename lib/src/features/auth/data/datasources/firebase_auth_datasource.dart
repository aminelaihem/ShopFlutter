// lib/src/features/auth/data/datasources/firebase_auth_datasource.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthDataSource {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  
  FirebaseAuthDataSource(this._auth, this._googleSignIn);

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

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  Stream<User?> watchAuthState() => _auth.authStateChanges();

  /// Connexion avec Google
  Future<User> signInWithGoogle() async {
    print('🔐 Tentative de connexion Google');
    try {
      // Déclencher le flux d'authentification Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw FirebaseAuthException(
          code: 'sign-in-cancelled', 
          message: 'Connexion Google annulée par l\'utilisateur'
        );
      }

      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Créer un nouveau credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Une fois connecté, retourner l'utilisateur
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user == null) {
        throw FirebaseAuthException(code: 'user-null', message: 'Utilisateur introuvable.');
      }
      
      print('✅ Connexion Google réussie: ${user.email}');
      return user;
    } catch (e) {
      print('❌ Erreur de connexion Google: $e');
      rethrow;
    }
  }

  /// Inscription avec Google (même processus que la connexion)
  Future<User> registerWithGoogle() async {
    // L'inscription et la connexion Google sont identiques
    // Firebase crée automatiquement un compte si l'utilisateur n'existe pas
    return await signInWithGoogle();
  }
}
