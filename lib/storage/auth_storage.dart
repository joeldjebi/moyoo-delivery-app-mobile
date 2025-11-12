import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';

/// Service de stockage pour l'authentification
class AuthStorage {
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';

  /// Sauvegarder le token d'authentification
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Supprimer le token d'authentification
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  /// Sauvegarder le refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  /// Récupérer le refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  /// Sauvegarder l'ID utilisateur
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_userIdKey, userId);
  }

  /// Récupérer l'ID utilisateur
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_userIdKey);
  }

  /// Sauvegarder le nom utilisateur
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, userName);
  }

  /// Récupérer le nom utilisateur
  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey);
  }

  /// Sauvegarder l'email utilisateur
  static Future<void> saveUserEmail(String userEmail) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userEmailKey, userEmail);
  }

  /// Récupérer l'email utilisateur
  static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userEmailKey);
  }

  /// Sauvegarder les données complètes d'authentification
  static Future<void> saveAuthData(AuthData authData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, authData.token);
    await prefs.setString(_refreshTokenKey, authData.refreshToken);
    await prefs.setInt(_userIdKey, authData.livreur.id);
    await prefs.setString(_userNameKey, authData.livreur.nomComplet);
    if (authData.livreur.email != null) {
      await prefs.setString(_userEmailKey, authData.livreur.email!);
    }
  }

  /// Récupérer les données d'authentification complètes
  static Future<AuthData?> getAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userId = prefs.getInt(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);

    if (token != null && userId != null && userName != null) {
      final livreur = Livreur(
        id: userId,
        nomComplet: userName,
        email: userEmail,
        mobile: '', // À récupérer depuis l'API si nécessaire
        status: 'actif', // Valeur par défaut
      );

      return AuthData(
        token: token,
        refreshToken: '', // Valeur par défaut
        tokenType: 'Bearer',
        expiresIn: 3600,
        refreshExpiresIn: 7200,
        livreur: livreur,
      );
    }
    return null;
  }

  /// Mettre à jour les informations du livreur
  static Future<void> updateLivreur(Livreur livreur) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, livreur.nomComplet);
    if (livreur.email != null) {
      await prefs.setString(_userEmailKey, livreur.email!);
    }
  }

  /// Récupérer le livreur stocké
  static Future<Livreur?> getLivreur() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_userIdKey);
    final userName = prefs.getString(_userNameKey);
    final userEmail = prefs.getString(_userEmailKey);

    if (userId != null && userName != null) {
      return Livreur(
        id: userId,
        nomComplet: userName,
        email: userEmail,
        mobile: '', // À récupérer depuis l'API si nécessaire
        status: 'actif', // Valeur par défaut
      );
    }
    return null;
  }

  /// Nettoyer toutes les données d'authentification
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }

  /// Vérifier si l'utilisateur est connecté
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Déconnexion complète
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_userEmailKey);
  }
}
