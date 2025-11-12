import 'dart:async';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/location_api_service.dart';
import '../services/socket_service.dart';
import '../models/location_api_models.dart';
import '../storage/auth_storage.dart';

/// Contrôleur pour la gestion de la géolocalisation
class LocationController extends GetxController {
  final LocationService _locationService = Get.find<LocationService>();
  final SocketService _socketService = Get.find<SocketService>();

  // États observables
  final Rx<LocationData?> _currentLocation = Rx<LocationData?>(null);
  final RxList<LocationData> _locationHistory = <LocationData>[].obs;
  final RxBool _isLocationEnabled = false.obs;
  final RxBool _isLocationTracking = false.obs;
  final RxString _locationError = ''.obs;
  final RxString _apiError = ''.obs;
  final RxBool _isSendingLocation = false.obs;
  final RxString _connectionStatus = 'disconnected'.obs;

  // Mission actuelle
  final Rx<CurrentMission?> _currentMission = Rx<CurrentMission?>(null);
  final Rx<MissionHistory?> _missionHistory = Rx<MissionHistory?>(null);

  // Timer pour l'envoi périodique
  Timer? _locationUpdateTimer;
  static const int _maxHistorySize = 100;
  static const Duration _updateInterval = Duration(seconds: 30);

  // Getters
  LocationData? get currentLocation => _currentLocation.value;
  List<LocationData> get locationHistory => _locationHistory;
  bool get isLocationEnabled => _isLocationEnabled.value;
  bool get isLocationTracking => _isLocationTracking.value;
  String get locationError => _locationError.value;
  String get apiError => _apiError.value;
  bool get isSendingLocation => _isSendingLocation.value;
  String get connectionStatus => _connectionStatus.value;
  CurrentMission? get currentMission => _currentMission.value;
  MissionHistory? get missionHistory => _missionHistory.value;

  @override
  void onInit() {
    super.onInit();
    print('📍 LocationController initialisé');
    _initLocationServiceListeners();
    _initSocketServiceListeners();
  }

  @override
  void onClose() {
    _locationUpdateTimer?.cancel();
    super.onClose();
  }

  /// Initialiser les écouteurs du service de localisation
  void _initLocationServiceListeners() {
    try {
      // Écouter les changements de position
      _locationService.positionStream.listen((position) {
        if (position != null) {
          _onLocationUpdate(position);
        }
      });

      // Écouter les changements d'état
      ever(_locationService.isLocationEnabledRx, (enabled) {
        _isLocationEnabled.value = enabled;
      });

      ever(_locationService.isTrackingRx, (tracking) {
        _isLocationTracking.value = tracking;
      });

      ever(_locationService.locationErrorRx, (error) {
        _locationError.value = error;
      });

      print('✅ LocationService initialisé dans LocationController');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation du LocationService: $e');
      _locationError.value = 'Erreur d\'initialisation: $e';
    }
  }

  /// Initialiser les écouteurs du service Socket.IO
  void _initSocketServiceListeners() {
    try {
      // Écouter les changements de statut de connexion
      ever(_socketService.isConnectedRx, (connected) {
        _connectionStatus.value = connected ? 'connected' : 'disconnected';
        if (!connected) {}
      });

      // Écouter les erreurs Socket.IO
      _socketService.errorStream.listen((error) {
        _apiError.value = error;
      });

      // Écouter les confirmations de position
      _socketService.locationUpdateStream.listen((location) {});
    } catch (e) {
      _apiError.value = 'Erreur Socket.IO: $e';
    }
  }

