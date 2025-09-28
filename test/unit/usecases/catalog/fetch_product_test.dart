// test/unit/usecases/catalog/fetch_product_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/catalog/domain/entities/product.dart';
import 'package:shopflutter/src/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:shopflutter/src/features/catalog/domain/usecases/fetch_product.dart';

import 'fetch_product_test.mocks.dart';

@GenerateMocks([CatalogRepository])
void main() {
  group('FetchProduct Use Case', () {
    late MockCatalogRepository mockRepository;
    late FetchProduct fetchProductUseCase;

    setUp(() {
      mockRepository = MockCatalogRepository();
      fetchProductUseCase = FetchProduct(mockRepository);
    });

    test('devrait retourner un produit quand la récupération réussit', () async {
      // Arrange
      const productId = 1;
      final expectedProduct = Product(
        id: productId,
        title: 'Test Product',
        price: 29.99,
        description: 'Test Description',
        category: 'electronics',
        thumbnail: 'test.jpg',
        images: ['test.jpg', 'test_2.jpg'],
      );

      when(mockRepository.fetchProduct(productId)).thenAnswer((_) async => expectedProduct);

      // Act
      final result = await fetchProductUseCase(productId);

      // Assert
      expect(result, equals(expectedProduct));
      expect(result.id, equals(productId));
      verify(mockRepository.fetchProduct(productId)).called(1);
    });

    test('devrait propager l\'exception du repository', () async {
      // Arrange
      const productId = 999;
      when(mockRepository.fetchProduct(productId)).thenThrow(Exception('Produit introuvable'));

      // Act & Assert
      expect(
        () => fetchProductUseCase(productId),
        throwsA(isA<Exception>()),
      );
    });

    test('devrait gérer les IDs négatifs', () async {
      // Arrange
      const productId = -1;
      when(mockRepository.fetchProduct(productId)).thenThrow(Exception('ID invalide'));

      // Act & Assert
      expect(
        () => fetchProductUseCase(productId),
        throwsA(isA<Exception>()),
      );
    });

    test('devrait gérer les IDs zéro', () async {
      // Arrange
      const productId = 0;
      when(mockRepository.fetchProduct(productId)).thenThrow(Exception('ID invalide'));

      // Act & Assert
      expect(
        () => fetchProductUseCase(productId),
        throwsA(isA<Exception>()),
      );
    });
  });
}
