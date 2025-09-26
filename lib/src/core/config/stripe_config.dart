// lib/src/core/config/stripe_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeConfig {
  /// 1) lit depuis .env
  /// 2) fallback sur --dart-define (utile en CI/CD)
  static String get publishableKey {
    return dotenv.env['STRIPE_PUBLISHABLE_KEY'] ??
        const String.fromEnvironment('STRIPE_PUBLISHABLE_KEY', defaultValue: '');
  }
  // Configuration
  static const String currency = 'eur';
  static const String country = 'FR';
  
  // Messages d'erreur
  static const String paymentFailedMessage = 'Le paiement a échoué. Veuillez réessayer.';
  static const String paymentSuccessMessage = 'Paiement réussi ! Commande créée avec succès.';
  static const String invalidCardMessage = 'Veuillez remplir tous les champs de la carte';
  static const String networkErrorMessage = 'Erreur de connexion. Vérifiez votre internet.';

}
