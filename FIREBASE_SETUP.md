# Configuration Firebase - Moyoo Fleet Delivery App

## 📋 Informations du projet Firebase

- **Nom du projet** : Moyoo Fleet
- **ID du projet** : moyoo-fleet
- **Numéro du projet** : 319265524393
- **ID de l'application Android** : 1:319265524393:android:e0b7d1f9ceccc67ab277b8
- **Nom du package** : com.moyoofleet.delivery_app

## 🔧 Configuration effectuée

### 1. Fichiers de configuration
- ✅ `android/app/google-services.json` - Configuration Firebase Android
- ✅ `lib/firebase_options.dart` - Options Firebase pour Flutter
- ✅ `android/app/build.gradle.kts` - Plugin Google Services ajouté
- ✅ `android/build.gradle.kts` - Classpath Google Services ajouté

### 2. Permissions Android
- ✅ `android.permission.INTERNET`
- ✅ `android.permission.WAKE_LOCK`
- ✅ `com.google.android.c2dm.permission.RECEIVE`

### 3. Configuration Gradle
- ✅ **build.gradle.kts (projet)** : Repositories et classpath Google Services
- ✅ **build.gradle.kts (app)** : Plugin Google Services appliqué

### 4. Services Firebase
- ✅ Firebase Messaging Service configuré
- ✅ Canal de notification par défaut : `high_importance_channel`
- ✅ Icône de notification par défaut : `@mipmap/ic_launcher`
- ✅ Couleur de notification : `@color/colorAccent`

### 5. Configuration de l'application
- ✅ Application ID : `com.moyoofleet.delivery_app`
- ✅ Nom de l'application : "Moyoo Fleet Delivery"
- ✅ Namespace : `com.moyoofleet.delivery_app`

## 🚀 Fonctionnalités implémentées

### Notifications Push
- ✅ Initialisation automatique de Firebase
- ✅ Demande des permissions de notification
- ✅ Obtention du token FCM
- ✅ Enregistrement du token sur le serveur
- ✅ Gestion des messages en arrière-plan et premier plan
- ✅ Système de fallback avec token simulé

### API Integration
- ✅ Endpoint : `POST /api/livreur/fcm-token`
- ✅ Détection automatique du type de device (iOS/Android)
- ✅ Enregistrement conditionnel (uniquement après login)

## 📱 Test des notifications

### 1. Vérification de l'initialisation
```
✅ Firebase initialisé avec succès
📱 Canaux de notification configurés
🔔 Permissions de notification: AuthorizationStatus.authorized
🔑 Token FCM obtenu: [token]
✅ NotificationService initialisé avec succès
```

### 2. Enregistrement du token
```
🔄 Enregistrement du token FCM sur le serveur...
🔍 FCM Service - Status: 200
✅ Token FCM enregistré avec succès
```

## 🔄 Prochaines étapes

### Pour la production
1. **Configuration iOS** : Ajouter le fichier `GoogleService-Info.plist`
2. **Certificats iOS** : Configurer les certificats de notification push
3. **Tests en production** : Vérifier les notifications push réelles
4. **Monitoring** : Surveiller les erreurs de notification

### Pour les notifications personnalisées
1. **Canaux Android** : Implémenter des canaux de notification personnalisés
2. **Actions de notification** : Ajouter des boutons d'action
3. **Navigation** : Améliorer la navigation selon le type de notification
4. **Badges** : Gérer les badges de notification

## 🛠️ Dépannage

### Erreurs courantes

#### **Erreur de build Gradle**
```
Cannot resolve external dependency com.google.gms:google-services:4.4.0 because no repositories are defined
```
**Solution** : Ajouter les repositories dans le bloc `buildscript` du fichier `android/build.gradle.kts` :
```kotlin
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}
```

#### **Erreur de version NDK**
```
firebase_core requires Android NDK 27.0.12077973
```
**Solution** : Mettre à jour la version NDK dans `android/app/build.gradle.kts` :
```kotlin
android {
    ndkVersion = "27.0.12077973"
    ...
}
```

#### **Erreur MainActivity non trouvée**
```
ClassNotFoundException: Didn't find class "com.moyoofleet.delivery_app.MainActivity"
```
**Solution** : Créer le fichier MainActivity avec le bon package name :
```kotlin
// android/app/src/main/kotlin/com/moyoofleet/delivery_app/MainActivity.kt
package com.moyoofleet.delivery_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity()
```

#### **Erreur Core Library Desugaring**
```
Dependency ':flutter_local_notifications' requires core library desugaring to be enabled
```
**Solution** : Activer le core library desugaring dans `android/app/build.gradle.kts` :
```kotlin
android {
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true  // ← Ajouter cette ligne
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")  // ← Ajouter cette dépendance
}
```

#### **Configuration du son des notifications**
Pour activer le son des notifications, ajouter dans `AndroidManifest.xml` :
```xml
<!-- Firebase Messaging default notification sound -->
<meta-data
    android:name="com.google.firebase.messaging.default_notification_sound"
    android:value="default" />
```

#### **Notifications natives avec flutter_local_notifications**
Pour afficher des notifications natives même en premier plan :
```dart
// Dans pubspec.yaml
flutter_local_notifications: ^17.2.3

// Configuration des canaux Android
const androidChannel = AndroidNotificationChannel(
  'high_importance_channel',
  'Notifications importantes',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);
```

#### **Erreur XML des canaux de notification**
```
Failed to flatten XML for resource 'default_channel_description' with error: Invalid unicode escape sequence
```
**Solution** : Supprimer le fichier `android/app/src/main/res/values/notification_channels.xml` car il n'est pas nécessaire. Le plugin `flutter_local_notifications` gère les canaux directement dans le code Dart.

#### **Actualisation transparente des listes**
Les notifications Firebase déclenchent automatiquement l'actualisation des listes :
```dart
// Détection automatique du type de notification
if (title.toLowerCase().contains('ramassage')) {
  _refreshRamassageLists(); // Actualise dashboard, liste et détails
}

if (title.toLowerCase().contains('livraison')) {
  _refreshDeliveryLists(); // Actualise les livraisons
}
```

#### **Autres erreurs courantes**
- **Firebase non initialisé** : Vérifier que `Firebase.initializeApp()` est appelé
- **Token FCM non disponible** : Vérifier les permissions de notification
- **Échec d'enregistrement** : Vérifier la connectivité et l'authentification
- **Pas de son** : Vérifier que `sound: true` est activé dans les permissions

### Logs de debug
- Tous les logs commencent par des emojis pour faciliter le filtrage
- 🔄 = Processus en cours
- ✅ = Succès
- ❌ = Erreur
- 🔍 = Debug/Information
- 📱 = Notification/Device
- 🔑 = Token/Authentification
