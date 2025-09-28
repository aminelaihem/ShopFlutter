// lib/src/features/cart/domain/entities/cart_item.dart
class CartItem {
  final int productId;
  final String title;
  final double price;
  final int qty;
  final String thumbnail;

  const CartItem({
    required this.productId,
    required this.title,
    required this.price,
    required this.qty,
    required this.thumbnail,
  });

  CartItem copyWith({int? qty}) => CartItem(
    productId: productId,
    title: title,
    price: price,
    qty: qty ?? this.qty,
    thumbnail: thumbnail,
  );

  double get lineTotal => price * qty;
}
