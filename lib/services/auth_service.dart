import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../constants/api_constants.dart';

class AuthService {
  static const String _baseUrl = ApiConstants.baseUrl;
  static const String _loginEndpoint = '/api/livreur/login';

  // Headers par défaut
  static Map<String, String> get _defaultHeaders => {
    'accept': 'application/json',
    'Content-Type': 'application/json',
    'X-CSRF-TOKEN': '',
  };

  /// Authentification du livreur
  static Future<LoginResponse> login({
    required String mobile,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl$_loginEndpoint');
      print('🔍 Tentative de connexion vers: $url');
      print('🔍 Mobile: $mobile');
      print('🔍 Headers: $_defaultHeaders');

      // Envoyer le mot de passe en clair (comme dans le curl qui fonctionne)
      print('🔍 Mot de passe: $password');

      final request = LoginRequest(mobile: mobile, password: password);
      print('🔍 Request Body: ${jsonEncode(request.toJson())}');

      final response = await http.post(
        url,
        headers: _defaultHeaders,
        body: jsonEncode(request.toJson()),
      );

      print('🔍 Status Code: ${response.statusCode}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Connexion réussie');
        return LoginResponse.fromJson(responseData);
      } else {
        print('❌ Erreur de connexion - Status: ${response.statusCode}');
        print('❌ Response Data: $responseData');

        // Extraire le message d'erreur de la réponse
        String errorMessage = 'Erreur de connexion';
        if (responseData is Map<String, dynamic>) {
          errorMessage =
              responseData['message'] ??
              responseData['error'] ??
              'Erreur de connexion';
        }

        // Retourner une LoginResponse avec success: false au lieu de lancer une exception
        return LoginResponse(
          success: false,
          message: errorMessage,
          data: AuthData(
            token: '',
            refreshToken: '',
            tokenType: '',
            expiresIn: 0,
            refreshExpiresIn: 0,
            livreur: Livreur(
              id: 0,
              nomComplet: '',
              mobile: '',
              email: '',
              adresse: '',
              permis: '',
              status: '',
              photo: '',
              engin: null,
              zoneActivite: null,
              communes: null,
              createdAt: '',
              updatedAt: '',
            ),
          ),
        );
      }
    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      throw ApiError(
        message: 'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    } on FormatException catch (e) {
      print('❌ FormatException: $e');
      throw ApiError(message: 'Erreur de format de réponse du serveur.');
    } catch (e) {
      print('❌ Erreur inattendue: $e');
      throw ApiError(message: 'Erreur inattendue: ${e.toString()}');
    }
  }

  /// Vérification de la validité du token
  static Future<bool> verifyToken(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/livreur/verify-token');

      final response = await http.get(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Rafraîchissement du token
  static Future<AuthData?> refreshToken(String refreshToken) async {
    try {
      final url = Uri.parse('$_baseUrl/api/livreur/refresh-token');

      final response = await http.post(
        url,
        headers: _defaultHeaders,
        body: jsonEncode({'refresh_token': refreshToken}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthData.fromJson(responseData['data']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Déconnexion
  static Future<bool> logout(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/livreur/logout');

      final response = await http.post(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Récupérer le profil détaillé du livreur
  static Future<Livreur?> getProfile(String token) async {
    try {
      final url = Uri.parse('$_baseUrl/api/livreur/profile');

      final response = await http.get(
        url,
        headers: {..._defaultHeaders, 'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return Livreur.fromJson(responseData['data']);
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la récupération du profil: $e');
      return null;
    }
  }

  /// Mettre à jour le profil du livreur
  static Future<Livreur?> updateProfile({
    required String token,
    required String firstName,
    required String lastName,
    required String email,
    required String address,
    required String permis,
    File? photo,
  }) async {
    try {
      final url = Uri.parse('$_baseUrl/api/livreur/profile');

      // Créer une requête multipart
      final request = http.MultipartRequest('POST', url);

      // Ajouter les headers
      request.headers.addAll({
        'accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-CSRF-TOKEN': '',
      });

      // Ajouter les champs de formulaire
      request.fields['first_name'] = firstName;
      request.fields['last_name'] = lastName;
      request.fields['email'] = email;
      request.fields['adresse'] = address;
      request.fields['permis'] = permis;

      // Ajouter la photo si fournie
      if (photo != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'photo',
            photo.path,
            filename: photo.path.split('/').last,
          ),
        );
      }

      // Envoyer la requête
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['success'] == true) {
          return Livreur.fromJson(responseData['data']);
        }
      }

      return null;
    } catch (e) {
      print('Erreur lors de la mise à jour du profil: $e');
      return null;
    }
  }
}
