// lib/src/app_shell/main_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';
import '../app/di/auth_providers.dart';
import '../app/di/cart_providers.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).asData?.value;
    final count = ref.watch(cartCountProvider).maybeWhen(data: (v) => v, orElse: () => 0);

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
              accountName: Text('ShopFlutter', style: const TextStyle(color: Colors.white70)),
              accountEmail: Text(session?.email ?? 'invité', style: const TextStyle(color: Colors.white)),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  (session?.email?.characters.first.toUpperCase() ?? 'S'),
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('Catalogue'),
              onTap: () {
                Navigator.of(context).pop();
                context.go(AppRoutes.catalog);
              },
            ),

            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: const Text('Panier'),
              trailing: count > 0
                  ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 12)),
              )
                  : null,
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.cart);
              },
            ),

            ListTile(
              leading: const Icon(Icons.receipt_long_outlined),
              title: const Text('Mes commandes'),
              onTap: () {
                Navigator.of(context).pop();
                context.push(AppRoutes.orders);
              },
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Déconnexion'),
              onTap: () async {
                Navigator.of(context).pop();
                await ref.read(signOutUsecaseProvider).call();
                if (context.mounted) context.go(AppRoutes.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
