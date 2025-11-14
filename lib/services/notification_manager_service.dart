import 'package:get/get.dart';
import '../models/local_notification_models.dart';
import 'local_notification_storage_service.dart';

/// Service de gestion centralisée des notifications
class NotificationManagerService {
  static final NotificationManagerService _instance =
      NotificationManagerService._internal();
  factory NotificationManagerService() => _instance;
  NotificationManagerService._internal();

  final LocalNotificationStorageService _storage =
      LocalNotificationStorageService.instance;

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
      // Charger les notifications stockées
      await _loadStoredNotifications();

      // Configurer les handlers Firebase
      _setupFirebaseHandlers();
    } catch (e) {}
  }

  /// Charger les notifications stockées
  Future<void> _loadStoredNotifications() async {
    try {
      final storedNotifications = await _storage.getAllNotifications();

      _notifications.value = storedNotifications;

      // Mettre à jour les statistiques
      await _updateStats();
    } catch (e) {}
  }

  /// Configurer les handlers Firebase
  void _setupFirebaseHandlers() {}

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
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _storage.markAsRead(notificationId);

      if (success) {
        await _loadStoredNotifications();
        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Marquer une notification comme non lue
  Future<bool> markAsUnread(String notificationId) async {
    try {
      final success = await _storage.markAsUnread(notificationId);

      if (success) {
        await _loadStoredNotifications();
        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      final success = await _storage.markAllAsRead();

      if (success) {
        await _loadStoredNotifications();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _storage.deleteNotification(notificationId);

      if (success) {
        await _loadStoredNotifications();

        // Forcer la mise à jour de la liste réactive
        _notifications.refresh();

        // Forcer la mise à jour des statistiques
        _updateStats();
      } else {}

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Supprimer toutes les notifications
  Future<bool> deleteAllNotifications() async {
    try {
      final success = await _storage.deleteAllNotifications();

      if (success) {
        await _loadStoredNotifications();
      }

      return success;
    } catch (e) {
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
      final filteredNotifications = await _storage.filterNotifications(
        filter: filter,
        sort: sort,
        limit: limit,
      );

      return filteredNotifications;
    } catch (e) {
      return [];
    }
  }

  /// Rechercher des notifications
  Future<List<LocalNotification>> searchNotifications(String query) async {
    try {
      final results = await _storage.searchNotifications(query);

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Obtenir les statistiques
  Future<NotificationStats> getStats() async {
    try {
      final stats = await _storage.getStats();
      _stats.value = stats;

      return stats;
    } catch (e) {
      return _stats.value;
    }
  }

  /// Mettre à jour les statistiques
  Future<void> _updateStats() async {
    try {
      final stats = NotificationStats.fromNotifications(_notifications);
      _stats.value = stats;
    } catch (e) {}
  }

  /// Nettoyer les données anciennes
  Future<bool> cleanupOldNotifications({int daysOld = 30}) async {
    try {
      final success = await _storage.deleteOldNotifications(daysOld: daysOld);

      if (success) {
        await _loadStoredNotifications();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Nettoyer les données corrompues
  Future<bool> cleanupCorruptedData() async {
    try {
      final success = await _storage.cleanupCorruptedData();

      if (success) {
        await _loadStoredNotifications();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Définir le nombre maximum de notifications
  Future<bool> setMaxNotifications(int max) async {
    try {
      final success = await _storage.setMaxNotifications(max);

      if (success) {
        await _loadStoredNotifications();
      }

      return success;
    } catch (e) {
      return false;
    }
  }

  /// Rafraîchir les notifications
  Future<void> refreshNotifications() async {
    try {
      await _loadStoredNotifications();
    } catch (e) {}
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
