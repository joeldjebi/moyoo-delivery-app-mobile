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
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis-assignes',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

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

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return DeliveryResponse.fromJson(responseData);
        } catch (e) {
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
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
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
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/start-delivery',
      );

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      final request = http.Request('POST', uri);
      request.headers.addAll(headers);
      request.body = '';

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
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
          throw Exception(
            'Erreur de connexion. Vérifiez votre connexion internet.',
          );
        }
      }
    } on SocketException {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
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

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
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
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
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
        '🔍 [DeliveryService] getColisDetails() - Début, colisId: $colisId',
      );
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/details',
      );

      print('🔍 [DeliveryService] URL: $uri');

      final headers = {
        'accept': 'application/json',
        'Content-Type': 'application/json',
        'X-CSRF-TOKEN': '',
        'Authorization': 'Bearer $token',
      };

      final request = http.Request('GET', uri);
      request.headers.addAll(headers);

      print('🔍 [DeliveryService] Envoi de la requête...');
      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);
      print('🔍 [DeliveryService] Réponse reçue:');
      print('   - statusCode: ${response.statusCode}');
      print('   - body length: ${response.body.length}');

      if (response.statusCode == 200) {
        try {
          print('🔍 [DeliveryService] Parsing de la réponse JSON...');
          final responseData = jsonDecode(response.body);
          print('🔍 [DeliveryService] JSON parsé avec succès');
          print(
            '🔍 [DeliveryService] Données: success=${responseData['success']}, message=${responseData['message']}',
          );
          final result = DeliveryDetailResponse.fromJson(responseData);
          print('🔍 [DeliveryService] DeliveryDetailResponse créé avec succès');
          return result;
        } catch (e, stackTrace) {
          print('❌ [DeliveryService] Erreur lors du parsing: $e');
          print('❌ [DeliveryService] Stack trace: $stackTrace');
          print('❌ [DeliveryService] Body: ${response.body}');
          throw Exception('Erreur lors du parsing de la réponse: $e');
        }
      } else if (response.statusCode == 401) {
        print('❌ [DeliveryService] Token expiré (401)');
        throw Exception('Token expiré');
      } else {
        print('❌ [DeliveryService] Erreur HTTP: ${response.statusCode}');
        print('❌ [DeliveryService] Body: ${response.body}');
        throw Exception(
          'Erreur de connexion. Vérifiez votre connexion internet.',
        );
      }
    } on SocketException {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
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
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}/api/livreur/colis/$colisId/complete-delivery',
      );

      final headers = {
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

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
          throw Exception('Erreur lors de l\'ajout de la photo: $e');
        }
      }

      final streamedResponse = await request.send().timeout(
        ApiConstants.connectTimeout,
        onTimeout:
            () =>
                throw TimeoutException(
                  'La requête a pris trop de temps pour se connecter.',
                ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData;
        } catch (e) {
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
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on TimeoutException catch (e) {
      throw Exception('La requête a pris trop de temps pour se connecter.');
    } catch (e) {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }
}
