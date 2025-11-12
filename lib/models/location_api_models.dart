/// Modèle pour les données de localisation du livreur (format API)
class LocationData {
  final int? id;
  final int? livreurId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String status;
  final String? address;

  LocationData({
    this.id,
    this.livreurId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.status = 'en_cours',
    this.address,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'] as int?,
      livreurId: json['livreur_id'] as int?,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      accuracy:
          json['accuracy'] != null
              ? double.parse(json['accuracy'].toString())
              : null,
      altitude:
          json['altitude'] != null
              ? double.parse(json['altitude'].toString())
              : null,
      speed:
          json['speed'] != null ? double.parse(json['speed'].toString()) : null,
      heading:
          json['heading'] != null
              ? double.parse(json['heading'].toString())
              : null,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: json['status'] as String? ?? 'en_cours',
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'livreur_id': livreurId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'address': address,
    };
  }
}

/// Modèle pour la requête de mise à jour de position
class LocationUpdateRequest {
  final int livreurId;
  final int? entrepriseId;
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final double? speed;
  final double? heading;
  final DateTime timestamp;
  final String status;
  final String? contextType; // 'ramassage' ou 'livraison'
  final int? contextId;
  final int? ramassageId;
  final int? historiqueLivraisonId;

  LocationUpdateRequest({
    required this.livreurId,
    this.entrepriseId,
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.status = 'en_cours',
    this.contextType,
    this.contextId,
    this.ramassageId,
    this.historiqueLivraisonId,
  });

  Map<String, dynamic> toJson() {
    return {
      'livreur_id': livreurId,
      'entreprise_id': entrepriseId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'context_type': contextType,
      'context_id': contextId,
      'ramassage_id': ramassageId,
      'historique_livraison_id': historiqueLivraisonId,
    };
  }
}

/// Modèle pour la réponse de mise à jour de position
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

  factory LocationUpdateResponse.fromJson(Map<String, dynamic> json) {
    return LocationUpdateResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      locationData:
          json['location_data'] != null
              ? LocationData.fromJson(
                json['location_data'] as Map<String, dynamic>,
              )
              : null,
      serverTimestamp:
          json['server_timestamp'] != null
              ? DateTime.parse(json['server_timestamp'] as String)
              : null,
    );
  }
}

/// Modèle pour l'historique des positions
class LocationHistoryResponse {
  final bool success;
  final List<LocationData> data;
  final int count;
  final Map<String, dynamic>? filters;

  LocationHistoryResponse({
    required this.success,
    required this.data,
    required this.count,
    this.filters,
  });

  factory LocationHistoryResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List<dynamic>;
    final List<LocationData> locations =
        dataList
            .map((item) => LocationData.fromJson(item as Map<String, dynamic>))
            .toList();

    return LocationHistoryResponse(
      success: json['success'] as bool,
      data: locations,
      count: json['count'] as int,
      filters: json['filters'] as Map<String, dynamic>?,
    );
  }
}

/// Modèle pour le statut de localisation
class LocationStatus {
  final int livreurId;
  final String status; // 'active', 'inactive', 'paused'
  final DateTime lastUpdated;
  final String? socketId;

  LocationStatus({
    required this.livreurId,
    required this.status,
    required this.lastUpdated,
    this.socketId,
  });

  factory LocationStatus.fromJson(Map<String, dynamic> json) {
    return LocationStatus(
      livreurId: json['livreur_id'] as int,
      status: json['status'] as String,
      lastUpdated: DateTime.parse(json['last_updated'] as String),
      socketId: json['socket_id'] as String?,
    );
  }
}

/// Modèle pour la réponse du statut
class LocationStatusResponse {
  final bool success;
  final LocationStatus? data;
  final String? message;

  LocationStatusResponse({required this.success, this.data, this.message});

  factory LocationStatusResponse.fromJson(Map<String, dynamic> json) {
    return LocationStatusResponse(
      success: json['success'] as bool,
      data:
          json['data'] != null
              ? LocationStatus.fromJson(json['data'] as Map<String, dynamic>)
              : null,
      message: json['message'] as String?,
    );
  }
}

/// Modèle pour la mission actuelle
class CurrentMission {
  final int livreurId;
  final Mission? mission;
  final LocationData? lastPosition;

  CurrentMission({required this.livreurId, this.mission, this.lastPosition});

  factory CurrentMission.fromJson(Map<String, dynamic> json) {
    return CurrentMission(
      livreurId: json['livreur_id'] as int,
      mission:
          json['mission'] != null
              ? Mission.fromJson(json['mission'] as Map<String, dynamic>)
              : null,
      lastPosition:
          json['last_position'] != null
              ? LocationData.fromJson(
                json['last_position'] as Map<String, dynamic>,
              )
              : null,
    );
  }
}

/// Modèle pour une mission
class Mission {
  final String type; // 'ramassage' ou 'livraison'
  final int id;
  final String code;
  final String adresse;
  final String client;
  final String telephone;

  Mission({
    required this.type,
    required this.id,
    required this.code,
    required this.adresse,
    required this.client,
    required this.telephone,
  });

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      type: json['type'] as String,
      id: json['id'] as int,
      code: json['code'] as String,
      adresse: json['adresse'] as String,
      client: json['client'] as String,
      telephone: json['telephone'] as String,
    );
  }
}

/// Modèle pour la réponse de mission actuelle
class CurrentMissionResponse {
  final bool success;
  final String? message;
  final CurrentMission? data;

  CurrentMissionResponse({required this.success, this.message, this.data});

  factory CurrentMissionResponse.fromJson(Map<String, dynamic> json) {
    return CurrentMissionResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
      data:
          json['data'] != null
              ? CurrentMission.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }
}

/// Modèle pour l'historique d'une mission
class MissionHistory {
  final Mission mission;
  final List<LocationData> positions;
  final int count;
  final double distanceTotal;
  final Duration dureeTotal;

  MissionHistory({
    required this.mission,
    required this.positions,
    required this.count,
    required this.distanceTotal,
    required this.dureeTotal,
  });

  factory MissionHistory.fromJson(Map<String, dynamic> json) {
    final List<dynamic> positionsList = json['positions'] as List<dynamic>;
    final List<LocationData> positions =
        positionsList
            .map((item) => LocationData.fromJson(item as Map<String, dynamic>))
            .toList();

    return MissionHistory(
      mission: Mission.fromJson(json['mission'] as Map<String, dynamic>),
      positions: positions,
      count: json['count'] as int,
      distanceTotal: (json['distance_total'] as num).toDouble(),
      dureeTotal: _parseDuration(json['duree_total'] as String),
    );
  }

  static Duration _parseDuration(String duration) {
    final parts = duration.split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return Duration(hours: hours, minutes: minutes, seconds: seconds);
    }
    return Duration.zero;
  }
}

/// Modèle pour la réponse de l'historique de mission
class MissionHistoryResponse {
  final bool success;
  final MissionHistory? data;

  MissionHistoryResponse({required this.success, this.data});

  factory MissionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return MissionHistoryResponse(
      success: json['success'] as bool,
      data:
          json['data'] != null
              ? MissionHistory.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }
}
