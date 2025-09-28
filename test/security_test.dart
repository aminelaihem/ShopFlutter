import 'package:flutter_test/flutter_test.dart';
import 'package:shopflutter/src/features/auth/presentation/viewmodels/auth_viewmodel.dart';

void main() {
  group('Tests de sécurité', () {
    test('Validation des entrées utilisateur', () {
      // Test de validation des emails
      expect(isValidEmail('test@example.com'), isTrue);
      expect(isValidEmail('invalid-email'), isFalse);
      expect(isValidEmail(''), isFalse);
      expect(isValidEmail(null), isFalse);
    });

    test('Validation des mots de passe', () {
      // Test de force des mots de passe
      expect(isStrongPassword('Password123!'), isTrue);
      expect(isStrongPassword('weak'), isFalse);
      expect(isStrongPassword('12345678'), isFalse);
      expect(isStrongPassword(''), isFalse);
    });

    test('Sanitisation des entrées', () {
      // Test de nettoyage des entrées
      expect(sanitizeInput('<script>alert("xss")</script>'), equals(''));
      expect(sanitizeInput('normal text'), equals('normal text'));
      expect(sanitizeInput(''), equals(''));
    });

    test('Validation des URLs', () {
      // Test de validation des URLs
      expect(isValidUrl('https://example.com'), isTrue);
      expect(isValidUrl('http://example.com'), isTrue);
      expect(isValidUrl('javascript:alert("xss")'), isFalse);
      expect(isValidUrl(''), isFalse);
    });
  });
}

// Fonctions utilitaires pour les tests de sécurité
bool isValidEmail(String? email) {
  if (email == null || email.isEmpty) return false;
  final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return emailRegex.hasMatch(email);
}

bool isStrongPassword(String? password) {
  if (password == null || password.isEmpty) return false;
  if (password.length < 8) return false;
  
  // Vérifier la présence d'au moins une majuscule, une minuscule, un chiffre et un caractère spécial
  final hasUpperCase = password.contains(RegExp(r'[A-Z]'));
  final hasLowerCase = password.contains(RegExp(r'[a-z]'));
  final hasDigits = password.contains(RegExp(r'[0-9]'));
  final hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  
  return hasUpperCase && hasLowerCase && hasDigits && hasSpecialChar;
}

String sanitizeInput(String input) {
  if (input.isEmpty) return input;
  
  // Supprimer les balises HTML et les scripts
  final htmlRegex = RegExp(r'<[^>]*>');
  final scriptRegex = RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false);
  
  String sanitized = input.replaceAll(scriptRegex, '');
  sanitized = sanitized.replaceAll(htmlRegex, '');
  
  // Échapper les caractères spéciaux
  sanitized = sanitized
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#x27;');
  
  return sanitized;
}

bool isValidUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  
  try {
    final uri = Uri.parse(url);
    return uri.hasScheme && 
           (uri.scheme == 'http' || uri.scheme == 'https') &&
           uri.host.isNotEmpty;
  } catch (e) {
    return false;
  }
}
