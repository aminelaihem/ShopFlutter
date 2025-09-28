// test/unit/usecases/catalog/fetch_products_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/catalog/domain/entities/product.dart';
import 'package:shopflutter/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:shopflutter/src/features/catalog/domain/usecases/fetch_products.dart';

import 'fetch_products_test.mocks.dart';

@GenerateMocks([CatalogRepository])
void main() {
  group('FetchProducts Use Case', () {
    late MockCatalogRepository mockRepository;
    late FetchProducts fetchProductsUseCase;

    setUp(() {
      mockRepository = MockCatalogRepository();
      fetchProductsUseCase = FetchProducts(mockRepository);
    });

    test('devrait retourner une liste de produits quand la récupération réussit', () async {
      // Arrange
      final expectedProducts = [
        Product(
          id: 1,
          title: 'Test Product 1',
          price: 29.99,
          description: 'Description 1',
          category: 'electronics',
          thumbnail: 'image1.jpg',
          images: ['image1.jpg', 'image1_2.jpg'],
        ),
        Product(
          id: 2,
          title: 'Test Product 2',
          price: 19.99,
          description: 'Description 2',
          category: 'clothing',
          thumbnail: 'image2.jpg',
          images: ['image2.jpg', 'image2_2.jpg'],
        ),
      ];

      when(mockRepository.fetchProducts()).thenAnswer((_) async => expectedProducts);

      // Act
      final result = await fetchProductsUseCase();

      // Assert
      expect(result, equals(expectedProducts));
      expect(result.length, equals(2));
      verify(mockRepository.fetchProducts()).called(1);
    });

    test('devrait retourner une liste vide quand aucun produit n\'est trouvé', () async {
      // Arrange
      when(mockRepository.fetchProducts()).thenAnswer((_) async => <Product>[]);

      // Act
      final result = await fetchProductsUseCase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.fetchProducts()).called(1);
    });

    test('devrait propager l\'exception du repository', () async {
      // Arrange
      when(mockRepository.fetchProducts()).thenThrow(Exception('Erreur réseau'));

      // Act & Assert
      expect(
        () => fetchProductsUseCase(),
        throwsA(isA<Exception>()),
      );
    });

    test('devrait appeler le repository une seule fois', () async {
      // Arrange
      when(mockRepository.fetchProducts()).thenAnswer((_) async => <Product>[]);

      // Act
      await fetchProductsUseCase();
      await fetchProductsUseCase();

      // Assert
      verify(mockRepository.fetchProducts()).called(2);
    });
  });
}
