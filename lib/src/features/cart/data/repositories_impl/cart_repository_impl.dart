// lib/src/features/cart/data/repositories_impl/cart_repository_impl.dart
import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';

import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl(this._box);
  final Box _box;

  static const _key = 'cart_items';

  // lis depuis Hive → renvoie une liste MUTABLE (pas const)
  List<CartItem> _read() {
    final raw = _box.get(_key);
    if (raw is! String) return <CartItem>[]; // important: liste growable
    final List list = jsonDecode(raw);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return CartItem(
        productId: m['productId'] as int,
        title: m['title'] as String,
        price: (m['price'] as num).toDouble(),
        qty: (m['qty'] as num).toInt(),
        thumbnail: m['thumbnail'] as String,
      );
    }).toList(); // growable by default
  }

  Future<void> _write(List<CartItem> items) async {
    final list = items
        .map(
          (e) => {
            'productId': e.productId,
            'title': e.title,
            'price': e.price,
            'qty': e.qty,
            'thumbnail': e.thumbnail,
          },
        )
        .toList();
    await _box.put(_key, jsonEncode(list));
  }

  @override
  Future<void> add(CartItem item) async {
    final list = _read();
    final idx = list.indexWhere((e) => e.productId == item.productId);
    if (idx >= 0) {
      list[idx] = list[idx].copyWith(qty: list[idx].qty + item.qty);
    } else {
      list.add(item);
    }
    await _write(list);
    _notify();
  }

  @override
  Future<void> updateQty(int productId, int qty) async {
    final list = _read();
    final idx = list.indexWhere((e) => e.productId == productId);
    if (idx >= 0) {
      if (qty <= 0) {
        list.removeAt(idx);
      } else {
        list[idx] = list[idx].copyWith(qty: qty);
      }
      await _write(list);
      _notify();
    }
  }

  @override
  Future<void> remove(int productId) async {
    final list = _read();
    list.removeWhere((e) => e.productId == productId);
    await _write(list);
    _notify();
  }

  @override
  Future<void> clear() async {
    await _write(<CartItem>[]); // vide propre
    _notify();
  }

  // petit stream maison pour notifier l’UI
  final _ctrl = StreamController<List<CartItem>>.broadcast();
  void _notify() => _ctrl.add(_read());

  @override
  Stream<List<CartItem>> watchItems() {
    Future.microtask(() => _ctrl.add(_read())); // push l’état courant direct
    return _ctrl.stream;
  }

  @override
  Future<List<CartItem>> getItems() async => _read();

  @override
  Future<int> getCount() async => _read().fold<int>(0, (acc, e) => acc + e.qty);

  @override
  Future<double> getTotal() async =>
      _read().fold<double>(0, (acc, e) => acc + e.price * e.qty);
}
