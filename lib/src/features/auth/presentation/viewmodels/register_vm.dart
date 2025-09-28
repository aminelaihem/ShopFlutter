// lib/src/features/auth/presentation/viewmodels/register_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register.dart';
import '../../../../app/di/auth_providers.dart';

class RegisterState {
  final String email;
  final String password;
  final bool isLoading;
  final String? error;
  const RegisterState({
    this.email = '',
    this.password = '',
    this.isLoading = false,
    this.error,
  });

  RegisterState copyWith({
    String? email,
    String? password,
    bool? isLoading,
    String? error,
  }) => RegisterState(
    email: email ?? this.email,
    password: password ?? this.password,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

class RegisterVm extends StateNotifier<RegisterState> {
  final Register _register;
  RegisterVm(this._register) : super(const RegisterState());

  Future<UserEntity?> register() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _register(state.email, state.password);
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

final registerVmProvider = StateNotifierProvider<RegisterVm, RegisterState>((
  ref,
) {
  return RegisterVm(ref.watch(registerUsecaseProvider));
});
