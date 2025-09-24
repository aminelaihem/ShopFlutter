// lib/src/features/catalog/domain/usecases/fetch_product.dart
import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class FetchProduct {
  final CatalogRepository _repo;
  FetchProduct(this._repo);
  Future<Product> call(int id) => _repo.fetchProduct(id);
}
