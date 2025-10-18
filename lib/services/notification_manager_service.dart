import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/local_notification_models.dart';
import 'local_notification_storage_service.dart';
import 'local_notification_service.dart' as local_notification_service;

/// Service de gestion centralisée des notifications
class NotificationManagerService {
  static final NotificationManagerService _instance =
      NotificationManagerService._internal();
  factory NotificationManagerService() => _instance;
  NotificationManagerService._internal();

  final LocalNotificationStorageService _storage =
      LocalNotificationStorageService.instance;
  final local_notification_service.LocalNotificationService _localNotification =
      local_notification_service.LocalNotificationService();

  // État réactif des notifications
  final RxList<LocalNotification> _notifications = <LocalNotification>[].obs;
  final Rx<NotificationStats> _stats =
      NotificationStats(
        total: 0,
        unread: 0,
        delivery: 0,
        pickup: 0,
        urgent: 0,
        error: 0,
        success: 0,
        info: 0,
      ).obs;

  // Getters
  List<LocalNotification> get notifications => _notifications;
  NotificationStats get stats => _stats.value;
  List<LocalNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  /// Initialiser le service
  Future<void> initialize() async {
    try {
      print('🔄 ===== INITIALISATION DU NOTIFICATIONMANAGER =====');

      // Charger les notifications stockées
      await _loadStoredNotifications();

      // Configurer les handlers Firebase
      _setupFirebaseHandlers();

      print('✅ NotificationManager initialisé avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation du NotificationManager: $e');
    }
  }

  /// Charger les notifications stockées
  Future<void> _loadStoredNotifications() async {
    try {
      print('📱 ===== CHARGEMENT DES NOTIFICATIONS STOCKÉES =====');
      print('📱 Appel de _storage.getAllNotifications()...');

      final storedNotifications = await _storage.getAllNotifications();
      print(
        '📱 Notifications récupérées du stockage: ${storedNotifications.length}',
      );
      print(
        '📱 IDs des notifications stockées: ${storedNotifications.map((n) => n.id).toList()}',
      );

      _notifications.value = storedNotifications;
      print(
        '📱 Liste réactive mise à jour avec ${_notifications.length} notifications',
      );

      // Mettre à jour les statistiques
      await _updateStats();
      print('📱 Statistiques mises à jour');

      print(
        '📱 ✅ ${storedNotifications.length} notifications chargées avec succès',
      );
    } catch (e) {
      print('❌ Erreur lors du chargement des notifications stockées: $e');
    }
  }

