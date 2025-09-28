// lib/src/core/config/stripe_config.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeConfig {
  // Clés Stripe chargées depuis le fichier .env
  static String get publishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static String get secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  // Configuration
  static String get currency => dotenv.env['STRIPE_CURRENCY'] ?? 'eur';
  static String get country => dotenv.env['STRIPE_COUNTRY'] ?? 'FR';

  // Messages d'erreur
  static const String paymentFailedMessage =
      'Le paiement a échoué. Veuillez réessayer.';
  static const String paymentSuccessMessage =
      'Paiement réussi ! Commande créée avec succès.';
  static const String invalidCardMessage =
      'Veuillez remplir tous les champs de la carte';
  static const String networkErrorMessage =
      'Erreur de connexion. Vérifiez votre internet.';
}
