// lib/src/features/auth/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/routes.dart';
import '../../../../app/utils/validators.dart';
import '../viewmodels/login_vm.dart';
import '../widgets/auth_layout.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginVmProvider);
    final vm = ref.read(loginVmProvider.notifier);

    Future<void> submit() async {
      FocusScope.of(context).unfocus();
      if (!_formKey.currentState!.validate()) return;
      vm.setEmail(_emailCtrl.text);
      vm.setPassword(_pwdCtrl.text);
      final user = await vm.signIn();
      if (user == null) {
        final msg = ref.read(loginVmProvider).error ?? 'Échec de connexion';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    }

    return AuthLayout(
      title: 'Connexion',
      subtitle: 'Accéder à ShopFlutter',
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: (v) => validateEmail(v ?? ''),
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _pwdCtrl,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              validator: (v) => validatePassword(v ?? ''),
              onFieldSubmitted: (_) => submit(),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: state.isLoading ? null : submit,
                child: state.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Se connecter'),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => context.go(AppRoutes.register),
              child: const Text("Créer un compte"),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 8),
              Text(state.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
