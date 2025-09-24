// lib/src/features/cart/presentation/viewmodels/cart_vm.dart
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../../app/di/cart_providers.dart';
import '../../../../app/di/catalog_providers.dart';
import '../../../catalog/domain/usecases/fetch_product.dart';

class CartVm extends StateNotifier<AsyncValue<List<CartItem>>> {
  CartVm(this._repo, this._fetch) : super(const AsyncValue.loading()) {
    _sub = _repo.watchItems().listen((items) {
      state = AsyncValue.data(items);
    });
  }

  final CartRepository _repo;
  final FetchProduct _fetch;
  late final StreamSubscription _sub;

  Future<void> addFromProductId(int id, {int qty = 1}) async {
    final p = await _fetch(id);
    await _repo.add(CartItem(
      productId: p.id,
      title: p.title,
      price: p.price,
      qty: qty,
      thumbnail: p.thumbnail,
    ));
  }

  Future<void> setQty(int id, int qty) => _repo.updateQty(id, qty);
  Future<void> remove(int id) => _repo.remove(id);
  Future<void> clear() => _repo.clear();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final cartVmProvider = StateNotifierProvider<CartVm, AsyncValue<List<CartItem>>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  final fetch = ref.watch(fetchProductProvider);
  return CartVm(repo, fetch);
});
