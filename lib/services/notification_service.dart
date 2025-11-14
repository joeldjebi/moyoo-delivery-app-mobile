import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ramassage_controller.dart';
import '../controllers/delivery_controller.dart';
import 'notification_manager_service.dart';
import '../models/local_notification_models.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static String? _fcmToken;
  static bool _isInitialized = false;
  static bool _handlersConfigured = false;
  static final NotificationManagerService _notificationManager =
      NotificationManagerService();

  /// Initialiser le service de notifications
  static Future<void> initialize() async {
    try {
      // Éviter les initialisations multiples
      if (_isInitialized) {
        return;
      }

      // Vérifier si Firebase est initialisé
      if (Firebase.apps.isEmpty) {
        return;
      }

      await _setupNotificationChannels();
      await _requestPermissions();
      await _getFcmToken();
      _setupMessageHandlers();
      await _notificationManager.initialize();

      // Marquer comme initialisé
      _isInitialized = true;
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Configurer les canaux de notification Android
  static Future<void> _setupNotificationChannels() async {
    try {
      // Configuration Android
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/ic_launcher',
      );

      // Configuration iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configuration initiale
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Initialiser le plugin
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Créer le canal de notification Android
      const androidChannel = AndroidNotificationChannel(
        'high_importance_channel',
        'Notifications importantes',
        description:
            'Notifications importantes pour les livraisons et ramassages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(androidChannel);
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Demander les permissions de notification
  static Future<void> _requestPermissions() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Obtenir le token FCM
  static Future<void> _getFcmToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Configurer les handlers de messages
  static void _setupMessageHandlers() {
    // Éviter la configuration multiple des handlers
    if (_handlersConfigured) {
      return;
    }

    // Message reçu en arrière-plan
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Message reçu au premier plan
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Message reçu quand l'app est en arrière-plan et ouverte par notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // Marquer les handlers comme configurés
    _handlersConfigured = true;
  }

  /// Enregistrer le token FCM sur le serveur
  static Future<bool> registerFcmTokenOnServer() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        return false;
      }

      final authController = Get.find<AuthController>();
      final authToken = authController.authToken;

      if (authToken.isEmpty) {
        return false;
      }

      final response = await FcmService.registerFcmToken(
        fcmToken: _fcmToken!,
        authToken: authToken,
      );

      return response.success;
    } catch (e) {
      return false;
    }
  }

  /// Vérifier si le token FCM est enregistré et valide
  static Future<bool> isFcmTokenRegistered() async {
    try {
      if (_fcmToken == null || _fcmToken!.isEmpty) {
        return false;
      }

      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn || authController.authToken.isEmpty) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Gérer les messages reçus au premier plan
  static void _handleForegroundMessage(RemoteMessage message) async {
    try {
      // Initialiser le gestionnaire de notifications si nécessaire
      await _notificationManager.initialize();

      // Créer et sauvegarder la notification locale via le gestionnaire
      final localNotification = LocalNotification.fromRemoteMessage(message);
      await _notificationManager.addNotification(
        title: localNotification.title,
        body: localNotification.body,
        data: localNotification.data,
        type: localNotification.type,
        imageUrl: localNotification.imageUrl,
        actionUrl: localNotification.actionUrl,
      );

      // Afficher une notification native
      await _showLocalNotification(message);

      // Actualiser les listes selon le type de notification
      _handleNotificationRefresh(message);
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Afficher une notification locale
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'high_importance_channel',
        'Notifications importantes',
        channelDescription:
            'Notifications importantes pour les livraisons et ramassages',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        message.hashCode,
        message.notification?.title ?? 'Notification',
        message.notification?.body ?? 'Nouveau message',
        notificationDetails,
      );
    } catch (e) {}
  }

  /// Gérer le tap sur une notification locale
  static void _onNotificationTapped(NotificationResponse response) {
    // Ici on peut naviguer vers une page spécifique selon le payload
  }

  /// Gérer l'actualisation des listes selon le type de notification
  static void _handleNotificationRefresh(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final data = message.data;

      // Vérifier si c'est une notification de ramassage
      if (title.toLowerCase().contains('ramassage') ||
          body.toLowerCase().contains('ramassage') ||
          data['type'] == 'ramassage') {
        _refreshRamassageLists();
      }

      // Vérifier si c'est une notification de livraison (mots-clés étendus)
      if (title.toLowerCase().contains('livraison') ||
          title.toLowerCase().contains('colis') ||
          title.toLowerCase().contains('nouveau') ||
          title.toLowerCase().contains('créé') ||
          title.toLowerCase().contains('cree') ||
          body.toLowerCase().contains('livraison') ||
          body.toLowerCase().contains('colis') ||
          body.toLowerCase().contains('nouveau') ||
          body.toLowerCase().contains('créé') ||
          body.toLowerCase().contains('cree') ||
          data['type'] == 'delivery' ||
          data['type'] == 'colis') {
        _refreshDeliveryLists();
      }
    } catch (e) {}
  }

  /// Actualiser les listes de ramassages
  static void _refreshRamassageLists() {
    try {
      // Actualiser le controller de ramassages
      if (Get.isRegistered<RamassageController>()) {
        final ramassageController = Get.find<RamassageController>();
        ramassageController.refreshRamassages();
      }
    } catch (e) {}
  }

  /// Actualiser les listes de livraisons
  static void _refreshDeliveryLists() {
    try {
      // Vérifier si le controller est enregistré
      if (Get.isRegistered<DeliveryController>()) {
        final deliveryController = Get.find<DeliveryController>();

        // Actualiser la liste de manière asynchrone
        deliveryController
            .refreshColis()
            .then((_) {
              // Diagnostic complet de l'état
              deliveryController.diagnosticState();

              // Forcer la mise à jour de l'interface
              deliveryController.forceUpdateUI();
            })
            .catchError((error) {});
      }
    } catch (e) {}
  }

  /// Gérer le tap sur une notification
  static void _handleNotificationTap(RemoteMessage message) async {
    try {
      // Initialiser le gestionnaire de notifications si nécessaire
      await _notificationManager.initialize();

      // Créer et sauvegarder la notification locale via le gestionnaire
      final localNotification = LocalNotification.fromRemoteMessage(message);
      await _notificationManager.addNotification(
        title: localNotification.title,
        body: localNotification.body,
        data: localNotification.data,
        type: localNotification.type,
        imageUrl: localNotification.imageUrl,
        actionUrl: localNotification.actionUrl,
      );

      // Navigation vers la page appropriée selon le type de notification
      final data = message.data;

      if (data.containsKey('type')) {
        switch (data['type']) {
          case 'delivery':
            // Naviguer vers les détails de livraison
            break;
          case 'pickup':
            // Naviguer vers les détails de ramassage
            break;
          default:
            // Naviguer vers le dashboard
            break;
        }
      }

      // Actualiser les listes selon le type de notification
      _handleNotificationRefresh(message);
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Obtenir le token FCM actuel
  static String? get fcmToken => _fcmToken;

  /// Obtenir le token FCM complet pour les tests
  static String getFcmTokenForTesting() {
    if (_fcmToken != null && _fcmToken!.isNotEmpty) {
      return _fcmToken!;
    }
    return 'Token FCM non disponible';
  }

  /// Forcer la demande de permissions
  static Future<bool> forceRequestPermissions() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      return false;
    }
  }

  /// Forcer la réinitialisation du service (pour le débogage)
  static void forceReinitialize() {
    _isInitialized = false;
    _handlersConfigured = false;
    _fcmToken = null;
  }

  /// Réinitialiser complètement le service et le reconfigurer
  static Future<void> forceReinitializeAndSetup() async {
    try {
      // Forcer la réinitialisation
      forceReinitialize();

      // Attendre un peu
      await Future.delayed(const Duration(milliseconds: 500));

      // Réinitialiser complètement
      await initialize();

      // Forcer l'enregistrement du token FCM
      await forceRegisterFcmToken();
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Forcer l'actualisation manuelle des listes (pour le débogage)
  static void forceRefreshLists() {
    // Actualiser les ramassages
    _refreshRamassageLists();

    // Actualiser les livraisons
    _refreshDeliveryLists();
  }

  /// Forcer l'enregistrement du token FCM (pour usage manuel)
  static Future<bool> forceRegisterFcmToken() async {
    try {
      // Réinitialiser le service si nécessaire
      if (!_isInitialized) {
        await initialize();
      }

      // Attendre un peu pour que l'initialisation se termine
      await Future.delayed(const Duration(milliseconds: 500));

      // Enregistrer le token
      return await registerFcmTokenOnServer();
    } catch (e) {
      return false;
    }
  }

  /// Vérifier et traiter les flags d'actualisation au retour au premier plan
  static void checkAndProcessRefreshFlags() {
    try {
      // Vérifier si les controllers sont disponibles
      bool ramassageControllerAvailable =
          Get.isRegistered<RamassageController>();
      bool deliveryControllerAvailable = Get.isRegistered<DeliveryController>();

      // Actualiser les listes si les controllers sont disponibles
      if (ramassageControllerAvailable) {
        _refreshRamassageLists();
      }

      if (deliveryControllerAvailable) {
        _refreshDeliveryLists();
      }
    } catch (e) {}
  }
}

/// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Assurez-vous que Firebase est initialisé même en arrière-plan
    await Firebase.initializeApp();

    // Initialiser le gestionnaire de notifications
    final notificationManager = NotificationManagerService();
    await notificationManager.initialize();

    // Créer et sauvegarder la notification locale
    final localNotification = LocalNotification.fromRemoteMessage(message);
    await notificationManager.addNotification(
      title: localNotification.title,
      body: localNotification.body,
      data: localNotification.data,
      type: localNotification.type,
      imageUrl: localNotification.imageUrl,
      actionUrl: localNotification.actionUrl,
    );

    // Analyser le message pour déterminer le type
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    final data = message.data;

    // Vérifier si c'est une notification de ramassage
    if (title.toLowerCase().contains('ramassage') ||
        body.toLowerCase().contains('ramassage') ||
        data['type'] == 'ramassage') {
      // En arrière-plan, on peut stocker un flag pour actualiser au retour au premier plan
      _storeRefreshFlag('ramassage');
    }

    // Vérifier si c'est une notification de livraison (mots-clés étendus)
    if (title.toLowerCase().contains('livraison') ||
        title.toLowerCase().contains('colis') ||
        title.toLowerCase().contains('nouveau') ||
        title.toLowerCase().contains('créé') ||
        title.toLowerCase().contains('cree') ||
        body.toLowerCase().contains('livraison') ||
        body.toLowerCase().contains('colis') ||
        body.toLowerCase().contains('nouveau') ||
        body.toLowerCase().contains('créé') ||
        body.toLowerCase().contains('cree') ||
        data['type'] == 'delivery' ||
        data['type'] == 'colis') {
      _storeRefreshFlag('delivery');
    }
  } catch (e) {}
}

/// Stocker un flag pour actualiser les listes au retour au premier plan
void _storeRefreshFlag(String type) {}
