// lib/src/features/catalog/domain/usecases/fetch_categories.dart
import '../repositories/catalog_repository.dart';

class FetchCategories {
  final CatalogRepository _repo;
  FetchCategories(this._repo);
  Future<List<String>> call() => _repo.fetchCategories();
}
