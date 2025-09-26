# Configuration Stripe pour ShopFlutter

## 🚀 Configuration rapide

### 1. Obtenir les clés Stripe

1. Créez un compte sur [stripe.com](https://stripe.com)
2. Allez dans le Dashboard Stripe
3. Récupérez vos clés de test :
   - **Clé publique** : `pk_test_...`
   - **Clé secrète** : `sk_test_...`

### 2. Configurer les clés

Ouvrez le fichier `lib/src/core/config/stripe_config.dart` et remplacez :

```dart
class StripeConfig {
  // Remplacez par vos vraies clés Stripe
  static const String publishableKey = 'pk_test_VOTRE_CLE_PUBLIQUE';
  static const String secretKey = 'sk_test_VOTRE_CLE_SECRETE';
  
  // Configuration
  static const String currency = 'eur';
  static const String country = 'FR';
}
```

### 3. Cartes de test Stripe

Le projet inclut déjà des cartes de test prêtes à utiliser :

#### ✅ Cartes qui fonctionnent :
- **4242 4242 4242 4242** - Carte Visa de test réussie
- **5555 5555 5555 4444** - Carte Mastercard de test

#### ❌ Cartes pour tester les erreurs :
- **4000 0000 0000 0002** - Carte refusée
- **4000 0000 0000 9995** - Fonds insuffisants

### 4. Tester le paiement

1. Lancez l'application
2. Ajoutez des produits au panier
3. Allez au checkout
4. Sélectionnez une carte de test
5. Remplissez les informations (ou utilisez les cartes prédéfinies)
6. Cliquez sur "Payer avec Stripe"

## 🔧 Fonctionnalités implémentées

### Interface utilisateur
- ✅ Sélecteur de cartes de test
- ✅ Formulaire de carte de crédit moderne
- ✅ Validation en temps réel
- ✅ Détection automatique du type de carte
- ✅ Animations fluides

### Intégration Stripe
- ✅ Création de PaymentIntent
- ✅ Confirmation de paiement
- ✅ Gestion des erreurs
- ✅ États de chargement
- ✅ Messages de succès/erreur

### Sécurité
- ✅ Clés de test uniquement
- ✅ Validation côté client
- ✅ Gestion des erreurs sécurisée

## 🚨 Important

- **NE JAMAIS** commiter les vraies clés Stripe
- Utilisez uniquement les clés de test en développement
- Pour la production, utilisez des variables d'environnement
- Testez toujours avec les cartes de test avant de déployer

## 📱 Test sur mobile

Pour tester sur un appareil physique :

1. Installez l'application
2. Utilisez les cartes de test fournies
3. Vérifiez que les paiements sont bien traités
4. Consultez le Dashboard Stripe pour voir les transactions

## 🔍 Dépannage

### Erreur "Invalid API Key"
- Vérifiez que vos clés Stripe sont correctes
- Assurez-vous d'utiliser les clés de test (pk_test_ et sk_test_)

### Erreur "Payment failed"
- Vérifiez que vous utilisez une carte de test valide
- Consultez les logs Stripe pour plus de détails

### Problème de réseau
- Vérifiez votre connexion internet
- Assurez-vous que l'API Stripe est accessible

## 📚 Ressources

- [Documentation Stripe Flutter](https://stripe.com/docs/payments/flutter)
- [Cartes de test Stripe](https://stripe.com/docs/testing)
- [Dashboard Stripe](https://dashboard.stripe.com)
