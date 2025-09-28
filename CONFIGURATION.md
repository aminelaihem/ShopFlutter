# Configuration de l'application

## Configuration des clés Stripe

Pour que l'application fonctionne correctement, vous devez configurer vos clés Stripe.

### Étapes de configuration :

1. **Créer le fichier .env** à la racine du projet :
   ```bash
   cp .env.example .env
   ```

2. **Remplacer les clés factices** dans le fichier `.env` par vos vraies clés Stripe :
   ```
   STRIPE_PUBLISHABLE_KEY=pk_test_votre_vraie_cle_publique
   STRIPE_SECRET_KEY=sk_test_votre_vraie_cle_secrete
   STRIPE_CURRENCY=eur
   STRIPE_COUNTRY=FR
   ```

3. **Installer les dépendances** :
   ```bash
   flutter pub get
   ```

### Sécurité

- ⚠️ **JAMAIS** commiter le fichier `.env` sur Git
- ✅ Le fichier `.env` est déjà dans `.gitignore`
- ✅ Utilisez `.env.example` comme modèle pour les autres développeurs

### Obtenir vos clés Stripe

1. Connectez-vous à votre [dashboard Stripe](https://dashboard.stripe.com/)
2. Allez dans "Développeurs" > "Clés API"
3. Copiez votre clé publique (pk_test_...) et votre clé secrète (sk_test_...)

### Test

Pour tester que la configuration fonctionne, lancez l'application :
```bash
flutter run
```

L'application devrait se lancer sans erreur et les paiements Stripe devraient fonctionner.
