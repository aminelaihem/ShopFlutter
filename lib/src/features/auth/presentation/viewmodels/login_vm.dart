// lib/src/features/auth/presentation/viewmodels/login_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/sign_in.dart';
import '../../../../app/di/auth_providers.dart';

class LoginState {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;
  const LoginState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
  });

  LoginState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? error,
  }) => LoginState(
    email: email ?? this.email,
    password: password ?? this.password,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class LoginVm extends StateNotifier<LoginState> {
  final SignIn _signIn;
  LoginVm(this._signIn) : super(const LoginState());

  Future<UserEntity?> signIn() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _signIn(state.email, state.password);
      state = state.copyWith(isLoading: false);
      return user;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  void setEmail(String v) => state = state.copyWith(email: v);
  void setPassword(String v) => state = state.copyWith(password: v);
}

final loginVmProvider = StateNotifierProvider<LoginVm, LoginState>((ref) {
  return LoginVm(ref.watch(signInUsecaseProvider));
});
