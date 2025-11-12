import 'dart:math';

/// Modèle pour les données de localisation du livreur
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String? address;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.address,
  });

  /// Créer un LocationData à partir d'une Position de Geolocator
  factory LocationData.fromPosition(dynamic position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
    );
  }

  /// Convertir en Map pour l'API
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'address': address,
    };
  }

  /// Créer un LocationData à partir d'une Map
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      accuracy: map['accuracy']?.toDouble(),
      altitude: map['altitude']?.toDouble(),
      speed: map['speed']?.toDouble(),
      heading: map['heading']?.toDouble(),
      timestamp: DateTime.parse(map['timestamp']),
      address: map['address'],
    );
  }

  /// Copier avec de nouveaux paramètres
  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? address,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationData &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode;
  }
}

/// Modèle pour l'envoi de la position du livreur à l'API
class LocationUpdateRequest {
  final int livreurId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String? status; // 'en_cours', 'en_pause', 'termine'

  LocationUpdateRequest({
    required this.livreurId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.speed,
    this.heading,
    required this.timestamp,
    this.status,
  });

  /// Convertir en Map pour l'API
  Map<String, dynamic> toMap() {
    return {
      'livreur_id': livreurId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }

  @override
  String toString() {
    return 'LocationUpdateRequest(livreurId: $livreurId, lat: $latitude, lng: $longitude, status: $status)';
  }
}

/// Modèle pour la réponse de l'API lors de l'envoi de position
class LocationUpdateResponse {
  final bool success;
  final String message;
  final LocationData? locationData;
  final DateTime? serverTimestamp;

  LocationUpdateResponse({
    required this.success,
    required this.message,
    this.locationData,
    this.serverTimestamp,
  });

  /// Créer à partir d'une réponse API
  factory LocationUpdateResponse.fromMap(Map<String, dynamic> map) {
    return LocationUpdateResponse(
      success: map['success'] ?? false,
      message: map['message'] ?? '',
      locationData:
          map['location_data'] != null
              ? LocationData.fromMap(map['location_data'])
              : null,
      serverTimestamp:
          map['server_timestamp'] != null
              ? DateTime.parse(map['server_timestamp'])
              : null,
    );
  }

  @override
  String toString() {
    return 'LocationUpdateResponse(success: $success, message: $message)';
  }
}

/// Modèle pour l'historique des positions
class LocationHistory {
  final List<LocationData> positions;
  final DateTime startTime;
  final DateTime endTime;
  final double totalDistance;
  final Duration totalDuration;

  LocationHistory({
    required this.positions,
    required this.startTime,
    required this.endTime,
    required this.totalDistance,
    required this.totalDuration,
  });

  /// Calculer la distance totale parcourue
  static double calculateTotalDistance(List<LocationData> positions) {
    if (positions.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 1; i < positions.length; i++) {
      LocationData prev = positions[i - 1];
      LocationData current = positions[i];

      // Calcul simple de distance (formule de Haversine simplifiée)
      double latDiff =
          (current.latitude - prev.latitude) *
          111320; // 1 degré ≈ 111320 mètres
      double lngDiff =
          (current.longitude - prev.longitude) *
          111320 *
          (0.5 + 0.5 * (prev.latitude + current.latitude) / 90);

      totalDistance += sqrt(latDiff * latDiff + lngDiff * lngDiff);
    }

    return totalDistance;
  }

  @override
  String toString() {
    return 'LocationHistory(positions: ${positions.length}, distance: ${totalDistance.toStringAsFixed(2)}m, duration: $totalDuration)';
  }
}
