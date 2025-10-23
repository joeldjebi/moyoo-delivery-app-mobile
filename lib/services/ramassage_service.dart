import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/ramassage_models.dart';
import '../models/ramassage_detail_models.dart';
import '../models/start_ramassage_models.dart';

class RamassageService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _ramassagesEndpoint = ApiConstants.pickupsEndpoint;

  // Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'X-CSRF-TOKEN': '',
  };

  /// Récupérer la liste des ramassages
  static Future<RamassageResponse> getRamassages(String token) async {
    try {
      final url = Uri.parse('$_baseUrl$_ramassagesEndpoint');

      final response = await http.get(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return RamassageResponse.fromJson(responseData);
        } else {
          throw Exception(responseData['message'] ?? 'Erreur inconnue');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Token expiré. Veuillez vous reconnecter.');
      } else {
        throw Exception(responseData['message'] ?? 'Erreur serveur');
      }
    } on http.ClientException {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on FormatException {
      throw Exception('Erreur de format de réponse du serveur.');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Récupérer les détails d'un ramassage avec les colis liés
  static Future<RamassageDetailResponse> getRamassageDetails(
    int ramassageId,
    String token,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/livreur/ramassages/$ramassageId/details',
      );

      final response = await http.get(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return RamassageDetailResponse.fromJson(responseData);
        } else {
          throw Exception(responseData['message'] ?? 'Erreur inconnue');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Erreur serveur');
      }
    } on http.ClientException {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on FormatException {
      throw Exception('Erreur de format de réponse du serveur.');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }

  /// Démarrer un ramassage
  static Future<StartRamassageResponse> startRamassage(
    int ramassageId,
    String token,
  ) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/api/livreur/ramassages/$ramassageId/start',
      );

      final response = await http.post(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
        body: '', // Corps vide comme dans le curl
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['success'] == true) {
          return StartRamassageResponse.fromJson(responseData);
        } else {
          throw Exception(responseData['message'] ?? 'Erreur inconnue');
        }
      } else {
        throw Exception(responseData['message'] ?? 'Erreur serveur');
      }
    } on http.ClientException {
      throw Exception(
        'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on FormatException {
      throw Exception('Erreur de format de réponse du serveur.');
    } catch (e) {
      throw Exception('Erreur inattendue: ${e.toString()}');
    }
  }
}
