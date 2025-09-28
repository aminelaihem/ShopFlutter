// test/unit/usecases/auth/register_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/auth/domain/entities/user.dart';
import 'package:shopflutter/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopflutter/src/features/auth/domain/usecases/register.dart';

import 'register_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('Register Use Case', () {
    late MockAuthRepository mockRepository;
    late Register registerUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      registerUseCase = Register(mockRepository);
    });

    test('devrait retourner un utilisateur quand l\'inscription réussit', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const expectedUser = UserEntity(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      when(mockRepository.register(email: email, password: password))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await registerUseCase(email, password);

      // Assert
      expect(result, equals(expectedUser));
      verify(mockRepository.register(email: email, password: password)).called(1);
    });

    test('devrait lancer une exception quand l\'email est vide', () async {
      // Arrange
      const email = '';
      const password = 'password123';

      // Act & Assert
      expect(
        () => registerUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.register(email: email, password: password));
    });

    test('devrait lancer une exception quand le mot de passe est trop court', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '12345'; // < 6 caractères

      // Act & Assert
      expect(
        () => registerUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.register(email: email, password: password));
    });

    test('devrait lancer une exception quand l\'email ne contient que des espaces', () async {
      // Arrange
      const email = '   ';
      const password = 'password123';

      // Act & Assert
      expect(
        () => registerUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.register(email: email, password: password));
    });

    test('devrait accepter un mot de passe de 6 caractères', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '123456';
      const expectedUser = UserEntity(id: '1', email: 'test@example.com');

      when(mockRepository.register(email: email, password: password))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await registerUseCase(email, password);

      // Assert
      expect(result, equals(expectedUser));
      verify(mockRepository.register(email: email, password: password)).called(1);
    });

    test('devrait propager l\'exception du repository', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      when(mockRepository.register(email: email, password: password))
          .thenThrow(AuthException('email-already-in-use', 'Email déjà utilisé.'));

      // Act & Assert
      expect(
        () => registerUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
    });

    test('devrait trimmer l\'email avant de l\'envoyer au repository', () async {
      // Arrange
      const email = '  test@example.com  ';
      const password = 'password123';
      const expectedUser = UserEntity(id: '1', email: 'test@example.com');

      when(mockRepository.register(email: 'test@example.com', password: password))
          .thenAnswer((_) async => expectedUser);

      // Act
      await registerUseCase(email, password);

      // Assert
      verify(mockRepository.register(email: 'test@example.com', password: password)).called(1);
    });
  });
}
