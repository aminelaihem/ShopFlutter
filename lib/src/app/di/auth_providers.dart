// lib/src/app/di/auth_providers.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/data/datasources/firebase_auth_datasource.dart';
import '../../features/auth/data/repositories_impl/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/auth/domain/entities/user.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authDataSourceProvider =
Provider<FirebaseAuthDataSource>((ref) => FirebaseAuthDataSource(ref.watch(firebaseAuthProvider)));

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.watch(authDataSourceProvider)));

final signInUsecaseProvider = Provider<SignIn>((ref) => SignIn(ref.watch(authRepositoryProvider)));
final registerUsecaseProvider = Provider<Register>((ref) => Register(ref.watch(authRepositoryProvider)));
final signOutUsecaseProvider = Provider<SignOut>((ref) => SignOut(ref.watch(authRepositoryProvider)));
final watchAuthStateUsecaseProvider =
Provider<WatchAuthState>((ref) => WatchAuthState(ref.watch(authRepositoryProvider)));

/// Session (stream) exposée à toute l’app.
final sessionProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(watchAuthStateUsecaseProvider).call();
});
