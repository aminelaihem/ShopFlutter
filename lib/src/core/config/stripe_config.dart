// lib/src/core/config/stripe_config.dart
class StripeConfig {
  // Clés de test Stripe - Remplacez par vos vraies clés
  static const String publishableKey = 'pk_test_51SBEbIJDdq5uniaJNYZiitIhr4kE3XnkjwGWzzR72EmTRrOVnZokswGwTcJHLDmnCmpb5c5A4jfbKk6T0dtdjPgT00yMYoeahP';
  static const String secretKey = 'sk_test_51SBEbIJDdq5uniaJc3SdZdHF53r776JIETwAbbtpE4Nb1P2XPCEZPQI1QryIhCbfKeg3zCCxRsG3aAiUeWlfA2sc00LuzMyR9I';
  
  // Configuration
  static const String currency = 'eur';
  static const String country = 'FR';
  
  // Messages d'erreur
  static const String paymentFailedMessage = 'Le paiement a échoué. Veuillez réessayer.';
  static const String paymentSuccessMessage = 'Paiement réussi ! Commande créée avec succès.';
  static const String invalidCardMessage = 'Veuillez remplir tous les champs de la carte';
  static const String networkErrorMessage = 'Erreur de connexion. Vérifiez votre internet.';
}
