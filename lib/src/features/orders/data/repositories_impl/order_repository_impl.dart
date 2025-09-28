// lib/src/features/orders/data/repositories_impl/order_repository_impl.dart
import 'dart:async';
import 'dart:convert';
import 'package:hive/hive.dart';

import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  OrderRepositoryImpl(this._box);
  final Box _box;

  static const _key = 'orders';

  List<OrderEntity> _read() {
    final raw = _box.get(_key);
    if (raw is! String) return <OrderEntity>[];
    final List list = jsonDecode(raw);
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      final List itemsJson = m['items'] as List;
      final items = itemsJson.map((x) {
        final mm = x as Map<String, dynamic>;
        return CartItem(
          productId: mm['productId'] as int,
          title: mm['title'] as String,
          price: (mm['price'] as num).toDouble(),
          qty: (mm['qty'] as num).toInt(),
          thumbnail: mm['thumbnail'] as String,
        );
      }).toList();
      return OrderEntity(
        id: m['id'] as String,
        items: items,
        total: (m['total'] as num).toDouble(),
        createdAt: DateTime.parse(m['createdAt'] as String),
        fullName: m['fullName'] as String?,
        address: m['address'] as String?,
        city: m['city'] as String?,
        zip: m['zip'] as String?,
      );
    }).toList();
  }

  Future<void> _write(List<OrderEntity> orders) async {
    final list = orders.map((o) {
      final items = o.items
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
      return {
        'id': o.id,
        'items': items,
        'total': o.total,
        'createdAt': o.createdAt.toIso8601String(),
        'fullName': o.fullName,
        'address': o.address,
        'city': o.city,
        'zip': o.zip,
      };
    }).toList();
    await _box.put(_key, jsonEncode(list));
  }

  @override
  Future<void> save(OrderEntity order) async {
    final list = _read();
    list.insert(0, order); // ordre récent d’abord
    await _write(list);
    _notify();
  }

  @override
  Stream<List<OrderEntity>> watchOrders() {
    Future.microtask(() => _ctrl.add(_read()));
    return _ctrl.stream;
  }

  @override
  Future<List<OrderEntity>> getOrders() async => _read();

  @override
  Future<void> clear() async {
    await _write(<OrderEntity>[]);
    _notify();
  }

  final _ctrl = StreamController<List<OrderEntity>>.broadcast();
  void _notify() => _ctrl.add(_read());
}
