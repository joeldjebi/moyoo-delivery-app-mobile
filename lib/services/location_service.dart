import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

/// Service de géolocalisation pour le suivi des livreurs
class LocationService extends GetxService {
  static LocationService get instance => Get.find<LocationService>();

  // Stream de position
  final Rx<Position?> _currentPosition = Rx<Position?>(null);
  final RxBool _isLocationEnabled = false.obs;
  final RxBool _isTracking = false.obs;
  final RxString _locationError = ''.obs;

  // Stream subscription pour le suivi en temps réel
  StreamSubscription<Position>? _positionStreamSubscription;

  // Getters
  Position? get currentPosition => _currentPosition.value;
  bool get isLocationEnabled => _isLocationEnabled.value;
  bool get isTracking => _isTracking.value;
  String get locationError => _locationError.value;

  // Getters pour les observables (pour l'écoute des changements)
  RxBool get isLocationEnabledRx => _isLocationEnabled;
  RxBool get isTrackingRx => _isTracking;
  RxString get locationErrorRx => _locationError;

  // Stream observable pour écouter les changements de position
  Stream<Position?> get positionStream => _currentPosition.stream;

  @override
  void onInit() {
    super.onInit();
    _checkLocationService();
  }

  @override
  void onClose() {
    stopLocationTracking();
    super.onClose();
  }

  /// Vérifier si le service de localisation est activé
  Future<bool> _checkLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      _isLocationEnabled.value = serviceEnabled;

      if (!serviceEnabled) {
        _locationError.value = 'Le service de localisation est désactivé';
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError.value = 'Permission de localisation refusée';
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError.value =
            'Permission de localisation définitivement refusée';
        return false;
      }

      _locationError.value = '';
      return true;
    } catch (e) {
      _locationError.value = 'Erreur: $e';
      return false;
    }
  }

  /// Obtenir la position actuelle
  Future<Position?> getCurrentPosition() async {
    try {
      bool serviceReady = await _checkLocationService();
      if (!serviceReady) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy:
            LocationAccuracy
                .high, // Augmenter la précision pour une meilleure localisation
        timeLimit: const Duration(
          seconds: 30,
        ), // Augmenter le timeout pour une meilleure précision
      );

      _currentPosition.value = position;
      _locationError.value = '';

      return position;
    } catch (e) {
      _locationError.value = 'Erreur: $e';
      return null;
    }
  }

  /// Démarrer le suivi de position en temps réel
  Future<bool> startLocationTracking({
    Duration interval = const Duration(seconds: 10),
    double distanceFilter = 10.0, // en mètres
  }) async {
    try {
      bool serviceReady = await _checkLocationService();
      if (!serviceReady) {
        return false;
      }

      // Arrêter le suivi précédent s'il existe
      await stopLocationTracking();

      // Obtenir la position initiale
      Position? initialPosition = await getCurrentPosition();
      if (initialPosition == null) {
        return false;
      }

      // Démarrer le stream de position
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: distanceFilter.toInt(),
          // Supprimer le timeLimit pour éviter les timeouts
        ),
      ).listen(
        (Position position) {
          _currentPosition.value = position;
          _locationError.value = '';
        },
        onError: (error) {
          _locationError.value = 'Erreur de suivi: $error';

          // Si c'est un timeout, essayer de redémarrer le stream
          if (error.toString().contains('TimeoutException')) {
            _restartPositionStream();
          }
        },
      );

      _isTracking.value = true;
      return true;
    } catch (e) {
      _locationError.value = 'Erreur: $e';
      return false;
    }
  }

  /// Arrêter le suivi de position
  Future<void> stopLocationTracking() async {
    try {
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;
      _isTracking.value = false;
    } catch (e) {}
  }

  /// Calculer la distance entre deux positions
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculer la distance entre la position actuelle et une position donnée
  double? calculateDistanceTo(double latitude, double longitude) {
    if (_currentPosition.value == null) return null;

    return calculateDistance(
      _currentPosition.value!.latitude,
      _currentPosition.value!.longitude,
      latitude,
      longitude,
    );
  }

  /// Obtenir l'adresse à partir des coordonnées (géocodage inverse)
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      // Note: Pour le géocodage inverse, vous devrez utiliser un service comme Google Places API
      // ou OpenStreetMap Nominatim. Ici, on retourne juste les coordonnées formatées
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si la position est valide (pas trop ancienne)
  bool isPositionValid(
    Position? position, {
    Duration maxAge = const Duration(minutes: 5),
  }) {
    if (position == null) return false;

    DateTime now = DateTime.now();
    DateTime positionTime = position.timestamp;
    Duration age = now.difference(positionTime);

    return age <= maxAge;
  }

  /// Obtenir la position la plus récente valide
  Position? getValidCurrentPosition() {
    if (isPositionValid(_currentPosition.value)) {
      return _currentPosition.value;
    }
    return null;
  }

  /// Forcer la mise à jour de la position
  Future<Position?> forceUpdatePosition() async {
    return await getCurrentPosition();
  }

  /// Redémarrer le stream de position après une erreur
  Future<void> _restartPositionStream() async {
    try {
      // Arrêter le stream actuel
      await _positionStreamSubscription?.cancel();
      _positionStreamSubscription = null;

      // Attendre un court délai
      await Future.delayed(const Duration(seconds: 2));

      // Redémarrer le stream si le suivi est toujours actif
      if (_isTracking.value) {
        _positionStreamSubscription = Geolocator.getPositionStream(
          locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen(
          (Position position) {
            _currentPosition.value = position;
            _locationError.value = '';
          },
          onError: (error) {
            _locationError.value = 'Erreur de suivi: $error';
          },
        );
      }
    } catch (e) {
      _locationError.value = 'Erreur de redémarrage: $e';
    }
  }

  /// Diagnostic de l'état du service
  void diagnosticState() {}
}
