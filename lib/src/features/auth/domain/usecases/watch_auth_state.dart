// lib/src/features/auth/domain/usecases/watch_auth_state.dart
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository _repo;
  WatchAuthState(this._repo);
  Stream<UserEntity?> call() => _repo.watchAuthState();
}
