# 🛍️ ShopFlutter

Une application e-commerce moderne développée avec Flutter, utilisant Firebase pour l'authentification et l'hébergement.

## 🚀 Déploiement

### Application Web Live
🌐 **URL de production:** [https://shopflutter.vercel.app](https://shopflutter.vercel.app)

### Environnements
- **Production:** [https://shopflutter.vercel.app](https://shopflutter.vercel.app)
- **Preview Branches:** [https://vercel.com/aminelaihem/shopflutter](https://vercel.com/aminelaihem/shopflutter)
- **Dashboard Vercel:** [https://vercel.com/dashboard](https://vercel.com/dashboard)

## 🛠️ Technologies

- **Frontend:** Flutter 3.24.0
- **Backend:** Firebase (Auth, Hosting)
- **State Management:** Riverpod
- **Routing:** GoRouter
- **Paiements:** Stripe
- **Base de données:** Hive (local) + Firebase
- **CI/CD:** GitHub Actions
- **Hébergement:** Vercel (gratuit)

## 📋 Fonctionnalités

- ✅ Authentification (Email/Password + Google Sign-In)
- 🛒 Catalogue de produits
- 🛍️ Panier d'achat
- 💳 Paiements sécurisés (Stripe)
- 📱 Interface responsive
- 🌐 PWA (Progressive Web App)
- 🔄 Synchronisation en temps réel

## 🚀 Démarrage Rapide

### Prérequis
- Flutter SDK 3.24.0+
- Dart SDK 3.9.0+
- Node.js 18+ (pour Firebase CLI)
- Compte Firebase

### Installation

1. **Cloner le repository**
   ```bash
   git clone https://github.com/votre-username/shopflutter.git
   cd shopflutter
   ```

2. **Installer les dépendances**
   ```bash
   flutter pub get
   ```

3. **Configuration Vercel**
   ```bash
   # Installer Vercel CLI
   npm install -g vercel
   
   # Se connecter à Vercel
   vercel login
   
   # Configurer le projet
   vercel
   ```

4. **Variables d'environnement**
   - Copiez `.env.example` vers `.env`
   - Configurez vos clés API (Stripe, Firebase, etc.)

5. **Lancer l'application**
   ```bash
   # Mode debug
   flutter run -d chrome
   
   # Mode release
   flutter run -d chrome --release
   ```

## 🧪 Tests

### Exécuter tous les tests
```bash
flutter test --coverage
```

### Vérifier la couverture de code
```bash
./scripts/check-coverage.sh --min-coverage=50
```

### Tests d'intégration
```bash
flutter test integration_test/
```

## 🏗️ Build et Déploiement

### Build Web
```bash
# Build de production
./scripts/build-web.sh --release

# Build de debug
./scripts/build-web.sh --debug
```

### Déploiement Vercel
```bash
# Déploiement automatique
scripts\deploy-vercel.bat

# Mode dry-run (test)
scripts\deploy-vercel.bat --dry-run
```

## 🔄 CI/CD

Le projet utilise GitHub Actions pour l'intégration continue et le déploiement automatique.

### Workflow CI/CD
- ✅ **Validation du code:** Formatage + Analyse statique
- ✅ **Tests:** Tests unitaires avec couverture ≥ 50%
- ✅ **Build:** Build web automatique
- ✅ **Déploiement:** Automatique sur Vercel

### Déclencheurs
- **Push sur `main`:** Déploiement automatique en production
- **Pull Request:** Validation et tests
- **Push sur `develop`:** Tests et validation

## 📊 Monitoring

### Métriques de qualité
- **Couverture de code:** ≥ 50%
- **Tests:** 100% des tests passent
- **Performance:** Lighthouse score ≥ 90

### Logs et monitoring
- **Vercel Dashboard:** [https://vercel.com/dashboard](https://vercel.com/dashboard)
- **GitHub Actions:** [https://github.com/votre-username/shopflutter/actions](https://github.com/votre-username/shopflutter/actions)

## 🛡️ Sécurité

- ✅ Authentification sécurisée avec Firebase Auth
- ✅ Paiements sécurisés avec Stripe
- ✅ Variables d'environnement protégées
- ✅ HTTPS obligatoire en production
- ✅ Headers de sécurité configurés

## 📱 PWA

L'application est configurée comme une Progressive Web App (PWA) :
- ✅ Installation sur mobile/desktop
- ✅ Fonctionnement hors ligne (partiel)
- ✅ Notifications push (à venir)
- ✅ Manifeste web configuré

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/nouvelle-fonctionnalite`)
3. Commit vos changements (`git commit -m 'Ajouter nouvelle fonctionnalité'`)
4. Push vers la branche (`git push origin feature/nouvelle-fonctionnalite`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/votre-username/shopflutter/issues)
- **Documentation:** [Wiki du projet](https://github.com/votre-username/shopflutter/wiki)
- **Email:** support@shopflutter.com

---

**Développé avec ❤️ en Flutter**
