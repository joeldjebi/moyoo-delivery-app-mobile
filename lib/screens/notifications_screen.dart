import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/local_notification_models.dart';
import '../services/notification_manager_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationManagerService _notificationManager =
      NotificationManagerService();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    await _notificationManager.refreshNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildNotificationsList(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Notifications',
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: AppDimensions.fontSizeM,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        // Bouton marquer tout comme lu
        IconButton(
          icon: const Icon(Icons.done_all),
          onPressed: _markAllAsRead,
          tooltip: 'Marquer tout comme lu',
        ),

        // Bouton supprimer tout
        IconButton(
          icon: const Icon(Icons.delete_sweep),
          onPressed: _deleteAllNotifications,
          tooltip: 'Supprimer toutes les notifications',
        ),

        // Bouton actualiser
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: _loadNotifications,
          tooltip: 'Actualiser',
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    return Obx(() {
      final notifications = _notificationManager.notifications;

      if (notifications.isEmpty) {
        return _buildEmptyState();
      }

      // Filtrer et trier les notifications
      List<LocalNotification> filteredNotifications =
          _filterAndSortNotifications(notifications);

      if (filteredNotifications.isEmpty) {
        return _buildEmptyState();
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final notification = filteredNotifications[index];
          return _buildNotificationCard(notification);
        },
      );
    });
  }

  List<LocalNotification> _filterAndSortNotifications(
    List<LocalNotification> notifications,
  ) {
    List<LocalNotification> filtered = List.from(notifications);

    // Trier par date (plus récentes en premier) et non lues en premier
    filtered.sort((a, b) {
      // D'abord par statut (non lues en premier)
      if (a.isRead != b.isRead) {
        return a.isRead ? 1 : -1;
      }
      // Puis par date (plus récentes en premier)
      return b.receivedAt.compareTo(a.receivedAt);
    });

    return filtered;
  }

  Widget _buildNotificationCard(LocalNotification notification) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            notification.isRead
                ? null
                : Border.all(
                  color: AppColors.primary.withOpacity(0.3),
                  width: 1,
                ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _handleNotificationTap(notification),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône de notification
                _buildNotificationIcon(notification),
                const SizedBox(width: 12),

                // Contenu principal
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre et indicateur de non lu
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontWeight:
                                    notification.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w600,
                                color: AppColors.textPrimary,
                                fontSize: 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      // Corps de la notification
                      Text(
                        notification.body,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Type et temps
                      Row(
                        children: [
                          _buildTypeChip(notification.type),
                          const SizedBox(width: 8),
                          Text(
                            notification.timeAgo,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Menu d'actions
                _buildActionMenu(notification),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionMenu(LocalNotification notification) {
    return PopupMenuButton<String>(
      onSelected: (value) => _handleNotificationAction(value, notification),
      icon: Icon(Icons.more_vert, size: 20, color: AppColors.textSecondary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      itemBuilder:
          (context) => [
            PopupMenuItem(
              value: 'mark_read',
              child: Row(
                children: [
                  Icon(
                    notification.isRead
                        ? Icons.mark_email_unread
                        : Icons.mark_email_read,
                    size: 18,
                    color:
                        notification.isRead
                            ? AppColors.info
                            : AppColors.success,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    notification.isRead
                        ? 'Marquer comme non lu'
                        : 'Marquer comme lu',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          notification.isRead
                              ? AppColors.info
                              : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  const SizedBox(width: 12),
                  Text(
                    'Supprimer',
                    style: TextStyle(fontSize: 14, color: AppColors.error),
                  ),
                ],
              ),
            ),
          ],
    );
  }

  Widget _buildNotificationIcon(LocalNotification notification) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.delivery:
        iconData = Icons.local_shipping;
        iconColor = AppColors.success;
        break;
      case NotificationType.pickup:
        iconData = Icons.inventory;
        iconColor = AppColors.info;
        break;
      case NotificationType.urgent:
        iconData = Icons.priority_high;
        iconColor = AppColors.error;
        break;
      case NotificationType.error:
        iconData = Icons.error;
        iconColor = AppColors.error;
        break;
      case NotificationType.success:
        iconData = Icons.check_circle;
        iconColor = AppColors.success;
        break;
      case NotificationType.info:
        iconData = Icons.info;
        iconColor = AppColors.primary;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 20),
    );
  }

  Widget _buildTypeChip(NotificationType type) {
    String label;
    Color color;

    switch (type) {
      case NotificationType.delivery:
        label = 'Livraison';
        color = AppColors.success;
        break;
      case NotificationType.pickup:
        label = 'Ramassage';
        color = AppColors.info;
        break;
      case NotificationType.urgent:
        label = 'Urgent';
        color = AppColors.error;
        break;
      case NotificationType.error:
        label = 'Erreur';
        color = AppColors.error;
        break;
      case NotificationType.success:
        label = 'Succès';
        color = AppColors.success;
        break;
      case NotificationType.info:
        label = 'Info';
        color = AppColors.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucune notification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vous n\'avez pas encore reçu de notifications.\nElles apparaîtront ici dès qu\'elles arriveront.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes d'action
  Future<void> _markAllAsRead() async {
    await _notificationManager.markAllAsRead();
    setState(() {});
  }

  Future<void> _deleteAllNotifications() async {
    final confirmed = await _showDeleteAllConfirmation();
    if (confirmed) {
      await _notificationManager.deleteAllNotifications();
      setState(() {});
    }
  }

  Future<bool> _showDeleteAllConfirmation() async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Supprimer toutes les notifications'),
                content: const Text(
                  'Êtes-vous sûr de vouloir supprimer toutes les notifications ? Cette action est irréversible.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Annuler'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Supprimer'),
                  ),
                ],
              ),
        ) ??
        false;
  }

  void _handleNotificationTap(LocalNotification notification) {
    if (!notification.isRead) {
      _notificationManager.markAsRead(notification.id);
    }

    // Navigation selon le type de notification
    switch (notification.type) {
      case NotificationType.delivery:
        Get.toNamed('/delivery-list');
        break;
      case NotificationType.pickup:
        Get.toNamed('/ramassage-list');
        break;
      default:
        Get.toNamed('/dashboard');
        break;
    }
  }

  void _handleNotificationAction(
    String action,
    LocalNotification notification,
  ) async {
    switch (action) {
      case 'mark_read':
        if (notification.isRead) {
          // Marquer comme non lu
          await _notificationManager.markAsUnread(notification.id);
        } else {
          // Marquer comme lu
          await _notificationManager.markAsRead(notification.id);
        }
        // Forcer la mise à jour de l'interface
        setState(() {});
        break;
      case 'delete':
        final confirmed = await _showDeleteConfirmation(notification);
        if (confirmed) {
          final success = await _notificationManager.deleteNotification(
            notification.id,
          );

          // Forcer la mise à jour de l'interface dans tous les cas
          setState(() {});

          // Recharger les notifications pour être sûr
          await _loadNotifications();
        }
        break;
    }
  }

  /// Afficher une confirmation de suppression
  Future<bool> _showDeleteConfirmation(LocalNotification notification) async {
    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                title: Text(
                  'Supprimer la notification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                content: Text(
                  'Êtes-vous sûr de vouloir supprimer cette notification ?',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Annuler',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: Text(
                      'Supprimer',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
        ) ??
        false;
  }

  // Méthodes utilitaires
}
