// lib/src/features/catalog/presentation/viewmodels/product_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/usecases/fetch_product.dart';
import '../../../../app/di/catalog_providers.dart';

class ProductState {
  final bool loading;
  final String? error;
  final Product? product;

  const ProductState({this.loading = false, this.error, this.product});

  ProductState copyWith({bool? loading, String? error, Product? product}) =>
      ProductState(loading: loading ?? this.loading, error: error, product: product ?? this.product);
}

class ProductVm extends StateNotifier<ProductState> {
  ProductVm(this._fetch) : super(const ProductState());
  final FetchProduct _fetch;

  Future<void> load(int id) async {
    state = state.copyWith(loading: true, error: null);
    try {
      final p = await _fetch(id);
      state = state.copyWith(loading: false, product: p);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }
}

final productVmProvider = StateNotifierProvider.family<ProductVm, ProductState, int>((ref, id) {
  final fetch = ref.watch(fetchProductProvider);
  final vm = ProductVm(fetch);
  // auto-load
  vm.load(id);
  return vm;
});
