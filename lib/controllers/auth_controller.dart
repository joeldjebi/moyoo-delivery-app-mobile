import 'package:get/get.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/notification_manager_service.dart';
import '../storage/auth_storage.dart';
import 'ramassage_controller.dart';

class AuthController extends GetxController {
  // Variables observables
  final RxBool _isLoading = false.obs;
  final RxBool _isLoggedIn = false.obs;
  final RxString _errorMessage = ''.obs;
  final Rx<Livreur?> _currentLivreur = Rx<Livreur?>(null);
  final RxString _authToken = ''.obs;

  // Getters
  bool get isLoading => _isLoading.value;
  bool get isLoggedIn => _isLoggedIn.value;
  String get errorMessage => _errorMessage.value;
  Rx<Livreur?> get currentLivreur => _currentLivreur;
  String get authToken => _authToken.value;

  @override
  void onInit() {
    super.onInit();
    _checkAuthStatus();
  }

  /// Vérifier le statut d'authentification au démarrage
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await AuthStorage.isLoggedIn();
      if (isLoggedIn) {
        final token = await AuthStorage.getToken();
        final livreur = await AuthStorage.getLivreur();

        if (token != null && livreur != null) {
          _authToken.value = token;
          _currentLivreur.value = livreur;
          _isLoggedIn.value = true;

          // Vérifier si le profil stocké est complet (a des communes)
          // Si pas complet, récupérer le profil détaillé
          if (livreur.communes == null || livreur.communes!.isEmpty) {
            await fetchProfile();
          }
        } else {
          await _logout();
        }
      }
    } catch (e) {
      await _logout();
    }
  }

  /// Connexion du livreur
  Future<bool> login({required String mobile, required String password}) async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final response = await AuthService.login(
        mobile: mobile,
        password: password,
      );

      if (response.success) {
        // Récupérer le profil détaillé immédiatement après la connexion
        final detailedProfile = await AuthService.getProfile(
          response.data.token,
        );

        // Utiliser le profil détaillé s'il est disponible, sinon utiliser les données de base
        final profileToSave = detailedProfile ?? response.data.livreur;

        // Créer un AuthData avec le profil complet
        final completeAuthData = AuthData(
          token: response.data.token,
          refreshToken: response.data.refreshToken,
          tokenType: response.data.tokenType,
          expiresIn: response.data.expiresIn,
          refreshExpiresIn: response.data.refreshExpiresIn,
          livreur: profileToSave,
        );

        // Sauvegarder les données complètes d'authentification
        await AuthStorage.saveAuthData(completeAuthData);

        // Mettre à jour l'état avec le profil complet
        _authToken.value = response.data.token;
        _currentLivreur.value = profileToSave;
        _isLoggedIn.value = true;

        // Notifier le RamassageController que l'utilisateur est connecté
        try {
          final ramassageController = Get.find<RamassageController>();
          ramassageController.onUserLoggedIn();
        } catch (e) {
          // Le contrôleur n'est pas encore initialisé, ce n'est pas grave
        }

        return true;
      } else {
        // Gérer le cas où la réponse indique un échec
        _errorMessage.value =
            response.message.isNotEmpty
                ? response.message
                : 'Échec de la connexion. Veuillez vérifier vos identifiants.';
        return false;
      }
    } on ApiError catch (e) {
      _errorMessage.value = e.message;
      return false;
    } catch (e) {
      // Vérifier si c'est une ApiError wrappée
      if (e.toString().contains('ApiError')) {
        // Extraire le message de l'ApiError
        final errorString = e.toString();
        final messageMatch = RegExp(
          r'message: ([^,]+)',
        ).firstMatch(errorString);
        if (messageMatch != null) {
          _errorMessage.value = messageMatch.group(1) ?? 'Erreur de connexion';
        } else {
          _errorMessage.value = 'Erreur de connexion';
        }
      } else {
        _errorMessage.value = 'Une erreur inattendue est survenue';
      }
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Déconnexion du livreur
  Future<void> logout() async {
    try {
      _isLoading.value = true;

      // Appeler l'API de déconnexion si un token existe
      if (_authToken.value.isNotEmpty) {
        await AuthService.logout(_authToken.value);
      }

      // Supprimer le token FCM du serveur
      if (_authToken.value.isNotEmpty) {
        try {
          final fcmResponse = await FcmService.deleteFcmToken(
            authToken: _authToken.value,
          );
        } catch (e) {
          // Ne pas faire échouer la déconnexion si la suppression du token FCM échoue
        }
      }

      // Vider les notifications locales
      try {
        final notificationManager = Get.find<NotificationManagerService>();
        await notificationManager.deleteAllNotifications();
      } catch (e) {
        // Ne pas faire échouer la déconnexion si la suppression des notifications échoue
      }

      // Nettoyer le stockage local
      await AuthStorage.clearAuthData();

      // Réinitialiser l'état
      _authToken.value = '';
      _currentLivreur.value = null;
      _isLoggedIn.value = false;
      _errorMessage.value = '';

      // Naviguer vers la page de login
      Get.offAllNamed('/login');
    } catch (e) {
      // Même en cas d'erreur, nettoyer l'état local
      await _logout();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Déconnexion locale (sans appel API)
  Future<void> _logout() async {
    // Vider les notifications locales
    try {
      final notificationManager = Get.find<NotificationManagerService>();
      await notificationManager.deleteAllNotifications();
    } catch (e) {
      // Ne pas faire échouer la déconnexion si la suppression des notifications échoue
    }

    await AuthStorage.clearAuthData();
    _authToken.value = '';
    _currentLivreur.value = null;
    _isLoggedIn.value = false;
    _errorMessage.value = '';
  }

  /// Rafraîchir le token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await AuthStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final newAuthData = await AuthService.refreshToken(refreshToken);
      if (newAuthData != null) {
        await AuthStorage.saveAuthData(newAuthData);
        _authToken.value = newAuthData.token;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Vérifier si le token est valide
  Future<bool> isTokenValid() async {
    if (_authToken.value.isEmpty) return false;

    try {
      return await AuthService.verifyToken(_authToken.value);
    } catch (e) {
      return false;
    }
  }

  /// Mettre à jour les informations du livreur
  Future<void> updateLivreurInfo(Livreur updatedLivreur) async {
    try {
      // Fusionner les données partielles avec les données complètes existantes
      final currentLivreur = _currentLivreur.value;
      if (currentLivreur != null) {
        // Créer un nouveau Livreur avec les données fusionnées
        final mergedLivreur = Livreur(
          id: updatedLivreur.id,
          nomComplet: updatedLivreur.nomComplet,
          firstName: updatedLivreur.firstName,
          lastName: updatedLivreur.lastName,
          mobile: updatedLivreur.mobile,
          email: updatedLivreur.email,
          adresse: updatedLivreur.adresse,
          permis:
              updatedLivreur.permis ??
              currentLivreur.permis, // Garder l'ancien si nouveau est null
          status: updatedLivreur.status,
          photo: updatedLivreur.photo,
          engin:
              updatedLivreur.engin ??
              currentLivreur.engin, // Garder l'ancien si nouveau est null
          zoneActivite:
              updatedLivreur.zoneActivite ?? currentLivreur.zoneActivite,
          communes:
              updatedLivreur.communes ??
              currentLivreur.communes, // Garder l'ancien si nouveau est null
          createdAt: updatedLivreur.createdAt ?? currentLivreur.createdAt,
          updatedAt: updatedLivreur.updatedAt ?? currentLivreur.updatedAt,
        );

        // Sauvegarder les données fusionnées
        await AuthStorage.updateLivreur(mergedLivreur);
        _currentLivreur.value = mergedLivreur;
      } else {
        // Si pas de données existantes, sauvegarder directement
        await AuthStorage.updateLivreur(updatedLivreur);
        _currentLivreur.value = updatedLivreur;
      }

      // Essayer de récupérer le profil complet en arrière-plan
      await fetchProfile();
    } catch (e) {
      _errorMessage.value = 'Erreur lors de la mise à jour du profil';
    }
  }

  /// Récupérer le profil détaillé du livreur (pour mise à jour manuelle)
  Future<void> fetchProfile() async {
    if (_authToken.value.isEmpty) return;

    try {
      _isLoading.value = true;

      final profile = await AuthService.getProfile(_authToken.value);

      if (profile != null) {
        _currentLivreur.value = profile;
        await AuthStorage.updateLivreur(profile);
      }
    } catch (e) {
    } finally {
      _isLoading.value = false;
    }
  }

  /// Forcer la mise à jour du profil (pour refresh manuel)
  Future<void> refreshProfile() async {
    await fetchProfile();
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage.value = '';
  }

  /// Obtenir le nom complet du livreur
  String get livreurName => _currentLivreur.value?.nomComplet ?? '';

  /// Obtenir le numéro de téléphone du livreur
  String get livreurMobile => _currentLivreur.value?.mobile ?? '';

  /// Obtenir le type d'engin du livreur
  String get livreurEnginType => _currentLivreur.value?.engin?.type ?? '';

  /// Vérifier si le livreur est actif
  bool get isLivreurActive => _currentLivreur.value?.status == 'actif';

  /// Obtenir l'adresse du livreur
  String get livreurAdresse => _currentLivreur.value?.adresse ?? '';

  /// Obtenir le numéro de permis
  String get livreurPermis => _currentLivreur.value?.permis ?? '';

  /// Obtenir la photo du livreur
  String? get livreurPhoto => _currentLivreur.value?.photo;

  /// Obtenir les communes du livreur
  List<Commune> get livreurCommunes => _currentLivreur.value?.communes ?? [];

  /// Obtenir les noms des communes
  List<String> get livreurCommunesNames =>
      _currentLivreur.value?.communes?.map((c) => c.libelle).toList() ?? [];

  /// Vérifier si le profil est complet (a toutes les informations détaillées)
  bool get isProfileComplete {
    final livreur = _currentLivreur.value;
    if (livreur == null) return false;

    // Vérifier si le profil a les informations détaillées
    return livreur.communes != null &&
        livreur.communes!.isNotEmpty &&
        livreur.adresse != null &&
        livreur.permis != null;
  }

  /// Obtenir un résumé du profil pour debug
  String get profileSummary {
    final livreur = _currentLivreur.value;
    if (livreur == null) return 'Aucun profil';

    return '${livreur.nomComplet} - ${livreur.mobile} - ${livreur.communes?.length ?? 0} communes';
  }
}
