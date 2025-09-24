// lib/src/features/catalog/presentation/viewmodels/catalog_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/usecases/fetch_categories.dart';
import '../../../catalog/domain/usecases/fetch_products.dart';
import '../../../../app/di/catalog_providers.dart';

class CatalogState {
  final bool loading;
  final String? error;
  final List<Product> products;
  final List<String> categories;
  final String query;
  final String? selectedCategory;

  const CatalogState({
    this.loading = false,
    this.error,
    this.products = const [],
    this.categories = const [],
    this.query = '',
    this.selectedCategory,
  });

  CatalogState copyWith({
    bool? loading,
    String? error,
    List<Product>? products,
    List<String>? categories,
    String? query,
    String? selectedCategory,
  }) {
    return CatalogState(
      loading: loading ?? this.loading,
      error: error,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      query: query ?? this.query,
      selectedCategory: selectedCategory,
    );
  }

  List<Product> get visible {
    final q = query.trim().toLowerCase();
    return products.where((p) {
      final byQuery = q.isEmpty ||
          p.title.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
      final byCat = selectedCategory == null || p.category == selectedCategory;
      return byQuery && byCat;
    }).toList();
  }
}

class CatalogVm extends StateNotifier<CatalogState> {
  CatalogVm(this._fetchProducts, this._fetchCategories) : super(const CatalogState());

  final FetchProducts _fetchProducts;
  final FetchCategories _fetchCategories;

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final cats = await _fetchCategories();
      final items = await _fetchProducts();
      state = state.copyWith(
        loading: false,
        categories: ['Tous', ...cats],
        products: items,
      );
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void setQuery(String q) => state = state.copyWith(query: q);
  void selectCategory(String? cat) => state = state.copyWith(selectedCategory: cat == 'Tous' ? null : cat);
  Future<void> refresh() => load();
}

final catalogVmProvider = StateNotifierProvider<CatalogVm, CatalogState>((ref) {
  return CatalogVm(ref.watch(fetchProductsProvider), ref.watch(fetchCategoriesProvider));
});
