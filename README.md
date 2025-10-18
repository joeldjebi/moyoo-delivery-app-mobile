# MOYOO Delivery App Mobile

Application mobile Flutter pour les livreurs de la plateforme MOYOO.

## 📱 Description

Cette application permet aux livreurs de gérer leurs livraisons et ramassages de manière efficace. Elle offre une interface intuitive pour :

- 📦 Gérer les livraisons (démarrer, terminer, annuler)
- 🚚 Gérer les ramassages (démarrer, finaliser, annuler)
- 📊 Consulter les statistiques de performance
- 🔔 Recevoir des notifications en temps réel
- 🔐 Gestion sécurisée des comptes utilisateurs

## 🚀 Fonctionnalités

### Livraisons
- Liste des colis assignés avec pagination
- Détails complets de chaque livraison
- Démarrage, finalisation et annulation des livraisons
- Gestion des photos de preuve et signatures
- Validation par code de livraison

### Ramassages
- Liste des ramassages avec filtres avancés
- Détails des ramassages avec informations client
- Démarrage, finalisation et annulation des ramassages
- Gestion des photos de preuve
- Validation par code de ramassage

### Authentification
- Connexion sécurisée avec token JWT
- Mot de passe oublié avec OTP
- Changement de mot de passe
- Gestion des sessions

### Notifications
- Notifications locales pour les actions
- Notifications push Firebase
- Gestion des notifications en arrière-plan

## 🛠️ Technologies

- **Flutter** - Framework de développement mobile
- **GetX** - Gestion d'état et navigation
- **HTTP** - Communication avec l'API
- **SharedPreferences** - Stockage local
- **Firebase** - Notifications push
- **Google Fonts** - Typographie

## 📋 Prérequis

- Flutter SDK (version 3.0+)
- Dart SDK (version 3.0+)
- Android Studio / Xcode
- Compte Firebase configuré

## 🔧 Installation

1. Cloner le repository :
```bash
git clone https://github.com/joeldjebi/moyoo-delivery-app-mobile.git
cd moyoo-delivery-app-mobile
```

2. Installer les dépendances :
```bash
flutter pub get
```

3. Configurer Firebase :
   - Ajouter `google-services.json` dans `android/app/`
   - Ajouter `GoogleService-Info.plist` dans `ios/Runner/`

4. Lancer l'application :
```bash
flutter run
```

## 📱 Captures d'écran

*À ajouter*

## 🏗️ Architecture

L'application suit une architecture MVC avec GetX :

```
lib/
├── controllers/     # Contrôleurs GetX
├── models/         # Modèles de données
├── services/       # Services API et utilitaires
├── screens/        # Écrans de l'application
├── widgets/        # Widgets réutilisables
├── constants/      # Constantes et configurations
└── main.dart       # Point d'entrée
```

## 🔐 Configuration

### Variables d'environnement
Créer un fichier `.env` avec :
```
API_BASE_URL=https://your-api-url.com
FIREBASE_PROJECT_ID=your-project-id
```

### Configuration API
Modifier `lib/constants/api_constants.dart` avec vos endpoints.

## 🚀 Déploiement

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## 📝 Changelog

### Version 1.0.0
- ✅ Authentification complète
- ✅ Gestion des livraisons
- ✅ Gestion des ramassages
- ✅ Notifications locales et push
- ✅ Interface utilisateur moderne
- ✅ Gestion des erreurs avancée

## 🤝 Contribution

1. Fork le projet
2. Créer une branche feature (`git checkout -b feature/AmazingFeature`)
3. Commit les changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 👥 Équipe

- **Joel Dje-Bi** - Développement principal
- **MOYOO Team** - Design et tests

## 📞 Support

Pour toute question ou support, contactez :
- Email : support@moyoo.com
- GitHub Issues : [Créer une issue](https://github.com/joeldjebi/moyoo-delivery-app-mobile/issues)

---

Développé avec ❤️ par l'équipe MOYOO