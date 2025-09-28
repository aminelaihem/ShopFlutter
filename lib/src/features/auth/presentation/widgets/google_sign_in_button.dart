// lib/src/features/auth/presentation/widgets/google_sign_in_button.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/google_auth_vm.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
    this.isRegister = false,
  });

  final VoidCallback onSuccess;
  final bool isRegister;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(googleAuthVmProvider);
    final vm = ref.read(googleAuthVmProvider.notifier);

    Future<void> handleGoogleSignIn() async {
      final user = isRegister
          ? await vm.registerWithGoogle()
          : await vm.signInWithGoogle();

      if (user != null) {
        onSuccess();
      } else if (state.error != null) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      }
    }

    return _SocialButton(
      onPressed: state.isLoading ? null : handleGoogleSignIn,
      icon: Icons.g_mobiledata,
      label: isRegister
          ? 'S\'inscrire avec Google'
          : 'Se connecter avec Google',
      color: const Color(0xFF4285F4),
      isLoading: state.isLoading,
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    color.withOpacity(0.7),
                  ),
                ),
              )
            : Icon(icon, color: Colors.white, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          disabledBackgroundColor: color.withOpacity(0.6),
        ),
      ),
    );
  }
}
