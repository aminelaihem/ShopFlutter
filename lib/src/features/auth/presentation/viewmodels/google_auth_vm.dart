// lib/src/features/auth/presentation/viewmodels/google_auth_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/register_with_google.dart';
import '../../../../app/di/auth_providers.dart';

class GoogleAuthState {
  final bool isLoading;
  final String? error;

  const GoogleAuthState({this.isLoading = false, this.error});

  GoogleAuthState copyWith({bool? isLoading, String? error}) =>
      GoogleAuthState(isLoading: isLoading ?? this.isLoading, error: error);
}

class GoogleAuthVm extends StateNotifier<GoogleAuthState> {
  final SignInWithGoogle _signInWithGoogle;
  final RegisterWithGoogle _registerWithGoogle;

  GoogleAuthVm(this._signInWithGoogle, this._registerWithGoogle)
    : super(const GoogleAuthState());

  Future<UserEntity?> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signInWithGoogle();
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  Future<UserEntity?> registerWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _registerWithGoogle();
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void clearError() => state = state.copyWith(error: null);
}

final googleAuthVmProvider =
    StateNotifierProvider<GoogleAuthVm, GoogleAuthState>((ref) {
      return GoogleAuthVm(
        ref.watch(signInWithGoogleUsecaseProvider),
        ref.watch(registerWithGoogleUsecaseProvider),
      );
    });
