// lib/src/features/orders/domain/entities/order.dart
import '../../../cart/domain/entities/cart_item.dart';

class OrderEntity {
  final String id;           // uuid
  final List<CartItem> items;
  final double total;
  final DateTime createdAt;
  final String? fullName;
  final String? address;
  final String? city;
  final String? zip;

  const OrderEntity({
    required this.id,
    required this.items,
    required this.total,
    required this.createdAt,
    this.fullName,
    this.address,
    this.city,
    this.zip,
  });
}
