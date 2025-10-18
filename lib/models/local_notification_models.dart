import 'package:firebase_messaging/firebase_messaging.dart';

/// Modèle pour une notification locale stockée
class LocalNotification {
  final String id;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime receivedAt;
  final bool isRead;
  final NotificationType type;
  final String? imageUrl;
  final String? actionUrl;

  LocalNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.data,
    required this.receivedAt,
    this.isRead = false,
    required this.type,
    this.imageUrl,
    this.actionUrl,
  });

  /// Créer une notification locale à partir d'un RemoteMessage
  factory LocalNotification.fromRemoteMessage(RemoteMessage message) {
    return LocalNotification(
      id: message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: message.notification?.title ?? 'Notification',
      body: message.notification?.body ?? 'Nouveau message',
      data: message.data,
      receivedAt: DateTime.now(),
      type: _determineNotificationType(message),
      imageUrl:
          message.notification?.android?.imageUrl ??
          message.notification?.apple?.imageUrl,
    );
  }

  /// Créer une notification locale manuelle
  factory LocalNotification.create({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    NotificationType? type,
    String? imageUrl,
    String? actionUrl,
  }) {
    return LocalNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      data: data ?? {},
      receivedAt: DateTime.now(),
      type: type ?? NotificationType.info,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  /// Déterminer le type de notification à partir du message
  static NotificationType _determineNotificationType(RemoteMessage message) {
    final title = message.notification?.title?.toLowerCase() ?? '';
    final body = message.notification?.body?.toLowerCase() ?? '';
    final data = message.data;

    // Vérifier les mots-clés pour déterminer le type
    if (title.contains('livraison') ||
        title.contains('colis') ||
        title.contains('nouveau') ||
        body.contains('livraison') ||
        body.contains('colis') ||
        body.contains('nouveau') ||
        data['type'] == 'delivery' ||
        data['type'] == 'colis') {
      return NotificationType.delivery;
    }

    if (title.contains('ramassage') ||
        body.contains('ramassage') ||
        data['type'] == 'ramassage') {
      return NotificationType.pickup;
    }

    if (title.contains('urgent') ||
        title.contains('important') ||
        body.contains('urgent') ||
        body.contains('important')) {
      return NotificationType.urgent;
    }

    if (title.contains('erreur') ||
        title.contains('échec') ||
        body.contains('erreur') ||
        body.contains('échec')) {
      return NotificationType.error;
    }

    if (title.contains('succès') ||
        title.contains('terminé') ||
        body.contains('succès') ||
        body.contains('terminé')) {
      return NotificationType.success;
    }

    return NotificationType.info;
  }

  /// Convertir en Map pour le stockage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'data': data,
      'receivedAt': receivedAt.toIso8601String(),
      'isRead': isRead,
      'type': type.name,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
    };
  }

  /// Créer à partir d'un Map
  factory LocalNotification.fromMap(Map<String, dynamic> map) {
    return LocalNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      receivedAt: DateTime.parse(
        map['receivedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isRead: map['isRead'] ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.info,
      ),
      imageUrl: map['imageUrl'],
      actionUrl: map['actionUrl'],
    );
  }

  /// Marquer comme lu
  LocalNotification markAsRead() {
    return LocalNotification(
      id: id,
      title: title,
      body: body,
      data: data,
      receivedAt: receivedAt,
      isRead: true,
      type: type,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  /// Marquer comme non lu
  LocalNotification markAsUnread() {
    return LocalNotification(
      id: id,
      title: title,
      body: body,
      data: data,
      receivedAt: receivedAt,
      isRead: false,
      type: type,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
    );
  }

  /// Obtenir le temps écoulé depuis la réception
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(receivedAt);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return 'Il y a ${(difference.inDays / 7).floor()}sem';
    }
  }

  /// Obtenir la date formatée
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDate = DateTime(
      receivedAt.year,
      receivedAt.month,
      receivedAt.day,
    );

    if (notificationDate == today) {
      return 'Aujourd\'hui ${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}';
    } else if (notificationDate == today.subtract(const Duration(days: 1))) {
      return 'Hier ${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}';
    } else {
      return '${receivedAt.day}/${receivedAt.month}/${receivedAt.year} ${receivedAt.hour.toString().padLeft(2, '0')}:${receivedAt.minute.toString().padLeft(2, '0')}';
    }
  }
}

/// Types de notifications
enum NotificationType {
  delivery, // Livraison
  pickup, // Ramassage
  urgent, // Urgent
  error, // Erreur
  success, // Succès
  info, // Information
}

/// Statistiques des notifications
class NotificationStats {
  final int total;
  final int unread;
  final int delivery;
  final int pickup;
  final int urgent;
  final int error;
  final int success;
  final int info;

  NotificationStats({
    required this.total,
    required this.unread,
    required this.delivery,
    required this.pickup,
    required this.urgent,
    required this.error,
    required this.success,
    required this.info,
  });

  /// Créer à partir d'une liste de notifications
  factory NotificationStats.fromNotifications(
    List<LocalNotification> notifications,
  ) {
    return NotificationStats(
      total: notifications.length,
      unread: notifications.where((n) => !n.isRead).length,
      delivery:
          notifications
              .where((n) => n.type == NotificationType.delivery)
              .length,
      pickup:
          notifications.where((n) => n.type == NotificationType.pickup).length,
      urgent:
          notifications.where((n) => n.type == NotificationType.urgent).length,
      error:
          notifications.where((n) => n.type == NotificationType.error).length,
      success:
          notifications.where((n) => n.type == NotificationType.success).length,
      info: notifications.where((n) => n.type == NotificationType.info).length,
    );
  }
}

/// Filtres pour les notifications
enum NotificationFilter {
  all, // Toutes
  unread, // Non lues
  delivery, // Livraisons
  pickup, // Ramassages
  urgent, // Urgentes
  error, // Erreurs
  success, // Succès
  info, // Informations
}

/// Options de tri pour les notifications
enum NotificationSort {
  newest, // Plus récentes
  oldest, // Plus anciennes
  unreadFirst, // Non lues en premier
  type, // Par type
}
