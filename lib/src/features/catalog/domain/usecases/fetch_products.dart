// lib/src/features/catalog/domain/usecases/fetch_products.dart
import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class FetchProducts {
  final CatalogRepository _repo;
  FetchProducts(this._repo);
  Future<List<Product>> call() => _repo.fetchProducts();
}
