# Guide de Contribution - MOYOO Delivery App

Merci de votre intérêt à contribuer au projet MOYOO Delivery App ! Ce guide vous aidera à comprendre comment contribuer efficacement.

## 🚀 Démarrage Rapide

1. **Fork** le repository
2. **Clone** votre fork localement
3. **Créez** une branche feature
4. **Commitez** vos changements
5. **Poussez** vers votre fork
6. **Ouvrez** une Pull Request

## 📋 Processus de Contribution

### 1. Configuration de l'Environnement

```bash
# Cloner votre fork
git clone https://github.com/VOTRE_USERNAME/moyoo-delivery-app-mobile.git
cd moyoo-delivery-app-mobile

# Ajouter le remote upstream
git remote add upstream https://github.com/joeldjebi/moyoo-delivery-app-mobile.git

# Installer les dépendances
flutter pub get
```

### 2. Création d'une Branche

```bash
# Synchroniser avec upstream
git fetch upstream
git checkout main
git merge upstream/main

# Créer une nouvelle branche
git checkout -b feature/nom-de-votre-feature
```

### 3. Standards de Code

#### Dart/Flutter
- Suivez les [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Utilisez `dart format` pour formater votre code
- Exécutez `flutter analyze` avant de commiter

#### Commits
Utilisez des messages de commit descriptifs :
```bash
git commit -m "feat: ajouter la gestion des notifications push"
git commit -m "fix: corriger le bug de pagination"
git commit -m "docs: mettre à jour le README"
```

#### Types de Commits
- `feat:` - Nouvelle fonctionnalité
- `fix:` - Correction de bug
- `docs:` - Documentation
- `style:` - Formatage, point-virgules manquants, etc.
- `refactor:` - Refactoring de code
- `test:` - Ajout de tests
- `chore:` - Tâches de maintenance

### 4. Tests

```bash
# Exécuter tous les tests
flutter test

# Exécuter l'analyse de code
flutter analyze

# Vérifier le formatage
dart format --output=none --set-exit-if-changed .
```

### 5. Pull Request

#### Avant de Soumettre
- [ ] Code testé localement
- [ ] Tests passent
- [ ] Code formaté
- [ ] Documentation mise à jour si nécessaire
- [ ] Pas de conflits avec la branche main

#### Template de PR
```markdown
## Description
Brève description des changements

## Type de Changement
- [ ] Bug fix
- [ ] Nouvelle fonctionnalité
- [ ] Breaking change
- [ ] Documentation

## Tests
- [ ] Tests unitaires
- [ ] Tests d'intégration
- [ ] Tests manuels

## Captures d'écran (si applicable)
Ajoutez des captures d'écran pour les changements UI

## Checklist
- [ ] Mon code suit les standards du projet
- [ ] J'ai effectué une auto-review
- [ ] J'ai commenté mon code si nécessaire
- [ ] Ma documentation est à jour
```

## 🏗️ Architecture du Projet

```
lib/
├── controllers/     # Contrôleurs GetX
├── models/         # Modèles de données
├── services/       # Services API
├── screens/        # Écrans de l'application
├── widgets/        # Widgets réutilisables
├── constants/      # Constantes
└── main.dart       # Point d'entrée
```

### Conventions de Nommage

- **Fichiers** : `snake_case.dart`
- **Classes** : `PascalCase`
- **Variables/Fonctions** : `camelCase`
- **Constantes** : `UPPER_SNAKE_CASE`

## 🐛 Signaler un Bug

Utilisez le template d'issue pour les bugs :

```markdown
## Description du Bug
Description claire du problème

## Étapes pour Reproduire
1. Aller à '...'
2. Cliquer sur '....'
3. Voir l'erreur

## Comportement Attendu
Description du comportement attendu

## Captures d'écran
Si applicable, ajoutez des captures d'écran

## Environnement
- OS: [ex: iOS, Android]
- Version Flutter: [ex: 3.16.0]
- Version de l'app: [ex: 1.0.0]
```

## 💡 Proposer une Fonctionnalité

```markdown
## Description de la Fonctionnalité
Description claire de la fonctionnalité souhaitée

## Problème Résolu
Quel problème cette fonctionnalité résout-elle ?

## Solution Proposée
Description de votre solution proposée

## Alternatives Considérées
Autres solutions que vous avez considérées

## Contexte Additionnel
Tout autre contexte ou captures d'écran
```

## 📞 Support

- **Discord** : [Lien vers le serveur Discord]
- **Email** : support@moyoo.com
- **Issues GitHub** : [Créer une issue](https://github.com/joeldjebi/moyoo-delivery-app-mobile/issues)

## 📄 Licence

En contribuant, vous acceptez que vos contributions soient sous la même licence que le projet.

## 🙏 Remerciements

Merci à tous les contributeurs qui rendent ce projet possible !

---

**Happy Coding! 🚀**
