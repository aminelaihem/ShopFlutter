// lib/src/features/orders/presentation/pages/orders_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/formatters/money.dart';
import '../../../../app/di/order_providers.dart';
import '../../domain/entities/order.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (orders) {
          if (orders.isEmpty) return const Center(child: Text('Aucune commande.'));
          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) => _OrderTile(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order});
  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final count = order.items.fold<int>(0, (a, e) => a + e.qty);
    return ListTile(
      title: Text('Commande ${order.id.substring(0, 8)}'),
      subtitle: Text('${count} article(s) • ${order.createdAt.toLocal()}'),
      trailing: Text(formatPrice(order.total)),
    );
  }
}
