// lib/src/features/catalog/data/models/product_model.dart
import '../../domain/entities/product.dart';

class ProductModel {
  final int id;
  final String title;
  final double price;
  final String image;
  final String description;
  final String category;

  ProductModel({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    price: (json['price'] as num).toDouble(),
    image: json['image'] as String,
    description: json['description'] as String,
    category: json['category'] as String,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'price': price,
    'image': image,
    'description': description,
    'category': category,
  };

  Product toEntity() => Product(
    id: id,
    title: title,
    price: price,
    thumbnail: image,
    images: [image],
    description: description,
    category: category,
  );
}
