import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/delivery_models.dart';
import '../models/delivery_detail_models.dart';

class DeliveryService {
  /// Récupérer la liste des colis assignés pour livraison
  static Future<DeliveryResponse> getColisAssignes({
    required String token,
  }) async {
    try {
      print(
        '🔍 Service - URL: ${ApiConstants.baseUrl}/api/livreur/colis-assignes',
      );
      print('🔍 Service - Token: ${token.substring(0, 20)}...');

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis-assignes',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      print('🔍 Service - Headers: $headers');

      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Service - Status Code: ${response.statusCode}');
      print('🔍 Service - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return DeliveryResponse.fromJson(responseData);
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur lors du parsing de la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré');
      } else {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
    } on SocketException {
      print('❌ Erreur de connexion réseau');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      print('❌ Erreur lors de la récupération des colis: $e');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }

  /// Démarrer une livraison
  static Future<Map<String, dynamic>> startDelivery({
    required int colisId,
    required String token,
  }) async {
    try {
      print('🔍 Service - Démarrage de la livraison pour le colis: $colisId');
      print(
        '🔍 Service - URL: ${ApiConstants.baseUrl}/api/livreur/colis/$colisId/start-delivery',
      );

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/start-delivery',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      print('🔍 Service - Headers: $headers');

      final request = http.Request('POST', uri);
      request.headers.addAll(headers);
      request.body = ''; // Corps vide comme dans le curl

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Service - Status Code: ${response.statusCode}');
      print('🔍 Service - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur lors du parsing de la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré');
      } else {
        // Gérer les réponses d'erreur avec des informations détaillées
        try {
          final responseData = jsonDecode(response.body);
          return responseData; // Retourner la réponse même en cas d'erreur pour que le controller puisse la traiter
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse d\'erreur: $e');
          throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.',
          );
        }
      }
    } on SocketException {
      print('❌ Erreur de connexion réseau');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      print('❌ Erreur lors du démarrage de la livraison: $e');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }

  /// Annuler une livraison
  static Future<Map<String, dynamic>> cancelDelivery({
    required int colisId,
    required String motifAnnulation,
    required String noteLivraison,
    required String token,
  }) async {
    try {
      print('🔍 Service - Annulation de la livraison pour le colis: $colisId');
      print(
        '🔍 Service - URL: ${ApiConstants.baseUrl}/api/livreur/colis/$colisId/cancel-delivery',
      );

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/cancel-delivery',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      final body = {
        'motif_annulation': motifAnnulation,
        'note_livraison': noteLivraison,
      };

      print('🔍 Service - Headers: $headers');
      print('🔍 Service - Body: $body');

      final request = http.Request('POST', uri);
      request.headers.addAll(headers);
      request.body = jsonEncode(body);

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Service - Status Code: ${response.statusCode}');
      print('🔍 Service - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur lors du parsing de la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré');
      } else {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
    } on SocketException {
      print('❌ Erreur de connexion réseau');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      print('❌ Erreur lors de l\'annulation de la livraison: $e');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }

  /// Récupérer les détails d'un colis
  static Future<DeliveryDetailResponse> getColisDetails({
    required int colisId,
    required String token,
  }) async {
    try {
      print(
        '🔍 Service - URL: ${ApiConstants.baseUrl}/api/livreur/colis/$colisId/details',
      );
      print('🔍 Service - Token: ${token.substring(0, 20)}...');

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/details',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      print('🔍 Service - Headers: $headers');

      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Service - Status Code: ${response.statusCode}');
      print('🔍 Service - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return DeliveryDetailResponse.fromJson(responseData);
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur lors du parsing de la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré');
      } else {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
    } on SocketException {
      print('❌ Erreur de connexion réseau');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      print('❌ Erreur lors de la récupération des détails du colis: $e');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }

  static Future<Map<String, dynamic>> completeDelivery({
    required int colisId,
    required String codeValidation,
    required String noteLivraison,
    required String token,
    String? photoProof,
    String? signatureData,
    double? latitude,
    double? longitude,
  }) async {
    try {
      print(
        '🔍 Service - Finalisation de la livraison pour le colis: $colisId',
      );
      print(
        '🔍 Service - URL: ${ApiConstants.baseUrl}/api/livreur/colis/$colisId/complete-delivery',
      );

      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/complete-delivery',
      );

      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('🔍 Service - Headers: $headers');

      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Ajouter les champs requis
      request.fields['code_validation'] = codeValidation;
      request.fields['note_livraison'] = noteLivraison;

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }
      if (signatureData != null) {
        request.fields['signature_data'] = signatureData;
      }

      // Ajouter la photo si fournie
      if (photoProof != null && photoProof.isNotEmpty) {
        try {
          final file = File(photoProof);
          if (await file.exists()) {
            final multipartFile = await http.MultipartFile.fromPath(
              'photo_proof',
              photoProof,
              filename:
                  'photo_proof_${DateTime.now().millisecondsSinceEpoch}.jpg',
            );
            request.files.add(multipartFile);
          }
        } catch (e) {
          print('⚠️ Erreur lors de l\'ajout de la photo: $e');
        }
      }

      print('🔍 Service - Champs: ${request.fields}');
      print('🔍 Service - Fichiers: ${request.files.length}');

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Service - Status Code: ${response.statusCode}');
      print('🔍 Service - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          throw Exception('Erreur lors du parsing de la réponse');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré');
      } else {
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
    } on SocketException {
      print('❌ Erreur de connexion réseau');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      print('❌ Timeout: $e');
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      print('❌ Erreur lors de la finalisation de la livraison: $e');
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }
}
