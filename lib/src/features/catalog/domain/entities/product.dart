// lib/src/features/catalog/domain/entities/product.dart
class Product {
  final int id;
  final String title;
  final double price;
  final String thumbnail;
  final List<String> images;
  final String description;
  final String category;

  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.images,
    required this.description,
    required this.category,
  });
}
