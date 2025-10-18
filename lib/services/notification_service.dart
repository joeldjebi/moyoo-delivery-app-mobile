import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'fcm_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ramassage_controller.dart';
import '../controllers/delivery_controller.dart';
import 'notification_manager_service.dart';

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
      print('🔄 ===== INITIALISATION DU SERVICE DE NOTIFICATIONS =====');
      print('🔄 Moment: ${DateTime.now().toIso8601String()}');
      print('🔄 Déjà initialisé: $_isInitialized');

      // Éviter les initialisations multiples
      if (_isInitialized) {
        print(
          '⚠️ NotificationService déjà initialisé - arrêt de l\'initialisation',
        );
        return;
      }

      // Vérifier si Firebase est initialisé
      if (Firebase.apps.isEmpty) {
        print('❌ Firebase n\'est pas initialisé - arrêt de l\'initialisation');
        return;
      }
      print('✅ Firebase est initialisé');

      // Configurer les canaux de notification Android
      print('🔄 Configuration des canaux de notification...');
      await _setupNotificationChannels();
      print('✅ Canaux de notification configurés');

      // Demander les permissions
      print('🔄 Demande des permissions...');
      await _requestPermissions();
      print('✅ Permissions demandées');

      // Obtenir le token FCM
      print('🔄 Obtention du token FCM...');
      await _getFcmToken();
      print('✅ Token FCM obtenu');

      // Configurer les handlers de messages
      print('🔄 Configuration des handlers de messages...');
      _setupMessageHandlers();
      print('✅ Handlers de messages configurés');

      // Initialiser le gestionnaire de notifications locales
      print('🔄 Initialisation du gestionnaire de notifications locales...');
      await _notificationManager.initialize();
      print('✅ Gestionnaire de notifications locales initialisé');

      // Marquer comme initialisé
      _isInitialized = true;
      print('✅ ===== NOTIFICATIONSERVICE INITIALISÉ AVEC SUCCÈS =====');
    } catch (e) {
      print('❌ ===== ERREUR LORS DE L\'INITIALISATION =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ ================================================');
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

      print('📱 Canaux de notification configurés avec son par défaut');
    } catch (e) {
      print('❌ Erreur lors de la configuration des canaux: $e');
    }
  }

  /// Demander les permissions de notification
  static Future<void> _requestPermissions() async {
    try {
      print('🔄 Demande des permissions de notification...');

      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true, // Son activé pour les notifications
      );

      print('🔔 ===== STATUT DES PERMISSIONS =====');
      print('🔔 Authorization Status: ${settings.authorizationStatus}');
      print('🔔 Alert: ${settings.alert}');
      print('🔔 Badge: ${settings.badge}');
      print('🔔 Sound: ${settings.sound}');
      print('🔔 Announcement: ${settings.announcement}');
      print('🔔 Car Play: ${settings.carPlay}');
      print('🔔 Critical Alert: ${settings.criticalAlert}');
      // print('🔔 Provisional: ${settings.provisional}'); // Propriété non disponible
      print('🔔 ==================================');

      // Vérifier si les permissions sont accordées
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Permissions de notification accordées');
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('❌ Permissions de notification refusées');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.notDetermined) {
        print('⚠️ Permissions de notification non déterminées');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        print('⚠️ Permissions de notification provisoires');
      }
    } catch (e) {
      print('❌ ===== ERREUR LORS DE LA DEMANDE DE PERMISSIONS =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ ===================================================');
    }
  }

  /// Obtenir le token FCM
  static Future<void> _getFcmToken() async {
    try {
      print('🔄 Obtention du token FCM...');
      _fcmToken = await _firebaseMessaging.getToken();

      if (_fcmToken != null && _fcmToken!.isNotEmpty) {
        print('🔑 ===== TOKEN FCM OBTENU =====');
        print(
          '🔑 Token (premiers 20 caractères): ${_fcmToken!.substring(0, 20)}...',
        );
        print(
          '🔑 Token (derniers 20 caractères): ...${_fcmToken!.substring(_fcmToken!.length - 20)}',
        );
        print('🔑 Longueur du token: ${_fcmToken!.length} caractères');
        print('🔑 =============================');
      } else {
        print('❌ Token FCM null ou vide');
      }
    } catch (e) {
      print('❌ ===== ERREUR LORS DE L\'OBTENTION DU TOKEN FCM =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ ===================================================');
    }
  }

  /// Configurer les handlers de messages
  static void _setupMessageHandlers() {
    print('🔄 Configuration des handlers de messages...');
    print('🔄 Handlers déjà configurés: $_handlersConfigured');

    // Éviter la configuration multiple des handlers
    if (_handlersConfigured) {
      print('⚠️ Handlers déjà configurés - arrêt de la configuration');
      return;
    }

    // Message reçu en arrière-plan
    print('🔄 Configuration du handler en arrière-plan...');
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    print('✅ Handler en arrière-plan configuré');

    // Message reçu au premier plan
    print('🔄 Configuration du handler au premier plan...');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📱 ===== MESSAGE REÇU AU PREMIER PLAN =====');
      print('📱 Titre: ${message.notification?.title}');
      print('📱 Moment: ${DateTime.now().toIso8601String()}');
      print('📱 ========================================');
      _handleForegroundMessage(message);
    });
    print('✅ Handler au premier plan configuré');

    // Message reçu quand l'app est en arrière-plan et ouverte par notification
    print('🔄 Configuration du handler d\'ouverture par notification...');
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 ===== APP OUVERTE PAR NOTIFICATION =====');
      print('📱 Titre: ${message.notification?.title}');
      print('📱 Moment: ${DateTime.now().toIso8601String()}');
      print('📱 ========================================');
      _handleNotificationTap(message);
    });
    print('✅ Handler d\'ouverture par notification configuré');

    // Marquer les handlers comme configurés
    _handlersConfigured = true;
    print('✅ Tous les handlers de messages configurés');
  }

  /// Enregistrer le token FCM sur le serveur
  static Future<bool> registerFcmTokenOnServer() async {
    try {
      if (_fcmToken == null) {
        print('❌ Token FCM non disponible');
        return false;
      }

      final authController = Get.find<AuthController>();
      final authToken = authController.authToken;

      if (authToken.isEmpty) {
        print('❌ Token d\'authentification non disponible');
        return false;
      }

      print('🔄 Enregistrement du token FCM sur le serveur...');

      final response = await FcmService.registerFcmToken(
        fcmToken: _fcmToken!,
        authToken: authToken,
      );

      if (response.success) {
        print('✅ Token FCM enregistré avec succès');
        return true;
      } else {
        print('❌ Erreur lors de l\'enregistrement: ${response.message}');
        return false;
      }
    } catch (e) {
      print('❌ Erreur lors de l\'enregistrement du token FCM: $e');
      return false;
    }
  }

  /// Gérer les messages reçus au premier plan
  static void _handleForegroundMessage(RemoteMessage message) async {
    // Log détaillé du message reçu
    print('🔔 ===== MESSAGE REÇU AU PREMIER PLAN =====');
    print('🔔 Message ID: ${message.messageId}');
    print('🔔 From: ${message.from}');
    print('🔔 Sent Time: ${message.sentTime}');
    print('🔔 TTL: ${message.ttl}');

    // Détails de la notification
    if (message.notification != null) {
      print('🔔 Notification:');
      print('🔔 - Title: "${message.notification!.title}"');
      print('🔔 - Body: "${message.notification!.body}"');
      print(
        '🔔 - Android Channel ID: ${message.notification!.android?.channelId}',
      );
      print(
        '🔔 - Android Click Action: ${message.notification!.android?.clickAction}',
      );
      print('🔔 - Android Color: ${message.notification!.android?.color}');
      print('🔔 - Android Sound: ${message.notification!.android?.sound}');
      print('🔔 - Android Tag: ${message.notification!.android?.tag}');
    } else {
      print('🔔 Notification: null');
    }

    // Données personnalisées
    print('🔔 Data:');
    message.data.forEach((key, value) {
      print('🔔 - $key: $value');
    });
    print('🔔 ==========================================');

    // Sauvegarder la notification localement
    print('📱 Sauvegarde de la notification localement...');
    await _notificationManager.initialize();

    // Afficher une notification native
    await _showLocalNotification(message);
    print('🔊 Notification native affichée avec son');

    // Actualiser les listes selon le type de notification
    _handleNotificationRefresh(message);
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
    } catch (e) {
      print('❌ Erreur lors de l\'affichage de la notification: $e');
    }
  }

  /// Gérer le tap sur une notification locale
  static void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Notification tapée: ${response.payload}');
    // Ici on peut naviguer vers une page spécifique selon le payload
  }

  /// Gérer l'actualisation des listes selon le type de notification
  static void _handleNotificationRefresh(RemoteMessage message) {
    try {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      final data = message.data;

      print('🔄 ===== ANALYSE DE LA NOTIFICATION POUR ACTUALISATION =====');
      print('🔄 - Titre: "$title"');
      print('🔄 - Corps: "$body"');
      print('🔄 - Data: $data');
      print('🔄 - Titre en minuscules: "${title.toLowerCase()}"');
      print('🔄 - Corps en minuscules: "${body.toLowerCase()}"');

      // Analyser chaque mot-clé individuellement
      print('🔄 Analyse des mots-clés:');
      print(
        '🔄 - Contient "ramassage" dans le titre: ${title.toLowerCase().contains('ramassage')}',
      );
      print(
        '🔄 - Contient "ramassage" dans le corps: ${body.toLowerCase().contains('ramassage')}',
      );
      print(
        '🔄 - Contient "livraison" dans le titre: ${title.toLowerCase().contains('livraison')}',
      );
      print(
        '🔄 - Contient "livraison" dans le corps: ${body.toLowerCase().contains('livraison')}',
      );
      print(
        '🔄 - Contient "colis" dans le titre: ${title.toLowerCase().contains('colis')}',
      );
      print(
        '🔄 - Contient "colis" dans le corps: ${body.toLowerCase().contains('colis')}',
      );
      print(
        '🔄 - Contient "nouveau" dans le titre: ${title.toLowerCase().contains('nouveau')}',
      );
      print(
        '🔄 - Contient "nouveau" dans le corps: ${body.toLowerCase().contains('nouveau')}',
      );
      print(
        '🔄 - Contient "créé" dans le titre: ${title.toLowerCase().contains('créé')}',
      );
      print(
        '🔄 - Contient "créé" dans le corps: ${body.toLowerCase().contains('créé')}',
      );
      print(
        '🔄 - Contient "cree" dans le titre: ${title.toLowerCase().contains('cree')}',
      );
      print(
        '🔄 - Contient "cree" dans le corps: ${body.toLowerCase().contains('cree')}',
      );
      print('🔄 - data["type"] == "ramassage": ${data['type'] == 'ramassage'}');
      print('🔄 - data["type"] == "delivery": ${data['type'] == 'delivery'}');
      print('🔄 - data["type"] == "colis": ${data['type'] == 'colis'}');

      bool isRamassageNotification = false;
      bool isDeliveryNotification = false;

      // Vérifier si c'est une notification de ramassage
      if (title.toLowerCase().contains('ramassage') ||
          body.toLowerCase().contains('ramassage') ||
          data['type'] == 'ramassage') {
        isRamassageNotification = true;
        print(
          '📦 Notification de ramassage détectée - Actualisation des listes',
        );
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
        isDeliveryNotification = true;
        print(
          '🚚 Notification de livraison détectée - Actualisation des listes',
        );
        _refreshDeliveryLists();
      }

      // Si aucune notification spécifique n'est détectée, log pour debug
      if (!isRamassageNotification && !isDeliveryNotification) {
        print('⚠️ ===== AUCUN TYPE DE NOTIFICATION DÉTECTÉ =====');
        print('⚠️ Mots-clés dans le titre: ${title.toLowerCase().split(' ')}');
        print('⚠️ Mots-clés dans le corps: ${body.toLowerCase().split(' ')}');
        print('⚠️ Tous les clés de data: ${data.keys.toList()}');
        print('⚠️ Toutes les valeurs de data: ${data.values.toList()}');
        print('⚠️ ================================================');
      } else {
        print('✅ ===== RÉSULTAT DE L\'ANALYSE =====');
        print('✅ - Notification de ramassage: $isRamassageNotification');
        print('✅ - Notification de livraison: $isDeliveryNotification');
        print('✅ ===================================');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'actualisation des listes: $e');
      print('❌ Stack trace: ${e.toString()}');
    }
  }

  /// Actualiser les listes de ramassages
  static void _refreshRamassageLists() {
    try {
      // Actualiser le controller de ramassages
      if (Get.isRegistered<RamassageController>()) {
        final ramassageController = Get.find<RamassageController>();
        ramassageController.refreshRamassages();
        print('✅ Liste des ramassages actualisée');
      }
    } catch (e) {
      print('❌ Erreur lors de l\'actualisation des ramassages: $e');
    }
  }

  /// Actualiser les listes de livraisons
  static void _refreshDeliveryLists() {
    try {
      print('🔄 ===== DÉBUT DE L\'ACTUALISATION DES LIVRAISONS =====');

      // Vérifier si le controller est enregistré
      if (Get.isRegistered<DeliveryController>()) {
        print('🔄 DeliveryController trouvé et enregistré');
        final deliveryController = Get.find<DeliveryController>();

        print('🔄 État AVANT actualisation:');
        print('🔄 - isLoading: ${deliveryController.isLoading}');
        print('🔄 - colis.length: ${deliveryController.colis.length}');
        print('🔄 - errorMessage: "${deliveryController.errorMessage}"');

        // Afficher les détails des colis actuels
        if (deliveryController.colis.isNotEmpty) {
          print('🔄 Colis actuels:');
          for (int i = 0; i < deliveryController.colis.length; i++) {
            final colis = deliveryController.colis[i];
            print('🔄 - Colis $i: ${colis.code} (statut: ${colis.status})');
          }
        } else {
          print('🔄 Aucun colis actuellement dans la liste');
        }

        print('🔄 Appel de deliveryController.refreshColis()...');

        // Actualiser la liste de manière asynchrone
        deliveryController
            .refreshColis()
            .then((_) {
              print('🔄 État APRÈS actualisation (dans le callback):');
              print('🔄 - isLoading: ${deliveryController.isLoading}');
              print('🔄 - colis.length: ${deliveryController.colis.length}');
              print('🔄 - errorMessage: "${deliveryController.errorMessage}"');

              // Diagnostic complet de l'état
              deliveryController.diagnosticState();

              // Forcer la mise à jour de l'interface
              deliveryController.forceUpdateUI();
            })
            .catchError((error) {
              print('❌ Erreur lors de l\'actualisation: $error');
            });

        print('✅ ===== ACTUALISATION DES LIVRAISONS LANCÉE =====');
      } else {
        print('⚠️ ===== DELIVERYCONTROLLER NON ENREGISTRÉ =====');
        print('⚠️ Controllers disponibles:');
        print(
          '⚠️ - RamassageController: ${Get.isRegistered<RamassageController>()}',
        );
        print(
          '⚠️ - DeliveryController: ${Get.isRegistered<DeliveryController>()}',
        );
        print('⚠️ - AuthController: ${Get.isRegistered<AuthController>()}');
        print('⚠️ ================================================');
      }
    } catch (e) {
      print('❌ ===== ERREUR LORS DE L\'ACTUALISATION DES LIVRAISONS =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ ========================================================');
    }
  }

  /// Gérer le tap sur une notification
  static void _handleNotificationTap(RemoteMessage message) {
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
  }

  /// Obtenir le token FCM actuel
  static String? get fcmToken => _fcmToken;

  /// Forcer la réinitialisation du service (pour le débogage)
  static void forceReinitialize() {
    print('🔄 ===== FORÇAGE DE LA RÉINITIALISATION =====');
    _isInitialized = false;
    _handlersConfigured = false;
    _fcmToken = null;
    print('✅ Service marqué pour réinitialisation');
    print('🔄 ==========================================');
  }

  /// Forcer l'actualisation manuelle des listes (pour le débogage)
  static void forceRefreshLists() {
    print('🔄 ===== FORÇAGE DE L\'ACTUALISATION DES LISTES =====');
    print('🔄 Moment: ${DateTime.now().toIso8601String()}');

    // Actualiser les ramassages
    print('🔄 Actualisation des ramassages...');
    _refreshRamassageLists();

    // Actualiser les livraisons
    print('🔄 Actualisation des livraisons...');
    _refreshDeliveryLists();

    print('✅ ===== ACTUALISATION FORCÉE TERMINÉE =====');
  }

  /// Vérifier le statut des notifications et diagnostiquer les problèmes
  static Future<void> checkNotificationStatus() async {
    try {
      print('🔍 ===== DIAGNOSTIC DU STATUT DES NOTIFICATIONS =====');
      print('🔍 Moment: ${DateTime.now().toIso8601String()}');

      // Vérifier Firebase
      print('🔍 Firebase:');
      print('🔍 - Apps initialisées: ${Firebase.apps.length}');
      if (Firebase.apps.isNotEmpty) {
        print('🔍 - App par défaut: ${Firebase.app().name}');
      }

      // Vérifier les permissions
      print('🔍 Permissions:');
      final settings = await _firebaseMessaging.getNotificationSettings();
      print('🔍 - Authorization Status: ${settings.authorizationStatus}');
      print('🔍 - Alert: ${settings.alert}');
      print('🔍 - Badge: ${settings.badge}');
      print('🔍 - Sound: ${settings.sound}');

      // Vérifier le token FCM
      print('🔍 Token FCM:');
      print('🔍 - Token actuel: ${_fcmToken != null ? "Présent" : "Absent"}');
      if (_fcmToken != null) {
        print('🔍 - Longueur: ${_fcmToken!.length} caractères');
        print('🔍 - Premiers caractères: ${_fcmToken!.substring(0, 20)}...');
      }

      // Vérifier les handlers
      print('🔍 Handlers:');
      print('🔍 - Handlers configurés: Oui');

      // Vérifier les canaux de notification
      print('🔍 Canaux de notification:');
      final androidPlugin =
          _localNotifications
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      if (androidPlugin != null) {
        final channels = await androidPlugin.getNotificationChannels();
        if (channels != null) {
          print('🔍 - Nombre de canaux: ${channels.length}');
          for (final channel in channels) {
            print('🔍 - Canal: ${channel.id} (${channel.name})');
          }
        } else {
          print('🔍 - Aucun canal de notification trouvé');
        }
      }

      print('🔍 ================================================');
    } catch (e) {
      print('❌ ===== ERREUR LORS DU DIAGNOSTIC =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ =====================================');
    }
  }

  /// Vérifier et traiter les flags d'actualisation au retour au premier plan
  static void checkAndProcessRefreshFlags() {
    try {
      print('🔄 ===== VÉRIFICATION DES FLAGS D\'ACTUALISATION =====');
      print('🔄 Moment: ${DateTime.now().toIso8601String()}');

      // Vérifier si les controllers sont disponibles
      bool ramassageControllerAvailable =
          Get.isRegistered<RamassageController>();
      bool deliveryControllerAvailable = Get.isRegistered<DeliveryController>();

      print('🔄 Controllers disponibles:');
      print('🔄 - RamassageController: $ramassageControllerAvailable');
      print('🔄 - DeliveryController: $deliveryControllerAvailable');
      print('🔄 - AuthController: ${Get.isRegistered<AuthController>()}');

      // Actualiser les listes si les controllers sont disponibles
      if (ramassageControllerAvailable) {
        print('🔄 ===== ACTUALISATION DES RAMASSAGES =====');
        _refreshRamassageLists();
      } else {
        print(
          '⚠️ RamassageController non disponible - pas d\'actualisation des ramassages',
        );
      }

      if (deliveryControllerAvailable) {
        print('🔄 ===== ACTUALISATION DES LIVRAISONS =====');
        _refreshDeliveryLists();
      } else {
        print(
          '⚠️ DeliveryController non disponible - pas d\'actualisation des livraisons',
        );
      }

      print('✅ ===== FLAGS D\'ACTUALISATION TRAITÉS =====');
    } catch (e) {
      print('❌ ===== ERREUR LORS DU TRAITEMENT DES FLAGS =====');
      print('❌ Erreur: $e');
      print('❌ Type d\'erreur: ${e.runtimeType}');
      print('❌ Stack trace: ${e.toString()}');
      print('❌ ================================================');
    }
  }
}