  /// Configurer les handlers Firebase
  void _setupFirebaseHandlers() {
    print('🔄 Configuration des handlers Firebase...');

    // Message reçu au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 Message reçu au premier plan: ${message.notification?.title}');
      _handleIncomingMessage(message);
    });

    // Message reçu en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 App ouverte par notification: ${message.notification?.title}');
      _handleIncomingMessage(message);
    });

    print('✅ Handlers Firebase configurés');
  }

  /// Gérer un message entrant
  Future<void> _handleIncomingMessage(RemoteMessage message) async {
    try {
      print('📱 ===== TRAITEMENT D\'UN MESSAGE ENTRANT =====');
      print('📱 Titre: ${message.notification?.title}');
      print('📱 Corps: ${message.notification?.body}');
      print('📱 Data: ${message.data}');

      // Créer la notification locale
      final localNotification = LocalNotification.fromRemoteMessage(message);

      // Sauvegarder localement
      await _storage.saveNotification(localNotification);

      // Mettre à jour la liste réactive
      await _loadStoredNotifications();

      // Afficher la notification native
      await _localNotification.showInfoNotification(
        title: localNotification.title,
        message: localNotification.body,
      );

      print('✅ Message traité et sauvegardé');
    } catch (e) {
      print('❌ Erreur lors du traitement du message: $e');
    }
  }

  /// Ajouter une notification manuelle
  Future<bool> addNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationType? type,
    String? imageUrl,
    String? actionUrl,
  }) async {
    try {
      print('📱 Ajout d\'une notification manuelle: $title');

      final notification = LocalNotification.create(
        title: title,
        body: body,
        data: data,
        type: type,
        imageUrl: imageUrl,
        actionUrl: actionUrl,
      );

      final success = await _storage.saveNotification(notification);

      if (success) {
        await _loadStoredNotifications();
        print('✅ Notification manuelle ajoutée');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors de l\'ajout de la notification manuelle: $e');
      return false;
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      print('📱 Marquage de la notification $notificationId comme lue...');

      final success = await _storage.markAsRead(notificationId);

      if (success) {
        await _loadStoredNotifications();
        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();
        print('✅ Notification marquée comme lue');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  /// Marquer une notification comme non lue
  Future<bool> markAsUnread(String notificationId) async {
    try {
      print('📱 Marquage de la notification $notificationId comme non lue...');

      final success = await _storage.markAsUnread(notificationId);

      if (success) {
        await _loadStoredNotifications();
        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();
        print('✅ Notification marquée comme non lue');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      print('📱 Marquage de toutes les notifications comme lues...');

      final success = await _storage.markAllAsRead();

      if (success) {
        await _loadStoredNotifications();
        print('✅ Toutes les notifications marquées comme lues');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du marquage de toutes les notifications: $e');
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      print('📱 Suppression de la notification $notificationId...');
      print(
        '📱 Nombre de notifications avant suppression: ${_notifications.length}',
      );

      final success = await _storage.deleteNotification(notificationId);
      print('📱 Résultat de la suppression dans le stockage: $success');

      if (success) {
        await _loadStoredNotifications();
        print(
          '📱 Nombre de notifications après rechargement: ${_notifications.length}',
        );

        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();
        print('📱 Liste réactive rafraîchie');

        // Forcer la mise à jour des statistiques
        _updateStats();
        print('📱 Statistiques mises à jour');

        print('✅ Notification supprimée avec succès');
      } else {
        print('❌ Échec de la suppression dans le stockage');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la notification: $e');
      return false;
    }
  }

  /// Supprimer toutes les notifications
  Future<bool> deleteAllNotifications() async {
    try {
      print('📱 Suppression de toutes les notifications...');

      final success = await _storage.deleteAllNotifications();

      if (success) {
        await _loadStoredNotifications();
        print('✅ Toutes les notifications supprimées');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors de la suppression de toutes les notifications: $e');
      return false;
    }
  }

  /// Filtrer les notifications
  Future<List<LocalNotification>> filterNotifications({
    NotificationFilter filter = NotificationFilter.all,
    NotificationSort sort = NotificationSort.newest,
    int? limit,
  }) async {
    try {
      print('📱 Filtrage des notifications: $filter, tri: $sort');

      final filteredNotifications = await _storage.filterNotifications(
        filter: filter,
        sort: sort,
        limit: limit,
      );

      print('📱 ${filteredNotifications.length} notifications filtrées');
      return filteredNotifications;
    } catch (e) {
      print('❌ Erreur lors du filtrage des notifications: $e');
      return [];
    }
  }

  /// Rechercher des notifications
  Future<List<LocalNotification>> searchNotifications(String query) async {
    try {
      print('📱 Recherche de notifications: "$query"');

      final results = await _storage.searchNotifications(query);

      print('📱 ${results.length} notifications trouvées');
      return results;
    } catch (e) {
      print('❌ Erreur lors de la recherche de notifications: $e');
      return [];
    }
  }

  /// Obtenir les statistiques
  Future<NotificationStats> getStats() async {
    try {
      print('📱 Calcul des statistiques...');

      final stats = await _storage.getStats();
      _stats.value = stats;

      print('📱 Statistiques: ${stats.total} total, ${stats.unread} non lues');
      return stats;
    } catch (e) {
      print('❌ Erreur lors du calcul des statistiques: $e');
      return _stats.value;
    }
  }

  /// Mettre à jour les statistiques
  Future<void> _updateStats() async {
    try {
      final stats = NotificationStats.fromNotifications(_notifications);
      _stats.value = stats;
    } catch (e) {
      print('❌ Erreur lors de la mise à jour des statistiques: $e');
    }
  }

  /// Nettoyer les données anciennes
  Future<bool> cleanupOldNotifications({int daysOld = 30}) async {
    try {
      print(
        '📱 Nettoyage des notifications anciennes (plus de $daysOld jours)...',
      );

      final success = await _storage.deleteOldNotifications(daysOld: daysOld);

      if (success) {
        await _loadStoredNotifications();
        print('✅ Nettoyage terminé');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du nettoyage des notifications anciennes: $e');
      return false;
    }
  }

  /// Nettoyer les données corrompues
  Future<bool> cleanupCorruptedData() async {
    try {
      print('📱 Nettoyage des données corrompues...');

      final success = await _storage.cleanupCorruptedData();

      if (success) {
        await _loadStoredNotifications();
        print('✅ Nettoyage des données corrompues terminé');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors du nettoyage des données corrompues: $e');
      return false;
    }
  }

  /// Définir le nombre maximum de notifications
  Future<bool> setMaxNotifications(int max) async {
    try {
      print('📱 Définition du nombre maximum de notifications: $max');

      final success = await _storage.setMaxNotifications(max);

      if (success) {
        await _loadStoredNotifications();
        print('✅ Nombre maximum de notifications défini');
      }

      return success;
    } catch (e) {
      print('❌ Erreur lors de la définition du nombre maximum: $e');
      return false;
    }
  }

  /// Rafraîchir les notifications
  Future<void> refreshNotifications() async {
    try {
      print('📱 ===== RAFRAÎCHISSEMENT DES NOTIFICATIONS =====');
      print(
        '📱 État actuel de la liste réactive: ${_notifications.length} notifications',
      );
      await _loadStoredNotifications();
      print(
        '📱 État final de la liste réactive: ${_notifications.length} notifications',
      );
      print('✅ Notifications rafraîchies avec succès');
    } catch (e) {
      print('❌ Erreur lors du rafraîchissement des notifications: $e');
    }
  }

  /// Obtenir les notifications non lues
  List<LocalNotification> getUnreadNotifications() {
    return _notifications.where((n) => !n.isRead).toList();
  }

  /// Obtenir les notifications par type
  List<LocalNotification> getNotificationsByType(NotificationType type) {
    return _notifications.where((n) => n.type == type).toList();
  }

  /// Obtenir le nombre de notifications non lues
  int get unreadCount => _stats.value.unread;

  /// Obtenir le nombre total de notifications
  int get totalCount => _stats.value.total;

  /// Vérifier s'il y a des notifications non lues
  bool get hasUnreadNotifications => _stats.value.unread > 0;

  /// Obtenir les notifications récentes (dernières 24h)
  List<LocalNotification> getRecentNotifications() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return _notifications
        .where((n) => n.receivedAt.isAfter(yesterday))
        .toList();
  }

  /// Obtenir les notifications urgentes
  List<LocalNotification> getUrgentNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.urgent)
        .toList();
  }

  /// Obtenir les notifications d'erreur
  List<LocalNotification> getErrorNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.error)
        .toList();
  }

  /// Obtenir les notifications de succès
  List<LocalNotification> getSuccessNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.success)
        .toList();
  }

  /// Obtenir les notifications de livraison
  List<LocalNotification> getDeliveryNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.delivery)
        .toList();
  }

  /// Obtenir les notifications de ramassage
  List<LocalNotification> getPickupNotifications() {
    return _notifications
        .where((n) => n.type == NotificationType.pickup)
        .toList();
  }
}
