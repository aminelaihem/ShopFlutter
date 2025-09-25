// lib/src/features/orders/presentation/pages/checkout_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/formatters/money.dart';
import '../../../cart/presentation/viewmodels/cart_vm.dart';
import '../viewmodels/checkout_vm.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(cartVmProvider);
    final vm = ref.read(checkoutVmProvider.notifier);
    final state = ref.watch(checkoutVmProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          final total = items.fold<double>(0, (a, e) => a + e.price * e.qty);
          final isDisabled = state.loading || items.isEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('Résumé', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ...items.map((e) => ListTile(
                title: Text(e.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${e.qty} × ${formatPrice(e.price)}'),
                trailing: Text(formatPrice(e.lineTotal)),
              )),
              const Divider(height: 32),
              Text('Livraison (mock)', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Nom complet'), onChanged: vm.setFullName),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Adresse'), onChanged: vm.setAddress),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Ville'), onChanged: vm.setCity)),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Code postal'), onChanged: vm.setZip)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Total: ${formatPrice(total)}', style: Theme.of(context).textTheme.titleLarge),
                  ),
                  SizedBox(
                    height: 48,
                    child: FilledButton(
                      onPressed: isDisabled
                          ? null
                          : () async {
                        final orderId = await vm.submit();
                        if (orderId != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Commande créée'),
                            ),
                          );
                          // retour onglet Catalogue (shell)
                          context.goNamed('catalog');
                        } else if (state.error != null && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(state.error!)),
                          );
                        }
                      },
                      child: state.loading
                          ? const CircularProgressIndicator(strokeWidth: 2)
                          : const Text('Payer (mock)'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
