# 🔌 Système de Test Socket.IO

## 📋 Vue d'ensemble

Le système de test Socket.IO permet de tester la connectivité Socket.IO directement depuis l'écran de configuration de l'application. Ce système offre une interface utilisateur intuitive pour diagnostiquer et gérer les connexions Socket.IO.

## 🚀 Fonctionnalités

### ✅ **Test de Connexion Socket.IO**
- **Test automatique** avec timeout configurable (défaut: 10 secondes)
- **Indicateur visuel** de progression pendant le test
- **Messages informatifs** sur le résultat du test
- **Mise à jour automatique** du statut de disponibilité

### 🔄 **Gestion de la Connexion**
- **Connexion manuelle** via le bouton "Tester la connexion Socket.IO"
- **Déconnexion forcée** via le bouton "Déconnecter Socket.IO"
- **Statut en temps réel** avec indicateurs visuels
- **Fallback automatique** vers l'API REST en cas d'échec

### 📊 **Interface Utilisateur**
- **Indicateurs visuels** colorés (vert/rouge) pour le statut
- **Messages de notification** détaillés
- **Mise à jour en temps réel** du statut
- **Informations de configuration** actuelles

## 🛠️ Implémentation Technique

### **Service Socket.IO (`SocketService`)**

#### **Méthode `testConnection()`**
```dart
Future<bool> testConnection({Duration timeout = const Duration(seconds: 5)})
```

**Fonctionnalités :**
- Crée une connexion de test temporaire
- Écoute les événements de connexion et d'erreur
- Timeout configurable pour éviter les blocages
- Nettoyage automatique de la connexion de test
- Retourne `true` si la connexion réussit, `false` sinon

**Paramètres :**
- `timeout` : Durée maximale d'attente (défaut: 5 secondes)

#### **Méthode `connect()`**
```dart
Future<bool> connect()
```

**Fonctionnalités :**
- Connexion principale à Socket.IO
- Authentification automatique avec le token JWT
- Gestion des erreurs de connexion
- Mise à jour du statut de connexion

#### **Méthode `disconnect()`**
```dart
void disconnect()
```

**Fonctionnalités :**
- Déconnexion propre de Socket.IO
- Nettoyage des ressources
- Mise à jour du statut

### **Écran de Configuration (`ConfigScreen`)**

#### **Méthode `_testSocketConnection()`**
```dart
void _testSocketConnection() async
```

**Fonctionnalités :**
- Affiche un dialog de chargement
- Appelle `socketService.testConnection()`
- Affiche le résultat via des notifications
- Met à jour le statut dans `ConfigService`

#### **Méthode `_disconnectSocket()`**
```dart
void _disconnectSocket()
```

**Fonctionnalités :**
- Déconnecte Socket.IO
- Met à jour le statut de disponibilité
- Affiche une notification de confirmation

## 🎯 Utilisation

### **1. Accès à l'Écran de Configuration**
1. Ouvrir l'application
2. Aller au dashboard
3. Cliquer sur l'icône ⚙️ (paramètres) dans l'AppBar
4. L'écran de configuration s'ouvre

### **2. Test de Connexion Socket.IO**
1. Dans la section "Actions"
2. Cliquer sur "Tester la connexion Socket.IO"
3. Attendre le résultat (dialog de chargement)
4. Consulter la notification de résultat

### **3. Déconnexion Socket.IO**
1. Dans la section "Actions"
2. Cliquer sur "Déconnecter Socket.IO"
3. Confirmer la déconnexion via la notification

### **4. Consultation du Statut**
- **Section Socket.IO** : Indicateur visuel du statut
- **Section Informations** : Configuration actuelle avec statut en temps réel

## 📱 Messages Utilisateur

### **✅ Connexion Réussie**
```
Test Socket.IO
✅ Connexion réussie ! Socket.IO est disponible.
```

### **❌ Connexion Échouée**
```
Test Socket.IO
❌ Échec de connexion. Socket.IO n'est pas disponible.
L'API REST sera utilisée automatiquement.
```

### **🔌 Déconnexion Réussie**
```
Socket.IO déconnecté
✅ Socket.IO a été déconnecté avec succès.
```

### **❌ Erreur de Test**
```
Erreur de test Socket.IO
❌ Erreur lors du test: [détails de l'erreur]
L'API REST sera utilisée automatiquement.
```

## 🔧 Configuration

### **URLs par Défaut**
- **API URL** : `http://192.168.1.4:8000`
- **Socket URL** : `http://192.168.1.4:3000`

### **Timeouts**
- **Test de connexion** : 10 secondes
- **Connexion principale** : 3 secondes
- **Délai d'attente** : 1 seconde

### **Indicateurs Visuels**
- **🟢 Vert** : Socket.IO disponible
- **🔴 Rouge** : Socket.IO indisponible
- **🟠 Orange** : Échec de connexion (fallback API REST)

## 🚨 Gestion des Erreurs

### **Erreurs Communes**
1. **Timeout de connexion** : Serveur Socket.IO non disponible
2. **Token manquant** : Authentification requise
3. **Erreur réseau** : Problème de connectivité
4. **Serveur indisponible** : URL incorrecte ou serveur arrêté

### **Fallback Automatique**
- Si Socket.IO échoue, l'API REST est utilisée automatiquement
- L'utilisateur est informé du changement de mode
- Aucune interruption du service de géolocalisation

## 📊 Diagnostic

### **Informations Affichées**
- Statut de connexion Socket.IO
- URLs de configuration
- Dernière mise à jour du statut
- Mode de communication actuel (Socket.IO ou API REST)

### **Rapport de Diagnostic**
- Utiliser le bouton "Diagnostic complet" pour un rapport détaillé
- Analyse de la connectivité réseau
- Vérification des permissions GPS
- État des services de l'application

## 🔄 Workflow de Test

```mermaid
graph TD
    A[Utilisateur clique sur "Tester Socket.IO"] --> B[Dialog de chargement]
    B --> C[Appel testConnection()]
    C --> D{Connexion réussie?}
    D -->|Oui| E[Notification: Succès]
    D -->|Non| F[Notification: Échec]
    E --> G[Mise à jour statut: Disponible]
    F --> H[Mise à jour statut: Indisponible]
    G --> I[Fallback vers API REST]
    H --> I
    I --> J[Interface mise à jour]
```

## 🎯 Avantages

### **Pour l'Utilisateur**
- **Interface intuitive** pour tester Socket.IO
- **Messages clairs** sur le statut de connexion
- **Pas d'interruption** du service de géolocalisation
- **Fallback transparent** vers l'API REST

### **Pour le Développeur**
- **Diagnostic facile** des problèmes de connexion
- **Gestion robuste** des erreurs
- **Logs détaillés** pour le debugging
- **Configuration flexible** des timeouts

## 🚀 Prochaines Améliorations

### **Fonctionnalités Futures**
- [ ] Test de ping Socket.IO
- [ ] Historique des tests de connexion
- [ ] Configuration avancée des timeouts
- [ ] Monitoring en temps réel de la connexion
- [ ] Notifications push pour les changements de statut

### **Optimisations**
- [ ] Cache des résultats de test
- [ ] Test automatique périodique
- [ ] Reconnexion automatique
- [ ] Métriques de performance

---

## 📞 Support

En cas de problème avec le système de test Socket.IO :

1. **Vérifier la connectivité réseau**
2. **Consulter le diagnostic complet**
3. **Vérifier les URLs de configuration**
4. **Redémarrer l'application si nécessaire**

Le système est conçu pour être **robuste** et **fiable**, avec un fallback automatique vers l'API REST en cas de problème avec Socket.IO.
