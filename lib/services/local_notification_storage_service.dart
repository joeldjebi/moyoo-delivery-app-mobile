import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/local_notification_models.dart';

/// Service de stockage local des notifications
class LocalNotificationStorageService {
  static const String _notificationsKey = 'local_notifications';
  static const String _maxNotificationsKey = 'max_notifications';
  static const int _defaultMaxNotifications = 1000;

  static LocalNotificationStorageService? _instance;
  static LocalNotificationStorageService get instance {
    _instance ??= LocalNotificationStorageService._();
    return _instance!;
  }

  LocalNotificationStorageService._();

  /// Obtenir toutes les notifications stockées
  Future<List<LocalNotification>> getAllNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final notifications =
          notificationsJson
              .map((json) => LocalNotification.fromMap(jsonDecode(json)))
              .toList();

      // Trier par date de réception (plus récentes en premier)
      notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

      return notifications;
    } catch (e) {
      return [];
    }
  }

  /// Sauvegarder une notification
  Future<bool> saveNotification(LocalNotification notification) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingNotifications = await getAllNotifications();

      // Vérifier si la notification existe déjà
      final existingIndex = existingNotifications.indexWhere(
        (n) => n.id == notification.id,
      );

      if (existingIndex != -1) {
        // Mettre à jour la notification existante
        existingNotifications[existingIndex] = notification;
      } else {
        // Ajouter la nouvelle notification
        existingNotifications.insert(0, notification);
      }

      // Limiter le nombre de notifications stockées
      final maxNotifications = await _getMaxNotifications();
      if (existingNotifications.length > maxNotifications) {
        existingNotifications.removeRange(
          maxNotifications,
          existingNotifications.length,
        );
      }

      // Sauvegarder
      final notificationsJson =
          existingNotifications.map((n) => jsonEncode(n.toMap())).toList();

      await prefs.setStringList(_notificationsKey, notificationsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Sauvegarder plusieurs notifications
  Future<bool> saveNotifications(List<LocalNotification> notifications) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingNotifications = await getAllNotifications();

      // Fusionner les notifications
      for (final notification in notifications) {
        final existingIndex = existingNotifications.indexWhere(
          (n) => n.id == notification.id,
        );

        if (existingIndex != -1) {
          existingNotifications[existingIndex] = notification;
        } else {
          existingNotifications.insert(0, notification);
        }
      }

      // Limiter le nombre de notifications stockées
      final maxNotifications = await _getMaxNotifications();
      if (existingNotifications.length > maxNotifications) {
        existingNotifications.removeRange(
          maxNotifications,
          existingNotifications.length,
        );
      }

      // Sauvegarder
      final notificationsJson =
          existingNotifications.map((n) => jsonEncode(n.toMap())).toList();

      await prefs.setStringList(_notificationsKey, notificationsJson);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Marquer une notification comme lue
  Future<bool> markAsRead(String notificationId) async {
    try {
      print('📱 Marquage de la notification $notificationId comme lue...');

      final notifications = await getAllNotifications();
      final notificationIndex = notifications.indexWhere(
        (n) => n.id == notificationId,
      );

      if (notificationIndex != -1) {
        notifications[notificationIndex] =
            notifications[notificationIndex].markAsRead();
        await saveNotifications(notifications);
        print('✅ Notification marquée comme lue');
        return true;
      } else {
        print('⚠️ Notification non trouvée');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  /// Marquer une notification comme non lue
  Future<bool> markAsUnread(String notificationId) async {
    try {
      print('📱 Marquage de la notification $notificationId comme non lue...');

      final notifications = await getAllNotifications();
      final notificationIndex = notifications.indexWhere(
        (n) => n.id == notificationId,
      );

      if (notificationIndex != -1) {
        notifications[notificationIndex] =
            notifications[notificationIndex].markAsUnread();
        await saveNotifications(notifications);
        print('✅ Notification marquée comme non lue');
        return true;
      } else {
        print('⚠️ Notification non trouvée');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors du marquage de la notification: $e');
      return false;
    }
  }

  /// Marquer toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    try {
      print('📱 Marquage de toutes les notifications comme lues...');

      final notifications = await getAllNotifications();
      final updatedNotifications =
          notifications.map((n) => n.markAsRead()).toList();

      await saveNotifications(updatedNotifications);
      print('✅ Toutes les notifications marquées comme lues');
      return true;
    } catch (e) {
      print('❌ Erreur lors du marquage de toutes les notifications: $e');
      return false;
    }
  }

  /// Supprimer une notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      print('📱 Suppression de la notification $notificationId...');

      final notifications = await getAllNotifications();
      print(
        '📱 Nombre de notifications avant suppression: ${notifications.length}',
      );

      final initialCount = notifications.length;
      notifications.removeWhere((n) => n.id == notificationId);
      final finalCount = notifications.length;

      print('📱 Notifications supprimées: ${initialCount - finalCount}');
      print('📱 Nombre de notifications après suppression: $finalCount');

      await saveNotifications(notifications);
      print('✅ Notification supprimée et sauvegardée');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression de la notification: $e');
      return false;
    }
  }

  /// Supprimer toutes les notifications
  Future<bool> deleteAllNotifications() async {
    try {
      print('📱 Suppression de toutes les notifications...');

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_notificationsKey);

      print('✅ Toutes les notifications supprimées');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression de toutes les notifications: $e');
      return false;
    }
  }

  /// Supprimer les notifications anciennes
  Future<bool> deleteOldNotifications({int daysOld = 30}) async {
    try {
      print('📱 Suppression des notifications de plus de $daysOld jours...');

      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final notifications = await getAllNotifications();
      final filteredNotifications =
          notifications.where((n) => n.receivedAt.isAfter(cutoffDate)).toList();

      await saveNotifications(filteredNotifications);

      final deletedCount = notifications.length - filteredNotifications.length;
      print('✅ $deletedCount notifications anciennes supprimées');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la suppression des notifications anciennes: $e');
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

      List<LocalNotification> notifications = await getAllNotifications();

      // Appliquer le filtre
      switch (filter) {
        case NotificationFilter.all:
          break;
        case NotificationFilter.unread:
          notifications = notifications.where((n) => !n.isRead).toList();
          break;
        case NotificationFilter.delivery:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.delivery)
                  .toList();
          break;
        case NotificationFilter.pickup:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.pickup)
                  .toList();
          break;
        case NotificationFilter.urgent:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.urgent)
                  .toList();
          break;
        case NotificationFilter.error:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.error)
                  .toList();
          break;
        case NotificationFilter.success:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.success)
                  .toList();
          break;
        case NotificationFilter.info:
          notifications =
              notifications
                  .where((n) => n.type == NotificationType.info)
                  .toList();
          break;
      }

      // Appliquer le tri
      switch (sort) {
        case NotificationSort.newest:
          notifications.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
          break;
        case NotificationSort.oldest:
          notifications.sort((a, b) => a.receivedAt.compareTo(b.receivedAt));
          break;
        case NotificationSort.unreadFirst:
          notifications.sort((a, b) {
            if (a.isRead == b.isRead) {
              return b.receivedAt.compareTo(a.receivedAt);
            }
            return a.isRead ? 1 : -1;
          });
          break;
        case NotificationSort.type:
          notifications.sort((a, b) {
            final typeComparison = a.type.name.compareTo(b.type.name);
            if (typeComparison == 0) {
              return b.receivedAt.compareTo(a.receivedAt);
            }
            return typeComparison;
          });
          break;
      }

      // Appliquer la limite
      if (limit != null && limit > 0) {
        notifications = notifications.take(limit).toList();
      }

      print('📱 ${notifications.length} notifications filtrées');
      return notifications;
    } catch (e) {
      print('❌ Erreur lors du filtrage des notifications: $e');
      return [];
    }
  }

  /// Obtenir les statistiques des notifications
  Future<NotificationStats> getStats() async {
    try {
      print('📱 Calcul des statistiques des notifications...');

      final notifications = await getAllNotifications();
      final stats = NotificationStats.fromNotifications(notifications);

      print('📱 Statistiques: ${stats.total} total, ${stats.unread} non lues');
      return stats;
    } catch (e) {
      print('❌ Erreur lors du calcul des statistiques: $e');
      return NotificationStats(
        total: 0,
        unread: 0,
        delivery: 0,
        pickup: 0,
        urgent: 0,
        error: 0,
        success: 0,
        info: 0,
      );
    }
  }

  /// Obtenir le nombre maximum de notifications stockées
  Future<int> _getMaxNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_maxNotificationsKey) ?? _defaultMaxNotifications;
    } catch (e) {
      return _defaultMaxNotifications;
    }
  }

  /// Définir le nombre maximum de notifications stockées
  Future<bool> setMaxNotifications(int max) async {
    try {
      print('📱 Définition du nombre maximum de notifications: $max');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_maxNotificationsKey, max);

      // Appliquer la limite immédiatement
      final notifications = await getAllNotifications();
      if (notifications.length > max) {
        final limitedNotifications = notifications.take(max).toList();
        await saveNotifications(limitedNotifications);
        print('📱 Notifications limitées à $max');
      }

      print('✅ Nombre maximum de notifications défini');
      return true;
    } catch (e) {
      print('❌ Erreur lors de la définition du nombre maximum: $e');
      return false;
    }
  }

  /// Rechercher des notifications
  Future<List<LocalNotification>> searchNotifications(String query) async {
    try {
      print('📱 Recherche de notifications: "$query"');

      final notifications = await getAllNotifications();
      final lowercaseQuery = query.toLowerCase();

      final results =
          notifications.where((n) {
            return n.title.toLowerCase().contains(lowercaseQuery) ||
                n.body.toLowerCase().contains(lowercaseQuery) ||
                n.data.values.any(
                  (value) =>
                      value.toString().toLowerCase().contains(lowercaseQuery),
                );
          }).toList();

      print('📱 ${results.length} notifications trouvées');
      return results;
    } catch (e) {
      print('❌ Erreur lors de la recherche de notifications: $e');
      return [];
    }
  }

  /// Obtenir les notifications non lues
  Future<List<LocalNotification>> getUnreadNotifications() async {
    return await filterNotifications(filter: NotificationFilter.unread);
  }

  /// Obtenir les notifications par type
  Future<List<LocalNotification>> getNotificationsByType(
    NotificationType type,
  ) async {
    final filter = _getFilterFromType(type);
    return await filterNotifications(filter: filter);
  }

  /// Convertir un type de notification en filtre
  NotificationFilter _getFilterFromType(NotificationType type) {
    switch (type) {
      case NotificationType.delivery:
        return NotificationFilter.delivery;
      case NotificationType.pickup:
        return NotificationFilter.pickup;
      case NotificationType.urgent:
        return NotificationFilter.urgent;
      case NotificationType.error:
        return NotificationFilter.error;
      case NotificationType.success:
        return NotificationFilter.success;
      case NotificationType.info:
        return NotificationFilter.info;
    }
  }

  /// Nettoyer les données corrompues
  Future<bool> cleanupCorruptedData() async {
    try {
      print('📱 Nettoyage des données corrompues...');

      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getStringList(_notificationsKey) ?? [];

      final validNotifications = <LocalNotification>[];

      for (final json in notificationsJson) {
        try {
          final notification = LocalNotification.fromMap(jsonDecode(json));
          validNotifications.add(notification);
        } catch (e) {
          print('⚠️ Notification corrompue ignorée: $e');
        }
      }

      // Sauvegarder les notifications valides
      final validJson =
          validNotifications.map((n) => jsonEncode(n.toMap())).toList();

      await prefs.setStringList(_notificationsKey, validJson);

      final corruptedCount =
          notificationsJson.length - validNotifications.length;
      print(
        '✅ Nettoyage terminé: $corruptedCount notifications corrompues supprimées',
      );
      return true;
    } catch (e) {
      print('❌ Erreur lors du nettoyage des données: $e');
      return false;
    }
  }
}
