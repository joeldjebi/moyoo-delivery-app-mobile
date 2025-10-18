import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../constants/api_constants.dart';
import '../models/complete_ramassage_models.dart';

class CompleteRamassageService {
  static const String _baseUrl = ApiConstants.baseUrl;

  /// Finaliser un ramassage avec photos et informations
  static Future<CompleteRamassageResponse> completeRamassage({
    required int ramassageId,
    required int nombreColisReel,
    String? notesRamassage,
    String? raisonDifference,
    required List<String> photosPaths,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/livreur/ramassages/$ramassageId/complete',
      );

      // Créer la requête multipart
      var request = http.MultipartRequest('POST', url);

      // Ajouter les headers
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-CSRF-TOKEN': '',
      });

      // Ajouter les champs de formulaire
      request.fields['nombre_colis_reel'] = nombreColisReel.toString();

      if (notesRamassage != null && notesRamassage.isNotEmpty) {
        request.fields['notes_ramassage'] = notesRamassage;
      }

      if (raisonDifference != null && raisonDifference.isNotEmpty) {
        request.fields['raison_difference'] = raisonDifference;
      }

      // Ajouter les photos
      for (String photoPath in photosPaths) {
        final file = File(photoPath);
        if (await file.exists()) {
          final fileName = path.basename(photoPath);

          request.files.add(
            await http.MultipartFile.fromPath(
              'photos_colis[]',
              photoPath,
              filename: fileName,
            ),
          );
        }
      }

      print('🔍 Envoi de la requête de finalisation du ramassage $ramassageId');
      print('🔍 Nombre de colis réel: $nombreColisReel');
      print('🔍 Nombre de photos: ${photosPaths.length}');
      print('🔍 Notes: $notesRamassage');
      print('🔍 Raison différence: $raisonDifference');

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body------>: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          final success = responseData['success'] ?? false;
          final message =
              responseData['message'] ?? 'Ramassage finalisé avec succès';

          return CompleteRamassageResponse(success: success, message: message);
        } catch (e) {
          print('❌ Erreur lors du parsing de la réponse: $e');
          return CompleteRamassageResponse(
            success: false,
            message: 'Erreur lors du parsing de la réponse',
          );
        }
      } else {
        return CompleteRamassageResponse(
          success: false,
          message: 'Erreur lors de la finalisation du ramassage',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la finalisation du ramassage: $e');
      return CompleteRamassageResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}
