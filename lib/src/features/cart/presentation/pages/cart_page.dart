// lib/src/features/cart/presentation/pages/cart_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/formatters/money.dart';
import '../../domain/entities/cart_item.dart';
import '../../presentation/viewmodels/cart_vm.dart';
import '../../presentation/widgets/cart_item_tile.dart';
import '../../../../app/di/cart_providers.dart';

class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(cartVmProvider);
    final totalAsync = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Panier')),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Panier vide'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return CartItemTile(
                      item: item,
                      onQtyChanged: (q) => ref.read(cartVmProvider.notifier).setQty(item.productId, q),
                      onRemove: () => ref.read(cartVmProvider.notifier).remove(item.productId),
                    );
                  },
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: totalAsync.when(
                        data: (t) => Text('Total: ${formatPrice(t)}', style: Theme.of(context).textTheme.titleMedium),
                        loading: () => const Text('Calcul...'),
                        error: (e, _) => Text('Erreur total: $e'),
                      ),
                    ),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () {
                          // mock checkout
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Checkout mock: commande créée')),
                          );
                          ref.read(cartVmProvider.notifier).clear();
                        },
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
