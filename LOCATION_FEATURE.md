# Fonctionnalité de Géolocalisation - App Delivery

## Vue d'ensemble

Cette fonctionnalité permet de suivre la position du livreur en temps réel et d'envoyer automatiquement les coordonnées GPS au serveur pour le suivi des livraisons.

## Fonctionnalités implémentées

### 1. Service de Géolocalisation (`LocationService`)
- **Récupération de position** : Obtient la position actuelle du livreur
- **Suivi en temps réel** : Stream de position avec mise à jour automatique
- **Gestion des permissions** : Vérification et demande des permissions de localisation
- **Calcul de distance** : Fonctions utilitaires pour calculer les distances
- **Gestion d'erreurs** : Gestion robuste des erreurs de géolocalisation

### 2. Contrôleur de Localisation (`LocationController`)
- **Suivi automatique** : Démarre/arrête le suivi selon l'état des livraisons
- **Envoi périodique** : Envoie la position au serveur toutes les 30 secondes
- **Historique local** : Maintient un historique des 100 dernières positions
- **Gestion d'état** : Suivi de l'état de la localisation et des erreurs

### 3. Service API (`LocationApiService`)
- **Envoi de position** : Envoie les coordonnées au serveur avec retry automatique
- **Historique serveur** : Récupère l'historique des positions depuis le serveur
- **Statut de localisation** : Met à jour le statut (actif/inactif/pause)

### 4. Interface Utilisateur
- **Widget de localisation** : Affiche la position actuelle et le statut
- **Écran d'historique** : Liste complète des positions avec détails
- **Intégration dashboard** : Widget compact dans le tableau de bord

## Configuration

### Permissions Android (déjà configurées)
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

### Permissions iOS (ajoutées)
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Cette application a besoin d'accéder à votre position pour suivre les livraisons en temps réel.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Cette application a besoin d'accéder à votre position pour suivre les livraisons en temps réel, même en arrière-plan.</string>
```

## Endpoints API

### Mise à jour de position
```
POST /api/livreur/location/update
Content-Type: application/json
Authorization: Bearer {token}

{
  "livreur_id": 1,
  "latitude": 48.8566,
  "longitude": 2.3522,
  "accuracy": 5.0,
  "speed": 12.5,
  "heading": 45.0,
  "timestamp": "2024-01-15T10:30:00Z",
  "status": "en_cours"
}
```

### Historique des positions
```
GET /api/livreur/location/history?start_date=2024-01-01&end_date=2024-01-15&limit=100
Authorization: Bearer {token}
```

### Statut de localisation
```
POST /api/livreur/location/status
Content-Type: application/json
Authorization: Bearer {token}

{
  "status": "active",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

## Utilisation

### Démarrage automatique
Le suivi de localisation démarre automatiquement quand :
- Une livraison est démarrée
- Le livreur se connecte à l'application

### Arrêt automatique
Le suivi s'arrête automatiquement quand :
- Une livraison est terminée
- Le livreur se déconnecte
- L'application est fermée

### Contrôle manuel
Le livreur peut :
- Démarrer/arrêter le suivi manuellement
- Forcer l'envoi de la position actuelle
- Consulter l'historique des positions

## Modèles de données

### LocationData
```dart
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String? address;
}
```

### LocationUpdateRequest
```dart
class LocationUpdateRequest {
  final int livreurId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String? status;
}
```

## Configuration du serveur

Le serveur doit implémenter les endpoints suivants :

1. **POST /api/livreur/location/update** : Recevoir les positions
2. **GET /api/livreur/location/history** : Retourner l'historique
3. **POST /api/livreur/location/status** : Mettre à jour le statut

## Sécurité

- **Authentification** : Tous les appels API nécessitent un token Bearer
- **Validation** : Validation des coordonnées côté serveur
- **Rate limiting** : Limitation des envois à 1 toutes les 30 secondes
- **Retry logic** : Retry automatique en cas d'échec (max 3 tentatives)

## Performance

- **Optimisation batterie** : Mise à jour uniquement si déplacement > 10m
- **Cache local** : Historique limité à 100 positions
- **Envoi asynchrone** : Envoi en arrière-plan sans bloquer l'UI
- **Gestion mémoire** : Nettoyage automatique de l'historique ancien

## Dépannage

### Problèmes courants

1. **Position non disponible**
   - Vérifier les permissions de localisation
   - S'assurer que le GPS est activé
   - Vérifier la connexion internet

2. **Erreur d'envoi API**
   - Vérifier la connexion internet
   - Vérifier le token d'authentification
   - Consulter les logs pour plus de détails

3. **Batterie qui se décharge rapidement**
   - Réduire la fréquence de mise à jour
   - Augmenter le seuil de distance minimum
   - Vérifier les paramètres de localisation du système

### Logs utiles
- `📍` : Messages de géolocalisation
- `🌐` : Messages d'API
- `❌` : Messages d'erreur
- `✅` : Messages de succès

## Évolutions futures

- [ ] Géocodage inverse pour obtenir les adresses
- [ ] Calcul d'itinéraire optimisé
- [ ] Notifications de proximité
- [ ] Mode hors ligne avec synchronisation
- [ ] Analytics de performance de livraison
- [ ] Intégration avec des cartes (Google Maps, OpenStreetMap)
