// lib/src/features/cart/domain/repositories/cart_repository.dart
import '../entities/cart_item.dart';

abstract class CartRepository {
  Future<void> add(CartItem item);
  Future<void> updateQty(int productId, int qty);
  Future<void> remove(int productId);
  Future<void> clear();

  Stream<List<CartItem>> watchItems();
  Future<List<CartItem>> getItems();
  Future<int> getCount();
  Future<double> getTotal();
}
