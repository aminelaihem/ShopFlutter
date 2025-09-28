// lib/src/app/di/auth_providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/entities/user.dart';

// Use cases
import '../../features/auth/domain/usecases/sign_in.dart' as uc;
import '../../features/auth/domain/usecases/register.dart' as uc;
import '../../features/auth/domain/usecases/sign_in_with_google.dart' as uc;
import '../../features/auth/domain/usecases/register_with_google.dart' as uc;
import '../../features/auth/domain/usecases/sign_out.dart' as uc;
import '../../features/auth/domain/usecases/watch_auth_state.dart' as uc;

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn(
  scopes: ['email', 'profile'],
));

final authDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) => 
  FirebaseAuthDataSource(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  )
);

final authRepositoryProvider =
Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)));

// Providers des use cases (aliasés pour éviter tout conflit de noms)
final signInUsecaseProvider = Provider<uc.SignIn>((ref) => uc.SignIn(ref.watch(authRepositoryProvider)));
final registerUsecaseProvider = Provider<uc.Register>((ref) => uc.Register(ref.watch(authRepositoryProvider)));
final signInWithGoogleUsecaseProvider = Provider<uc.SignInWithGoogle>((ref) => uc.SignInWithGoogle(ref.watch(authRepositoryProvider)));
final registerWithGoogleUsecaseProvider = Provider<uc.RegisterWithGoogle>((ref) => uc.RegisterWithGoogle(ref.watch(authRepositoryProvider)));
final signOutUsecaseProvider = Provider<uc.SignOut>((ref) => uc.SignOut(ref.watch(authRepositoryProvider)));
final watchAuthStateUsecaseProvider =
Provider<uc.WatchAuthState>((ref) => uc.WatchAuthState(ref.watch(authRepositoryProvider)));

/// Session (stream) exposée à toute l’app.
final sessionProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(watchAuthStateUsecaseProvider).call();
});
