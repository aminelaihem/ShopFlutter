// test/unit/usecases/auth/sign_in_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/auth/domain/entities/user.dart';
import 'package:shopflutter/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopflutter/src/features/auth/domain/usecases/sign_in.dart';

import 'sign_in_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  group('SignIn Use Case', () {
    late MockAuthRepository mockRepository;
    late SignIn signInUseCase;

    setUp(() {
      mockRepository = MockAuthRepository();
      signInUseCase = SignIn(mockRepository);
    });

    test('devrait retourner un utilisateur quand la connexion réussit', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const expectedUser = UserEntity(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      when(mockRepository.signIn(email: email, password: password))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await signInUseCase(email, password);

      // Assert
      expect(result, equals(expectedUser));
      verify(mockRepository.signIn(email: email, password: password)).called(1);
    });

    test('devrait lancer une exception quand l\'email est vide', () async {
      // Arrange
      const email = '';
      const password = 'password123';

      // Act & Assert
      expect(
        () => signInUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.signIn(email: email, password: password));
    });

    test('devrait lancer une exception quand le mot de passe est vide', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '';

      // Act & Assert
      expect(
        () => signInUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.signIn(email: email, password: password));
    });

    test('devrait lancer une exception quand l\'email ne contient que des espaces', () async {
      // Arrange
      const email = '   ';
      const password = 'password123';

      // Act & Assert
      expect(
        () => signInUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
      verifyNever(mockRepository.signIn(email: email, password: password));
    });

    test('devrait propager l\'exception du repository', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const errorMessage = 'Utilisateur introuvable.';

      when(mockRepository.signIn(email: email, password: password))
          .thenThrow(AuthException('user-not-found', errorMessage));

      // Act & Assert
      expect(
        () => signInUseCase(email, password),
        throwsA(isA<AuthException>()),
      );
    });

    test('devrait trimmer l\'email avant de l\'envoyer au repository', () async {
      // Arrange
      const email = '  test@example.com  ';
      const password = 'password123';
      const expectedUser = UserEntity(id: '1', email: 'test@example.com');

      when(mockRepository.signIn(email: 'test@example.com', password: password))
          .thenAnswer((_) async => expectedUser);

      // Act
      await signInUseCase(email, password);

      // Assert
      verify(mockRepository.signIn(email: 'test@example.com', password: password)).called(1);
    });
  });
}
