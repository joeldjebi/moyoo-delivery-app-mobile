import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/location_api_models.dart';

/// Service pour les appels API de localisation
class LocationApiService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const Duration _timeout = ApiConstants.connectTimeout;

  /// Envoyer une position au serveur
  static Future<LocationUpdateResponse> updateLocation({
    required String token,
    required LocationUpdateRequest request,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl${ApiConstants.locationUpdateEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationUpdateResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return LocationUpdateResponse(
          success: false,
          message:
              errorData['message'] ?? 'Erreur lors de l\'envoi de la position',
        );
      }
    } catch (e) {
      return LocationUpdateResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  /// Récupérer l'historique des positions
  static Future<LocationHistoryResponse> getLocationHistory({
    required String token,
    int? livreurId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    String? status,
    String? contextType,
    int? contextId,
    String? missionType,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (livreurId != null) queryParams['livreur_id'] = livreurId.toString();
      if (startDate != null)
        queryParams['start_date'] = startDate.toIso8601String().split('T')[0];
      if (endDate != null)
        queryParams['end_date'] = endDate.toIso8601String().split('T')[0];
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (contextType != null) queryParams['context_type'] = contextType;
      if (contextId != null) queryParams['context_id'] = contextId.toString();
      if (missionType != null) queryParams['mission_type'] = missionType;

      final uri = Uri.parse(
        '$_baseUrl${ApiConstants.locationHistoryEndpoint}',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationHistoryResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return LocationHistoryResponse(success: false, data: [], count: 0);
      }
    } catch (e) {
      return LocationHistoryResponse(success: false, data: [], count: 0);
    }
  }

  /// Mettre à jour le statut de localisation
  static Future<LocationStatusResponse> updateLocationStatus({
    required String token,
    required String status, // 'active', 'inactive', 'paused'
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl${ApiConstants.locationStatusEndpoint}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
            body: jsonEncode({'status': status}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationStatusResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return LocationStatusResponse(
          success: false,
          message:
              errorData['message'] ?? 'Erreur lors de la mise à jour du statut',
        );
      }
    } catch (e) {
      return LocationStatusResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  /// Récupérer le statut actuel de localisation
  static Future<LocationStatusResponse> getLocationStatus({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl${ApiConstants.locationStatusEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return LocationStatusResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return LocationStatusResponse(
          success: false,
          message:
              errorData['message'] ??
              'Erreur lors de la récupération du statut',
        );
      }
    } catch (e) {
      return LocationStatusResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  /// Récupérer la mission actuelle du livreur
  static Future<CurrentMissionResponse> getCurrentMission({
    required String token,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl${ApiConstants.currentMissionEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return CurrentMissionResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return CurrentMissionResponse(
          success: false,
          message:
              errorData['message'] ??
              'Erreur lors de la récupération de la mission',
        );
      }
    } catch (e) {
      return CurrentMissionResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  /// Récupérer l'historique des positions pour une mission spécifique
  static Future<MissionHistoryResponse> getMissionHistory({
    required String token,
    required String missionType, // 'ramassage' ou 'livraison'
    required int missionId,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {};
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse(
        '$_baseUrl${ApiConstants.missionHistoryEndpoint}/$missionType/$missionId',
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(
            uri,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return MissionHistoryResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        return MissionHistoryResponse(success: false);
      }
    } catch (e) {
      return MissionHistoryResponse(success: false);
    }
  }

  /// Envoyer une position avec retry automatique
  static Future<LocationUpdateResponse> updateLocationWithRetry({
    required String token,
    required LocationUpdateRequest request,
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final response = await updateLocation(token: token, request: request);

        if (response.success) {
          return response;
        }

        // Si ce n'est pas le dernier essai, attendre avant de réessayer
        if (attempt < maxRetries) {
          await Future.delayed(retryDelay);
        }
      } catch (e) {
        if (attempt == maxRetries) {
          return LocationUpdateResponse(
            success: false,
            message: 'Échec après $maxRetries tentatives: $e',
          );
        }
        await Future.delayed(retryDelay);
      }
    }

    return LocationUpdateResponse(
      success: false,
      message: 'Échec après $maxRetries tentatives',
    );
  }
}
