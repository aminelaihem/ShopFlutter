// test/unit/viewmodels/catalog/catalog_vm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/catalog/domain/entities/product.dart';
import 'package:shopflutter/src/features/catalog/domain/usecases/fetch_products.dart';
import 'package:shopflutter/src/features/catalog/domain/usecases/fetch_categories.dart';
import 'package:shopflutter/src/features/catalog/presentation/viewmodels/catalog_vm.dart';

import 'catalog_vm_test.mocks.dart';

@GenerateMocks([FetchProducts, FetchCategories])
void main() {
  group('CatalogVm', () {
    late MockFetchProducts mockFetchProducts;
    late MockFetchCategories mockFetchCategories;
    late CatalogVm catalogVm;

    setUp(() {
      mockFetchProducts = MockFetchProducts();
      mockFetchCategories = MockFetchCategories();
      catalogVm = CatalogVm(mockFetchProducts, mockFetchCategories);
    });

    test('devrait initialiser avec un état par défaut', () {
      // Assert
      expect(catalogVm.state.loading, equals(false));
      expect(catalogVm.state.error, isNull);
      expect(catalogVm.state.products, isEmpty);
      expect(catalogVm.state.categories, isEmpty);
      expect(catalogVm.state.query, equals(''));
      expect(catalogVm.state.selectedCategory, isNull);
    });

    test('devrait charger les produits et catégories avec succès', () async {
      // Arrange
      final products = [
        Product(
          id: 1,
          title: 'Product 1',
          price: 29.99,
          description: 'Description 1',
          category: 'electronics',
          thumbnail: 'image1.jpg',
          images: ['image1.jpg'],
        ),
        Product(
          id: 2,
          title: 'Product 2',
          price: 19.99,
          description: 'Description 2',
          category: 'clothing',
          thumbnail: 'image2.jpg',
          images: ['image2.jpg'],
        ),
      ];

      final categories = ['electronics', 'clothing', 'books'];

      when(mockFetchProducts()).thenAnswer((_) async => products);
      when(mockFetchCategories()).thenAnswer((_) async => categories);

      // Act
      await catalogVm.load();

      // Assert
      expect(catalogVm.state.loading, equals(false));
      expect(catalogVm.state.error, isNull);
      expect(catalogVm.state.products, equals(products));
      expect(catalogVm.state.categories, equals(['Tous', ...categories]));
      verify(mockFetchProducts()).called(1);
      verify(mockFetchCategories()).called(1);
    });

    test('devrait gérer les erreurs de chargement', () async {
      // Arrange
      when(mockFetchProducts()).thenThrow(Exception('Erreur réseau'));
      when(mockFetchCategories()).thenAnswer((_) async => []);

      // Act
      await catalogVm.load();

      // Assert
      expect(catalogVm.state.loading, equals(false));
      expect(catalogVm.state.error, isNotNull);
      expect(catalogVm.state.products, isEmpty);
    });

    test('devrait filtrer les produits par requête', () {
      // Arrange
      final products = [
        Product(
          id: 1,
          title: 'iPhone 13',
          price: 999.99,
          description: 'Smartphone Apple',
          category: 'electronics',
          thumbnail: 'iphone.jpg',
          images: ['iphone.jpg'],
        ),
        Product(
          id: 2,
          title: 'Samsung Galaxy',
          price: 799.99,
          description: 'Smartphone Android',
          category: 'electronics',
          thumbnail: 'samsung.jpg',
          images: ['samsung.jpg'],
        ),
        Product(
          id: 3,
          title: 'T-shirt',
          price: 19.99,
          description: 'Cotton t-shirt',
          category: 'clothing',
          thumbnail: 'tshirt.jpg',
          images: ['tshirt.jpg'],
        ),
      ];

      catalogVm.state = catalogVm.state.copyWith(products: products);

      // Act & Assert
      catalogVm.setQuery('iPhone');
      expect(catalogVm.state.visible.length, equals(1));
      expect(catalogVm.state.visible.first.title, equals('iPhone 13'));

      catalogVm.setQuery('smartphone');
      expect(catalogVm.state.visible.length, equals(2));

      catalogVm.setQuery('t-shirt');
      expect(catalogVm.state.visible.length, equals(1));
      expect(catalogVm.state.visible.first.title, equals('T-shirt'));
    });

    test('devrait filtrer les produits par catégorie', () {
      // Arrange
      final products = [
        Product(
          id: 1,
          title: 'iPhone 13',
          price: 999.99,
          description: 'Smartphone Apple',
          category: 'electronics',
          thumbnail: 'iphone.jpg',
          images: ['iphone.jpg'],
        ),
        Product(
          id: 2,
          title: 'T-shirt',
          price: 19.99,
          description: 'Cotton t-shirt',
          category: 'clothing',
          thumbnail: 'tshirt.jpg',
          images: ['tshirt.jpg'],
        ),
      ];

      catalogVm.state = catalogVm.state.copyWith(products: products);

      // Act & Assert
      catalogVm.selectCategory('electronics');
      expect(catalogVm.state.visible.length, equals(1));
      expect(catalogVm.state.visible.first.category, equals('electronics'));

      catalogVm.selectCategory('clothing');
      expect(catalogVm.state.visible.length, equals(1));
      expect(catalogVm.state.visible.first.category, equals('clothing'));

      catalogVm.selectCategory(null);
      expect(catalogVm.state.visible.length, equals(2));
    });

    test('devrait combiner filtres par requête et catégorie', () {
      // Arrange
      final products = [
        Product(
          id: 1,
          title: 'iPhone 13',
          price: 999.99,
          description: 'Smartphone Apple',
          category: 'electronics',
          thumbnail: 'iphone.jpg',
          images: ['iphone.jpg'],
        ),
        Product(
          id: 2,
          title: 'Samsung Galaxy',
          price: 799.99,
          description: 'Smartphone Android',
          category: 'electronics',
          thumbnail: 'samsung.jpg',
          images: ['samsung.jpg'],
        ),
        Product(
          id: 3,
          title: 'T-shirt',
          price: 19.99,
          description: 'Cotton t-shirt',
          category: 'clothing',
          thumbnail: 'tshirt.jpg',
          images: ['tshirt.jpg'],
        ),
      ];

      catalogVm.state = catalogVm.state.copyWith(products: products);

      // Act
      catalogVm.setQuery('smartphone');
      catalogVm.selectCategory('electronics');

      // Assert
      expect(catalogVm.state.visible.length, equals(2));
      expect(
        catalogVm.state.visible.every((p) => p.category == 'electronics'),
        isTrue,
      );
      expect(
        catalogVm.state.visible.every(
          (p) =>
              p.title.toLowerCase().contains('smartphone') ||
              p.description.toLowerCase().contains('smartphone'),
        ),
        isTrue,
      );
    });

    test('devrait effacer les filtres', () {
      // Arrange
      final products = [
        Product(
          id: 1,
          title: 'Product 1',
          price: 10.0,
          description: 'Desc 1',
          category: 'cat1',
          thumbnail: 'img1.jpg',
          images: ['img1.jpg'],
        ),
        Product(
          id: 2,
          title: 'Product 2',
          price: 20.0,
          description: 'Desc 2',
          category: 'cat2',
          thumbnail: 'img2.jpg',
          images: ['img2.jpg'],
        ),
      ];

      catalogVm.state = catalogVm.state.copyWith(products: products);
      catalogVm.setQuery('test');
      catalogVm.selectCategory('cat1');

      // Act
      catalogVm.setQuery('');
      catalogVm.selectCategory(null);

      // Assert
      expect(catalogVm.state.query, equals(''));
      expect(catalogVm.state.selectedCategory, isNull);
      expect(catalogVm.state.visible.length, equals(2));
    });
  });
}
