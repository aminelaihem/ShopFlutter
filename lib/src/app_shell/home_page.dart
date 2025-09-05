// lib/src/app_shell/home_page.dart  (UI propre + logout)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app/di/auth_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlutter'),
        actions: [
          if (session != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(child: Text(session.email ?? '', style: const TextStyle(fontSize: 13))),
            ),
          TextButton.icon(
            onPressed: () => ref.read(signOutUsecaseProvider).call(),
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('Logout'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 60),
            const SizedBox(height: 10),
            Text(
              session?.email ?? 'Connecté',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            const Text('Auth OK. On attaquera le catalogue après.'),
          ],
        ),
      ),
    );
  }
}
