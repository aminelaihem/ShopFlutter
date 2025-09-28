// test/unit/viewmodels/auth/login_vm_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shopflutter/src/features/auth/domain/entities/user.dart';
import 'package:shopflutter/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopflutter/src/features/auth/domain/usecases/sign_in.dart';
import 'package:shopflutter/src/features/auth/presentation/viewmodels/login_vm.dart';

import 'login_vm_test.mocks.dart';

@GenerateMocks([SignIn])
void main() {
  group('LoginVm', () {
    late MockSignIn mockSignIn;
    late LoginVm loginVm;

    setUp(() {
      mockSignIn = MockSignIn();
      loginVm = LoginVm(mockSignIn);
    });

    test('devrait initialiser avec un état par défaut', () {
      // Assert
      expect(loginVm.state.email, equals(''));
      expect(loginVm.state.password, equals(''));
      expect(loginVm.state.isLoading, equals(false));
      expect(loginVm.state.error, isNull);
    });

    test('devrait mettre à jour l\'email', () {
      // Arrange
      const email = 'test@example.com';

      // Act
      loginVm.setEmail(email);

      // Assert
      expect(loginVm.state.email, equals(email));
    });

    test('devrait mettre à jour le mot de passe', () {
      // Arrange
      const password = 'password123';

      // Act
      loginVm.setPassword(password);

      // Assert
      expect(loginVm.state.password, equals(password));
    });

    test('devrait gérer une connexion réussie', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      const expectedUser = UserEntity(
        id: '1',
        email: 'test@example.com',
        displayName: 'Test User',
      );

      loginVm.setEmail(email);
      loginVm.setPassword(password);

      when(mockSignIn(email, password)).thenAnswer((_) async => expectedUser);

      // Act
      final result = await loginVm.signIn();

      // Assert
      expect(result, equals(expectedUser));
      expect(loginVm.state.isLoading, equals(false));
      expect(loginVm.state.error, isNull);
      verify(mockSignIn(email, password)).called(1);
    });

    test('devrait gérer une erreur de connexion', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'wrongpassword';
      const errorMessage = 'Mot de passe incorrect.';

      loginVm.setEmail(email);
      loginVm.setPassword(password);

      when(
        mockSignIn(email, password),
      ).thenThrow(AuthException('wrong-password', errorMessage));

      // Act
      final result = await loginVm.signIn();

      // Assert
      expect(result, isNull);
      expect(loginVm.state.isLoading, equals(false));
      expect(loginVm.state.error, equals(errorMessage));
    });

    test('devrait mettre isLoading à true pendant la connexion', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';

      loginVm.setEmail(email);
      loginVm.setPassword(password);

      when(mockSignIn(email, password)).thenAnswer((_) async {
        // Vérifier que isLoading est true pendant l'appel
        expect(loginVm.state.isLoading, equals(true));
        return const UserEntity(id: '1', email: 'test@example.com');
      });

      // Act
      await loginVm.signIn();

      // Assert
      expect(loginVm.state.isLoading, equals(false));
    });

    test(
      'devrait effacer l\'erreur précédente lors d\'une nouvelle tentative',
      () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';

        loginVm.setEmail(email);
        loginVm.setPassword(password);

        // Simuler une première erreur
        when(
          mockSignIn(email, password),
        ).thenThrow(AuthException('network-error', 'Erreur réseau'));

        await loginVm.signIn();
        expect(loginVm.state.error, isNotNull);

        // Simuler un succès la deuxième fois
        when(mockSignIn(email, password)).thenAnswer(
          (_) async => const UserEntity(id: '1', email: 'test@example.com'),
        );

        // Act
        await loginVm.signIn();

        // Assert
        expect(loginVm.state.error, isNull);
      },
    );
  });
}
