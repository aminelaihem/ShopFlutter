// lib/src/features/catalog/presentation/pages/product_detail_page.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/formatters/money.dart';
import '../viewmodels/product_vm.dart';

class ProductDetailPage extends ConsumerWidget {
  const ProductDetailPage({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productVmProvider(id));
    final p = state.product;

    return Scaffold(
      appBar: AppBar(title: const Text('Détail produit')),
      body: Builder(
        builder: (_) {
          if (state.loading && p == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null && p == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 36),
                  const SizedBox(height: 8),
                  Text(state.error!),
                ],
              ),
            );
          }
          if (p == null) return const SizedBox.shrink();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: p.images.first,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (_, __, ___) => const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(p.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(formatPrice(p.price), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(height: 12),
              Text(p.description),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: () {
                    // On branchera le panier ici dans la feature "cart".
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('À venir : ajout au panier')),
                    );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Ajouter au panier'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