  /// Gérer la mise à jour de position
  void _onLocationUpdate(Position position) {
    try {
      // Créer l'objet LocationData
      final locationData = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        speed: position.speed,
        heading: position.heading,
        timestamp: position.timestamp,
        status: _isLocationTracking.value ? 'en_cours' : 'en_pause',
      );

      // Mettre à jour la position actuelle
      _currentLocation.value = locationData;

      // Ajouter à l'historique local
      _addToHistory(locationData);

      // Envoyer au serveur si le suivi est actif
      if (_isLocationTracking.value) {
        _sendLocationToServer(locationData);
      }
    } catch (e) {
      _locationError.value = 'Erreur position: $e';
    }
  }

  /// Ajouter une position à l'historique local
  void _addToHistory(LocationData location) {
    _locationHistory.add(location);

    // Limiter la taille de l'historique
    if (_locationHistory.length > _maxHistorySize) {
      _locationHistory.removeAt(0);
    }
  }

  /// Envoyer la position au serveur
  Future<void> _sendLocationToServer(LocationData location) async {
    if (_isSendingLocation.value) return; // Éviter les envois multiples

    try {
      _isSendingLocation.value = true;

      // Récupérer le token d'authentification
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        _apiError.value = 'Token d\'authentification manquant';
        return;
      }

      // Récupérer l'ID du livreur
      final livreurId = await AuthStorage.getUserId() ?? 0;
      if (livreurId == 0) {
        _apiError.value = 'ID livreur manquant';
        return;
      }

      // Créer la requête
      final request = LocationUpdateRequest(
        livreurId: livreurId,
        latitude: location.latitude,
        longitude: location.longitude,
        accuracy: location.accuracy,
        altitude: location.altitude,
        speed: location.speed,
        heading: location.heading,
        timestamp: location.timestamp,
        status: location.status,
        contextType: _getCurrentContextType(),
        contextId: _getCurrentContextId(),
      );

      // Essayer d'abord Socket.IO
      if (_socketService.isConnected) {
        final success = await _socketService.sendLocation(request);
        if (success) {
          return;
        }
      }

      // Fallback sur l'API REST
      final response = await LocationApiService.updateLocationWithRetry(
        token: token,
        request: request,
        maxRetries: 2,
      );

      if (response.success) {
      } else {
        _apiError.value = response.message;
      }
    } catch (e) {
      _apiError.value = 'Erreur envoi position: $e';
    } finally {
      _isSendingLocation.value = false;
    }
  }

  /// Obtenir le type de contexte actuel
  String? _getCurrentContextType() {
    // TODO: Implémenter la logique pour déterminer le contexte
    // Retourner 'ramassage' ou 'livraison' selon la mission actuelle
    return null;
  }

  /// Obtenir l'ID du contexte actuel
  int? _getCurrentContextId() {
    // TODO: Implémenter la logique pour obtenir l'ID de la mission
    return null;
  }

  /// Démarrer le suivi de localisation
  Future<void> startLocationTracking() async {
    try {
      print('📍 LocationController - Démarrage du suivi de localisation');

      // Démarrer le service de localisation
      final success = await _locationService.startLocationTracking();
      if (!success) {
        _locationError.value = 'Impossible de démarrer le suivi GPS';
        print('❌ LocationController - Échec du démarrage du service');
        return;
      }

      // Mettre à jour manuellement l'état de suivi
      _isLocationTracking.value = true;
      print('✅ LocationController - Suivi de localisation activé');

      // Se connecter au Socket.IO
      await _socketService.connect();

      // Mettre à jour le statut
      await _updateLocationStatus('active');

      // Démarrer le timer d'envoi périodique
      _startLocationUpdateTimer();
    } catch (e) {
      print('❌ LocationController - Erreur démarrage suivi: $e');
      _locationError.value = 'Erreur démarrage suivi: $e';
    }
  }

  /// Arrêter le suivi de localisation
  Future<void> stopLocationTracking() async {
    try {
      print('📍 LocationController - Arrêt du suivi de localisation');

      // Arrêter le timer
      _locationUpdateTimer?.cancel();
      _locationUpdateTimer = null;

      // Mettre à jour manuellement l'état de suivi
      _isLocationTracking.value = false;
      print('✅ LocationController - Suivi de localisation arrêté');

      // Arrêter le service de localisation
      _locationService.stopLocationTracking();

      // Mettre à jour le statut
      await _updateLocationStatus('inactive');
    } catch (e) {
      print('❌ LocationController - Erreur arrêt suivi: $e');
      _locationError.value = 'Erreur arrêt suivi: $e';
    }
  }

  /// Démarrer le timer d'envoi périodique
  void _startLocationUpdateTimer() {
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = Timer.periodic(_updateInterval, (timer) {
      if (_isLocationTracking.value && _currentLocation.value != null) {
        _sendLocationToServer(_currentLocation.value!);
      }
    });
  }

  /// Mettre à jour le statut de localisation
  Future<void> _updateLocationStatus(String status) async {
    try {
      // Via Socket.IO
      if (_socketService.isConnected) {
        await _socketService.changeLocationStatus(status);
      }

      // Via API REST
      final token = await AuthStorage.getToken();
      if (token != null) {
        await LocationApiService.updateLocationStatus(
          token: token,
          status: status,
        );
      }
    } catch (e) {}
  }

  /// Forcer l'envoi de la position actuelle
  Future<void> forceSendCurrentLocation() async {
    if (_currentLocation.value != null) {
      await _sendLocationToServer(_currentLocation.value!);
    }
  }

  /// Charger l'historique des positions
  Future<void> loadLocationHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return;

      final response = await LocationApiService.getLocationHistory(
        token: token,
        startDate: startDate,
        endDate: endDate,
        limit: limit ?? 100,
      );

      if (response.success) {
        _locationHistory.clear();
        _locationHistory.addAll(response.data);
      }
    } catch (e) {
      _apiError.value = 'Erreur chargement historique: $e';
    }
  }

  /// Charger la mission actuelle
  Future<void> loadCurrentMission() async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return;

      final response = await LocationApiService.getCurrentMission(token: token);
      if (response.success && response.data != null) {
        _currentMission.value = response.data;
      }
    } catch (e) {
      _apiError.value = 'Erreur chargement mission: $e';
    }
  }

  /// Charger l'historique d'une mission
  Future<void> loadMissionHistory(String missionType, int missionId) async {
    try {
      final token = await AuthStorage.getToken();
      if (token == null) return;

      final response = await LocationApiService.getMissionHistory(
        token: token,
        missionType: missionType,
        missionId: missionId,
      );

      if (response.success && response.data != null) {
        _missionHistory.value = response.data;
      }
    } catch (e) {
      _apiError.value = 'Erreur chargement historique mission: $e';
    }
  }

  /// Obtenir le statut de connexion
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _socketService.isConnected,
      'status': _connectionStatus.value,
      'lastError': _apiError.value,
    };
  }

  /// Diagnostic de l'état
  void diagnosticState() {}
}
