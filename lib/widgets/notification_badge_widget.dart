import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../services/notification_manager_service.dart';

/// Widget pour afficher un badge de notifications avec le nombre de notifications non lues
class NotificationBadgeWidget extends StatelessWidget {
  final Widget child;
  final double? size;
  final Color? badgeColor;
  final Color? textColor;
  final bool showZero;

  const NotificationBadgeWidget({
    super.key,
    required this.child,
    this.size,
    this.badgeColor,
    this.textColor,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notificationManager = NotificationManagerService();
      final unreadCount = notificationManager.unreadCount;

      // Ne pas afficher le badge si le nombre est 0 et showZero est false
      if (unreadCount == 0 && !showZero) {
        return child;
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          if (unreadCount > 0 || showZero)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 16),
                height: 16,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Center(
                  child: Text(
                    unreadCount > 99 ? '99+' : unreadCount.toString(),
                    style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// Widget pour afficher un badge de notifications simple (juste un point)
class NotificationDotWidget extends StatelessWidget {
  final Widget child;
  final double? size;
  final Color? dotColor;

  const NotificationDotWidget({
    super.key,
    required this.child,
    this.size,
    this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notificationManager = NotificationManagerService();
      final unreadCount = notificationManager.unreadCount;

      // Ne pas afficher le point si aucune notification non lue
      if (unreadCount == 0) {
        return child;
      }

      return Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          Positioned(
            right: 2,
            top: 2,
            child: Container(
              width: size ?? 8,
              height: size ?? 8,
              decoration: BoxDecoration(
                color: dotColor ?? AppColors.error,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Widget pour afficher le nombre de notifications non lues dans un texte
class NotificationCountWidget extends StatelessWidget {
  final TextStyle? textStyle;
  final String? prefix;
  final String? suffix;

  const NotificationCountWidget({
    super.key,
    this.textStyle,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notificationManager = NotificationManagerService();
      final unreadCount = notificationManager.unreadCount;

      return Text(
        '${prefix ?? ''}${unreadCount}${suffix ?? ''}',
        style:
            textStyle ??
            const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
      );
    });
  }
}

/// Widget pour afficher les statistiques des notifications
class NotificationStatsWidget extends StatelessWidget {
  final bool showTotal;
  final bool showUnread;
  final bool showByType;
  final TextStyle? textStyle;

  const NotificationStatsWidget({
    super.key,
    this.showTotal = true,
    this.showUnread = true,
    this.showByType = false,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final notificationManager = NotificationManagerService();
      final stats = notificationManager.stats;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTotal)
            Text(
              'Total: ${stats.total}',
              style: textStyle ?? const TextStyle(fontSize: 12),
            ),
          if (showUnread)
            Text(
              'Non lues: ${stats.unread}',
              style:
                  textStyle ??
                  const TextStyle(
                    fontSize: 12,
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          if (showByType) ...[
            if (stats.delivery > 0)
              Text(
                'Livraisons: ${stats.delivery}',
                style: textStyle ?? const TextStyle(fontSize: 10),
              ),
            if (stats.pickup > 0)
              Text(
                'Ramassages: ${stats.pickup}',
                style: textStyle ?? const TextStyle(fontSize: 10),
              ),
            if (stats.urgent > 0)
              Text(
                'Urgentes: ${stats.urgent}',
                style:
                    textStyle ??
                    const TextStyle(
                      fontSize: 10,
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
                    ),
              ),
          ],
        ],
      );
    });
  }
}
