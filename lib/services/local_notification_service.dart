import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialise le service de notifications locales
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configuration Android
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configuration iOS
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = true;
    } catch (e) {}
  }

  /// Gère le tap sur une notification
  void _onNotificationTapped(NotificationResponse response) {
    // Ici on peut ajouter de la logique pour naviguer vers une page spécifique
  }

  /// Affiche une notification de succès
  Future<void> showSuccessNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      message: message,
      payload: payload,
      type: NotificationType.success,
    );
  }

  /// Affiche une notification d'erreur
  Future<void> showErrorNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      message: message,
      payload: payload,
      type: NotificationType.error,
    );
  }

  /// Affiche une notification d'avertissement
  Future<void> showWarningNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      message: message,
      payload: payload,
      type: NotificationType.warning,
    );
  }

  /// Affiche une notification d'information
  Future<void> showInfoNotification({
    required String title,
    required String message,
    String? payload,
  }) async {
    await _showNotification(
      title: title,
      message: message,
      payload: payload,
      type: NotificationType.info,
    );
  }

  /// Méthode privée pour afficher une notification
  Future<void> _showNotification({
    required String title,
    required String message,
    String? payload,
    required NotificationType type,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      const AndroidNotificationDetails
      androidDetails = AndroidNotificationDetails(
        'delivery_actions',
        'Actions de livraison',
        channelDescription:
            'Notifications pour les actions de livraison (démarrer, terminer, annuler)',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF2196F3), // Couleur primaire
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Générer un ID unique pour chaque notification
      final int notificationId = DateTime.now().millisecondsSinceEpoch
          .remainder(100000);

      await _flutterLocalNotificationsPlugin.show(
        notificationId,
        title,
        message,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      // Fallback vers snackbar en cas d'erreur
      _showFallbackSnackbar(title, message, type);
    }
  }

  /// Fallback vers snackbar en cas d'erreur avec les notifications
  void _showFallbackSnackbar(
    String title,
    String message,
    NotificationType type,
  ) {
    Color backgroundColor;
    switch (type) {
      case NotificationType.success:
        backgroundColor = const Color(0xFF4CAF50);
        break;
      case NotificationType.error:
        backgroundColor = const Color(0xFFF44336);
        break;
      case NotificationType.warning:
        backgroundColor = const Color(0xFFFF9800);
        break;
      case NotificationType.info:
        backgroundColor = const Color(0xFF2196F3);
        break;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 10,
    );
  }

  /// Annule toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  /// Annule une notification spécifique
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}

/// Types de notifications
enum NotificationType { success, error, warning, info }
