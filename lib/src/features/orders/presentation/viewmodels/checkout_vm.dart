// lib/src/features/orders/presentation/viewmodels/checkout_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../../cart/domain/repositories/cart_repository.dart';
import '../../../../app/di/cart_providers.dart';
import '../../../../app/di/order_providers.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class CheckoutState {
  final String fullName;
  final String address;
  final String city;
  final String zip;
  final bool loading;
  final String? error;

  const CheckoutState({
    this.fullName = '',
    this.address = '',
    this.city = '',
    this.zip = '',
    this.loading = false,
    this.error,
  });

  CheckoutState copyWith({
    String? fullName,
    String? address,
    String? city,
    String? zip,
    bool? loading,
    String? error,
  }) => CheckoutState(
    fullName: fullName ?? this.fullName,
    address: address ?? this.address,
    city: city ?? this.city,
    zip: zip ?? this.zip,
    loading: loading ?? this.loading,
    error: error,
  );
}

class CheckoutVm extends StateNotifier<CheckoutState> {
  CheckoutVm(this._orders, this._cart) : super(const CheckoutState());

  final OrderRepository _orders;
  final CartRepository _cart;

  void setFullName(String v) => state = state.copyWith(fullName: v);
  void setAddress(String v) => state = state.copyWith(address: v);
  void setCity(String v) => state = state.copyWith(city: v);
  void setZip(String v) => state = state.copyWith(zip: v);

  Future<String?> submit() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _cart.getItems();
      if (items.isEmpty) throw Exception('Panier vide');

      final total = items.fold<double>(0, (a, e) => a + e.price * e.qty);
      final id = const Uuid().v4();

      final order = OrderEntity(
        id: id,
        items: List<CartItem>.from(items),
        total: total,
        createdAt: DateTime.now(),
        fullName: state.fullName.trim().isEmpty ? null : state.fullName.trim(),
        address: state.address.trim().isEmpty ? null : state.address.trim(),
        city: state.city.trim().isEmpty ? null : state.city.trim(),
        zip: state.zip.trim().isEmpty ? null : state.zip.trim(),
      );

      await _orders.save(order);
      await _cart.clear();
      state = state.copyWith(loading: false);
      return id;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return null;
    }
  }
}

final checkoutVmProvider = StateNotifierProvider<CheckoutVm, CheckoutState>((
  ref,
) {
  final orders = ref.watch(orderRepositoryProvider);
  final cart = ref.watch(cartRepositoryProvider);
  return CheckoutVm(orders, cart);
});
