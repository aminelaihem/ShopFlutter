// lib/src/app_shell/home_page.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/router/routes.dart';
import '../app/di/auth_providers.dart';
import '../app/di/cart_providers.dart';
import '../app/di/order_providers.dart';
import '../features/catalog/presentation/viewmodels/catalog_vm.dart';
import '../features/cart/domain/entities/cart_item.dart';
import '../core/formatters/money.dart';

import './main_drawer.dart';



class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // si le catalogue n’est pas chargé, je le déclenche (pour les “à la une”)
    Future.microtask(() {
      final s = ref.read(catalogVmProvider);
      if (s.products.isEmpty) {
        ref.read(catalogVmProvider.notifier).load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider).asData?.value;
    final cartCount = ref.watch(cartCountProvider).maybeWhen(data: (v) => v, orElse: () => 0);
    final cartTotal = ref.watch(cartTotalProvider).maybeWhen(data: (v) => v, orElse: () => 0.0);
    final orders = ref.watch(ordersStreamProvider).maybeWhen(data: (v) => v, orElse: () => const []);
    final catalog = ref.watch(catalogVmProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: [
          // Panier (avec badge)
          IconButton(
            tooltip: 'Panier',
            onPressed: () => context.pushNamed('cart'),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                if (cartCount > 0)
                  Positioned(
                    right: -4,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text('$cartCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                    ),
                  ),
              ],
            ),
          ),

          // Déconnexion
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () async {
              await ref.read(signOutUsecaseProvider).call();
              if (context.mounted) context.goNamed('login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],

      ),
      drawer: const MainDrawer(),

      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          // header
          _Card(
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  child: Text(
                    (session?.email?.characters.first.toUpperCase() ?? 'S'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    session?.email != null ? 'Bienvenue, ${session!.email}' : 'Bienvenue 👋',
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (kIsWeb)
                  FilledButton.tonalIcon(
                    onPressed: () {
                      // plus tard: bouton “Installer” PWA si tu veux
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('PWA install: à brancher (optionnel)')),
                      );
                    },
                    icon: const Icon(Icons.install_mobile),
                    label: const Text('Installer'),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // actions rapides
          _SectionTitle('Actions rapides'),
          Row(
            children: [
              Expanded(
                child: _QuickAction(
                  icon: Icons.storefront,
                  label: 'Catalogue',
                  onTap: () => context.goNamed('catalog'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.shopping_bag,
                  label: cartCount > 0 ? 'Panier • ${cartCount}x' : 'Panier',
                  sublabel: cartCount > 0 ? formatPrice(cartTotal) : null,
                  onTap: () => context.goNamed('cart'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickAction(
                  icon: Icons.receipt_long,
                  label: 'Commandes',
                  onTap: () => context.goNamed('orders'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // dernières commandes
          _SectionTitle('Dernières commandes'),
          if (orders.isEmpty)
            _Muted('Aucune commande pour le moment.')
          else
            _Card(
              child: Column(
                children: [
                  for (final o in orders.take(3))
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.receipt_long_outlined),
                      title: Text('Commande ${o.id.substring(0, 8)}'),
                      subtitle: Text(
                        '${o.items.fold<int>(0, (int acc, CartItem e) => acc + e.qty)} article(s) • ${o.createdAt.toLocal()}',
                      ),
                      trailing: Text(formatPrice(o.total)),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // produits à la une (4 tuiles)
          _SectionTitle('À la une'),
          if (catalog.loading && catalog.products.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
          else if (catalog.visible.isEmpty)
            _Muted('Rien à afficher.')
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: catalog.visible.length.clamp(0, 4),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: .78,
              ),
              itemBuilder: (context, i) {
                final p = catalog.visible[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.pushNamed('product', pathParameters: {'id': '${p.id}'}),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(p.thumbnail, fit: BoxFit.cover, width: double.infinity),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(formatPrice(p.price), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: child,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(text, style: Theme.of(context).textTheme.titleMedium));
}

class _Muted extends StatelessWidget {
  const _Muted(this.text);
  final String text;
  @override
  Widget build(BuildContext context) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(text, style: TextStyle(color: Theme.of(context).hintColor)));
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, this.sublabel, this.onTap});
  final IconData icon;
  final String label;
  final String? sublabel;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                    if (sublabel != null)
                      Text(sublabel!, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
