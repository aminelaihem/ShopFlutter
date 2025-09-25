// lib/src/features/orders/domain/repositories/order_repository.dart
import '../entities/order.dart';

abstract class OrderRepository {
  Future<void> save(OrderEntity order);
  Stream<List<OrderEntity>> watchOrders();
  Future<List<OrderEntity>> getOrders();
  Future<void> clear(); // optionnel
}
