import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import 'memory_storage.dart';

class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _livreurKey = 'livreur_data';
  static const String _isLoggedInKey = 'is_logged_in';

  /// Sauvegarder les données d'authentification
  static Future<void> saveAuthData(AuthData authData) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(_tokenKey, authData.token);
      await prefs.setString(_refreshTokenKey, authData.refreshToken);
      await prefs.setString(_livreurKey, jsonEncode(authData.livreur.toJson()));
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      print('Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      // Fallback vers le stockage en mémoire
      MemoryStorage.setString(_tokenKey, authData.token);
      MemoryStorage.setString(_refreshTokenKey, authData.refreshToken);
      MemoryStorage.setString(
        _livreurKey,
        jsonEncode(authData.livreur.toJson()),
      );
      MemoryStorage.setBool(_isLoggedInKey, true);
    }
  }

  /// Récupérer le token d'authentification
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      return MemoryStorage.getString(_tokenKey);
    }
  }

  /// Récupérer le refresh token
  static Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      print('Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      return MemoryStorage.getString(_refreshTokenKey);
    }
  }

  /// Récupérer les données du livreur
  static Future<Livreur?> getLivreur() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final livreurJson = prefs.getString(_livreurKey);

      if (livreurJson != null) {
        try {
          final livreurData = jsonDecode(livreurJson);
          return Livreur.fromJson(livreurData);
        } catch (e) {
          print('Erreur lors du décodage des données du livreur: $e');
          return null;
        }
      }

      return null;
    } catch (e) {
      print('Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      final livreurJson = MemoryStorage.getString(_livreurKey);

      if (livreurJson != null) {
        try {
          final livreurData = jsonDecode(livreurJson);
          return Livreur.fromJson(livreurData);
        } catch (e) {
          print('Erreur lors du décodage des données du livreur (mémoire): $e');
          return null;
        }
      }

      return null;
    }
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('Erreur SharedPreferences, utilisation du stockage mémoire: $e');
      return MemoryStorage.getBool(_isLoggedInKey) ?? false;
    }
  }

  /// Mettre à jour le token
  static Future<void> updateToken(String newToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, newToken);
    } catch (e) {
      print('Erreur lors de la mise à jour du token: $e');
    }
  }

  /// Mettre à jour les données du livreur
  static Future<void> updateLivreur(Livreur livreur) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_livreurKey, jsonEncode(livreur.toJson()));
    } catch (e) {
      print('Erreur lors de la mise à jour des données du livreur: $e');
    }
  }

  /// Supprimer toutes les données d'authentification
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_refreshTokenKey);
      await prefs.remove(_livreurKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Erreur SharedPreferences, nettoyage du stockage mémoire: $e');
    }

    // Nettoyer aussi le stockage mémoire
    MemoryStorage.remove(_tokenKey);
    MemoryStorage.remove(_refreshTokenKey);
    MemoryStorage.remove(_livreurKey);
    MemoryStorage.setBool(_isLoggedInKey, false);
  }

  /// Vérifier si le token est expiré
  static Future<bool> isTokenExpired() async {
    try {
      final token = await getToken();
      if (token == null) return true;

      // Décoder le JWT pour vérifier l'expiration
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = jsonDecode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) return true;

      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expirationDate);
    } catch (e) {
      print('Erreur lors de la vérification de l\'expiration du token: $e');
      return true;
    }
  }
}
