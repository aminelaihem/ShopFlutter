# 🚀 Configuration Vercel - Guide Étape par Étape

## 🎯 Objectif
Configurer Vercel pour le déploiement automatique de votre application Flutter.

## 💰 Avantages de Vercel
- ✅ **100% Gratuit** pour les projets personnels
- ✅ **Déploiement automatique** depuis GitHub
- ✅ **Performance excellente** avec CDN global
- ✅ **Preview branches** automatiques
- ✅ **Support Flutter** natif

## 🚀 Instructions de Configuration

### Étape 1 : Créer un compte Vercel
1. Allez sur [https://vercel.com](https://vercel.com)
2. Cliquez sur **"Sign Up"**
3. Connectez-vous avec votre compte GitHub
4. Autorisez Vercel à accéder à vos repositories

### Étape 2 : Importer le projet
1. Dans le dashboard Vercel, cliquez sur **"Add New..."** → **"Project"**
2. Sélectionnez votre repository **ShopFlutter**
3. Cliquez sur **"Import"**

### Étape 3 : Configuration du projet
1. **Project Name:** `shopflutter` (ou votre choix)
2. **Framework Preset:** `Other` (ou `Flutter` si disponible)
3. **Root Directory:** `/` (racine du projet)
4. **Build Command:** `flutter build web --release`
5. **Output Directory:** `build/web`
6. **Install Command:** `flutter pub get`

### Étape 4 : Variables d'environnement
Si vous avez des variables d'environnement (`.env`), ajoutez-les :
1. Dans **Environment Variables**
2. Ajoutez vos clés (Stripe, Firebase, etc.)

### Étape 5 : Déploiement
1. Cliquez sur **"Deploy"**
2. Attendez que le build se termine
3. Votre application sera disponible sur `https://shopflutter.vercel.app`

## 🔑 Configuration des Secrets GitHub

### Étape 1 : Obtenir le token Vercel
1. Allez dans [Vercel Settings](https://vercel.com/account/tokens)
2. Cliquez sur **"Create Token"**
3. Nom: `GitHub Actions`
4. Scope: `Full Account`
5. Copiez le token généré

### Étape 2 : Ajouter le secret dans GitHub
1. Allez sur votre repository GitHub
2. **Settings** → **Secrets and variables** → **Actions**
3. Cliquez sur **"New repository secret"**
4. **Name:** `VERCEL_TOKEN`
5. **Secret:** [Votre token Vercel]
6. Cliquez sur **"Add secret"**

## 🧪 Test de la Configuration

### Test Local
```bash
# Installation de Vercel CLI
npm install -g vercel

# Connexion
vercel login

# Test de déploiement
scripts\deploy-vercel.bat --dry-run
```

### Test GitHub Actions
1. Faites un push sur la branche `main`
2. Vérifiez dans l'onglet **Actions** que le workflow s'exécute
3. Votre application sera déployée automatiquement

## 🌐 URLs de Déploiement

### Production
- **URL principale:** https://shopflutter.vercel.app
- **Dashboard:** https://vercel.com/dashboard

### Preview Branches
- Chaque branche aura automatiquement une URL de preview
- Format: `https://shopflutter-git-[branch-name]-[username].vercel.app`

## 📊 Monitoring et Logs

### Dashboard Vercel
- **Analytics:** Visiteurs, performance, erreurs
- **Functions:** Logs des fonctions serverless
- **Domains:** Gestion des domaines personnalisés

### GitHub Actions
- **Logs:** https://github.com/[username]/ShopFlutter/actions
- **Status:** Vérification du statut des déploiements

## 🔧 Configuration Avancée

### Domaine personnalisé
1. Dans Vercel Dashboard → **Domains**
2. Ajoutez votre domaine
3. Configurez les DNS selon les instructions

### Variables d'environnement par environnement
1. **Production:** Variables pour la production
2. **Preview:** Variables pour les branches de test
3. **Development:** Variables pour le développement local

## 🚨 Dépannage

### Erreur: "Build failed"
- Vérifiez que `flutter build web --release` fonctionne localement
- Vérifiez les logs dans Vercel Dashboard

### Erreur: "Deployment failed"
- Vérifiez que le token `VERCEL_TOKEN` est correct
- Vérifiez les permissions GitHub Actions

### Erreur: "Environment variables missing"
- Ajoutez les variables manquantes dans Vercel Dashboard
- Vérifiez que les noms correspondent exactement

## ✅ Validation Finale

Une fois configuré, votre prochain push sur `main` devrait :
1. ✅ Exécuter tous les tests
2. ✅ Build l'application web
3. ✅ Déployer automatiquement sur Vercel
4. ✅ Être accessible sur https://shopflutter.vercel.app

---

**🎉 Félicitations ! Votre CI/CD avec Vercel est maintenant configuré !**
