// lib/src/features/catalog/domain/repositories/catalog_repository.dart
import '../entities/product.dart';

abstract class CatalogRepository {
  Future<List<Product>> fetchProducts();
  Future<Product> fetchProduct(int id);
  Future<List<String>> fetchCategories();
}