/// Handler pour les messages en arrière-plan
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Assurez-vous que Firebase est initialisé même en arrière-plan
  await Firebase.initializeApp();

  // Log détaillé du message reçu en arrière-plan
  print('🚀 ===== MESSAGE REÇU EN ARRIÈRE-PLAN =====');
  print('🚀 Message ID: ${message.messageId}');
  print('🚀 From: ${message.from}');
  print('🚀 Sent Time: ${message.sentTime}');
  print('🚀 TTL: ${message.ttl}');

  // Détails de la notification
  if (message.notification != null) {
    print('🚀 Notification:');
    print('🚀 - Title: "${message.notification!.title}"');
    print('🚀 - Body: "${message.notification!.body}"');
    print(
      '🚀 - Android Channel ID: ${message.notification!.android?.channelId}',
    );
    print(
      '🚀 - Android Click Action: ${message.notification!.android?.clickAction}',
    );
    print('🚀 - Android Color: ${message.notification!.android?.color}');
    print('🚀 - Android Sound: ${message.notification!.android?.sound}');
    print('🚀 - Android Tag: ${message.notification!.android?.tag}');
  } else {
    print('🚀 Notification: null');
  }

  // Données personnalisées
  print('🚀 Data:');
  message.data.forEach((key, value) {
    print('🚀 - $key: $value');
  });
  print('🚀 ==========================================');

  // Analyser le message pour déterminer le type
  final title = message.notification?.title ?? '';
  final body = message.notification?.body ?? '';
  final data = message.data;

  print('🔄 Analyse du message en arrière-plan:');
  print('🔄 - Titre: "$title"');
  print('🔄 - Corps: "$body"');
  print('🔄 - Data: $data');

  // Vérifier si c'est une notification de ramassage
  if (title.toLowerCase().contains('ramassage') ||
      body.toLowerCase().contains('ramassage') ||
      data['type'] == 'ramassage') {
    print(
      '📦 Notification de ramassage en arrière-plan - Marquer pour actualisation',
    );
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
    print(
      '🚚 Notification de livraison en arrière-plan - Marquer pour actualisation',
    );
    _storeRefreshFlag('delivery');
  }
}

/// Stocker un flag pour actualiser les listes au retour au premier plan
void _storeRefreshFlag(String type) {
  // Utiliser SharedPreferences pour stocker le flag
  // Ceci sera lu au retour au premier plan
  print('💾 Flag d\'actualisation stocké pour: $type');
}
