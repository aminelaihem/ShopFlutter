// lib/src/features/catalog/presentation/pages/catalog_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/di/auth_providers.dart';
import '../../../cart/presentation/widgets/cart_badge_button.dart';
import '../viewmodels/catalog_vm.dart';
import '../widgets/product_card.dart';
import '../widgets/search_field.dart';

import '../../../../app_shell/main_drawer.dart';


class CatalogPage extends ConsumerStatefulWidget {
  const CatalogPage({super.key});
  @override
  ConsumerState<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends ConsumerState<CatalogPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(catalogVmProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogVmProvider);
    final vm = ref.read(catalogVmProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopFlutter'),
        actions: [
          const CartBadgeButton(), // badge panier
          IconButton(
            tooltip: 'Déconnexion',
            onPressed: () => ref.read(signOutUsecaseProvider).call(),
            icon: const Icon(Icons.logout),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SearchField(onChanged: vm.setQuery),
          ),
        ),
      ),
      drawer: const MainDrawer(),
      body: RefreshIndicator(
        onRefresh: vm.refresh,
        child: Builder(
          builder: (_) {
            if (state.loading && state.products.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.error != null && state.products.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 36),
                  const SizedBox(height: 8),
                  Center(child: Text(state.error!)),
                  const SizedBox(height: 8),
                  Center(
                    child: FilledButton(onPressed: vm.load, child: const Text('Réessayer')),
                  ),
                ],
              );
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _CategoriesBar(
                    categories: state.categories,
                    selected: state.selectedCategory,
                    onSelect: vm.selectCategory,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final p = state.visible[index];
                        return ProductCard(
                          product: p,
                          onTap: () => context.pushNamed(
                            'product',
                            pathParameters: {'id': '${p.id}'},
                          ),
                        );
                      },
                      childCount: state.visible.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: .70,
                    ),
                  ),
                ),
                if (state.visible.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: Text('Aucun produit.')),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CategoriesBar extends StatelessWidget {
  const _CategoriesBar({required this.categories, required this.selected, required this.onSelect});
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) {
          final c = categories[i];
          final isSel = (selected ?? 'Tous') == c;
          return ChoiceChip(
            label: Text(c),
            selected: isSel,
            onSelected: (_) => onSelect(c),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: categories.length,
      ),
    );
  }
}
