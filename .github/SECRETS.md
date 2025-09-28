# Configuration des Secrets GitHub

Ce document décrit les secrets GitHub nécessaires pour le déploiement automatique.

## Secrets Requis

### 1. FIREBASE_TOKEN
**Description:** Token d'authentification Firebase pour GitHub Actions
**Comment l'obtenir:**
```bash
# Installer Firebase CLI
npm install -g firebase-tools

# Se connecter
firebase login

# Générer un token
firebase login:ci
```

**Configuration GitHub:**
1. Aller dans Settings > Secrets and variables > Actions
2. Cliquer sur "New repository secret"
3. Nom: `FIREBASE_TOKEN`
4. Valeur: Le token généré par `firebase login:ci`

### 2. FIREBASE_PROJECT_ID
**Description:** ID du projet Firebase
**Valeur:** `shopflutter-d3308`

**Configuration GitHub:**
1. Aller dans Settings > Secrets and variables > Actions
2. Cliquer sur "New repository secret"
3. Nom: `FIREBASE_PROJECT_ID`
4. Valeur: `shopflutter-d3308`

### 3. FIREBASE_SERVICE_ACCOUNT (Optionnel)
**Description:** Clé de service Firebase pour l'authentification avancée
**Comment l'obtenir:**
1. Aller dans Firebase Console > Project Settings > Service Accounts
2. Cliquer sur "Generate new private key"
3. Télécharger le fichier JSON

**Configuration GitHub:**
1. Aller dans Settings > Secrets and variables > Actions
2. Cliquer sur "New repository secret"
3. Nom: `FIREBASE_SERVICE_ACCOUNT`
4. Valeur: Contenu du fichier JSON (formaté en une seule ligne)

## Variables d'Environnement Locales

Créez un fichier `.env` à la racine du projet :

```env
# Firebase
FIREBASE_PROJECT_ID=shopflutter-d3308
FIREBASE_API_KEY=your_api_key_here
FIREBASE_AUTH_DOMAIN=shopflutter-d3308.firebaseapp.com

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...

# Google Sign-In
GOOGLE_CLIENT_ID=your_google_client_id_here
```

## Vérification de la Configuration

### Test Local
```bash
# Vérifier la connexion Firebase
firebase projects:list

# Tester le déploiement (dry-run)
./scripts/deploy-blue-green.sh --dry-run
```

### Test GitHub Actions
1. Créer une branche de test
2. Faire un push
3. Vérifier dans l'onglet "Actions" que le workflow s'exécute correctement

## Dépannage

### Erreur: "Firebase project not found"
- Vérifier que `FIREBASE_PROJECT_ID` est correct
- Vérifier que le token `FIREBASE_TOKEN` est valide

### Erreur: "Permission denied"
- Vérifier que le token Firebase a les permissions nécessaires
- Régénérer le token si nécessaire

### Erreur: "Build failed"
- Vérifier que tous les tests passent localement
- Vérifier que la couverture de code est >= 50%

## Sécurité

⚠️ **Important:**
- Ne jamais commiter les fichiers `.env` ou les clés de service
- Utiliser uniquement les secrets GitHub pour les variables sensibles
- Régénérer les tokens régulièrement
- Limiter les permissions des tokens au minimum nécessaire
