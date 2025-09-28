# 🔑 Configuration des Secrets GitHub - Guide Étape par Étape

## 🎯 Objectif
Configurer les secrets nécessaires pour que GitHub Actions puisse déployer automatiquement sur Firebase Hosting.

## 📋 Secrets Requis

### 1. FIREBASE_TOKEN
**Valeur obtenue :** `[TOKEN_GÉNÉRÉ_LOCALEMENT]`

### 2. FIREBASE_PROJECT_ID
**Valeur :** `shopflutter-d3308`

## 🚀 Instructions de Configuration

### Étape 1 : Aller dans les Settings du Repository
1. Ouvrez votre repository GitHub : `https://github.com/[VOTRE_USERNAME]/ShopFlutter`
2. Cliquez sur l'onglet **Settings** (en haut à droite)
3. Dans le menu de gauche, cliquez sur **Secrets and variables**
4. Cliquez sur **Actions**

### Étape 2 : Ajouter FIREBASE_TOKEN
1. Cliquez sur **New repository secret**
2. **Name :** `FIREBASE_TOKEN`
3. **Secret :** `[VOTRE_TOKEN_FIREBASE]`
4. Cliquez sur **Add secret**

### Étape 3 : Ajouter FIREBASE_PROJECT_ID
1. Cliquez sur **New repository secret**
2. **Name :** `FIREBASE_PROJECT_ID`
3. **Secret :** `shopflutter-d3308`
4. Cliquez sur **Add secret**

### Étape 4 : Vérification
Vous devriez maintenant voir 2 secrets configurés :
- ✅ FIREBASE_TOKEN
- ✅ FIREBASE_PROJECT_ID

## 🧪 Test de la Configuration

### Option 1 : Test via Push (Recommandé)
```bash
# Faire un petit changement et push
git add .
git commit -m "test: configuration CI/CD"
git push origin main
```

### Option 2 : Test via GitHub Actions
1. Allez dans l'onglet **Actions** de votre repository
2. Vous devriez voir le workflow "CI/CD Pipeline" en cours
3. Cliquez dessus pour voir les détails

## 🔍 Vérification du Déploiement

### URLs à Vérifier
- **Production :** https://shopflutter-d3308.web.app
- **Console Firebase :** https://console.firebase.google.com/project/shopflutter-d3308

### Logs GitHub Actions
1. Allez dans **Actions** > **CI/CD Pipeline** > [Votre commit]
2. Vérifiez que toutes les étapes passent :
   - ✅ Validation du code
   - ✅ Tests avec couverture
   - ✅ Build web
   - ✅ Déploiement

## 🚨 Dépannage

### Erreur : "Firebase project not found"
- Vérifiez que `FIREBASE_PROJECT_ID` est correct
- Vérifiez que le projet existe dans Firebase Console

### Erreur : "Permission denied"
- Vérifiez que `FIREBASE_TOKEN` est correct
- Le token peut expirer, régénérez-le si nécessaire

### Erreur : "Tests failed"
- Vérifiez que votre code passe les tests localement
- Exécutez : `scripts\validate.bat`

## 🔄 Mise à Jour des Secrets

Si vous devez régénérer le token :
```bash
firebase login:ci
```

Puis mettez à jour le secret `FIREBASE_TOKEN` dans GitHub.

## ✅ Validation Finale

Une fois configuré, votre prochain push sur `main` devrait :
1. ✅ Exécuter tous les tests
2. ✅ Build l'application web
3. ✅ Déployer automatiquement sur Firebase Hosting
4. ✅ Être accessible sur https://shopflutter-d3308.web.app

---

**🎉 Félicitations ! Votre CI/CD est maintenant configuré !**
