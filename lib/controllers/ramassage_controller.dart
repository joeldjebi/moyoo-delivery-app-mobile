import 'package:get/get.dart';
import '../services/ramassage_service.dart';
import '../services/complete_ramassage_service.dart';
import '../models/ramassage_models.dart';
import 'auth_controller.dart';
import 'location_controller.dart';

class RamassageController extends GetxController {
  final _ramassages = <Ramassage>[].obs;
  final _isLoading = false.obs;
  final _errorMessage = ''.obs;
  final _statistiques = Rxn<RamassageStatistiques>();

  // Getters
  List<Ramassage> get ramassages => _ramassages;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  RamassageStatistiques? get statistiques => _statistiques.value;

  @override
  void onInit() {
    super.onInit();
    // Ne pas charger automatiquement au démarrage
    // loadRamassages();
  }

  /// Recharger les ramassages quand l'utilisateur se connecte
  void onUserLoggedIn() {
    if (isUserLoggedIn) {
      loadRamassages();
    }
  }

  /// Forcer le chargement initial des ramassages
  Future<void> forceLoadRamassages() async {
    // Réinitialiser l'état d'erreur et forcer le chargement
    _errorMessage.value = '';
    await _loadRamassagesWithRetry();
  }

  /// Charger les ramassages avec retry automatique
  Future<void> _loadRamassagesWithRetry() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Attendre un peu pour que l'auth soit prête
      await Future.delayed(const Duration(milliseconds: 100));

      // Récupérer le token depuis AuthController
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        // Si pas de token, attendre un peu plus et réessayer
        await Future.delayed(const Duration(milliseconds: 500));
        final retryToken = authController.authToken;

        if (retryToken.isEmpty) {
          _errorMessage.value = 'Token d\'authentification manquant';
          return;
        }

        final response = await RamassageService.getRamassages(retryToken);
        if (response.success) {
          _ramassages.value = response.data;
          _statistiques.value = response.statistiques;
          update(); // Forcer le rebuild de GetBuilder
        } else {
          _errorMessage.value = response.message;
          update(); // Forcer le rebuild même en cas d'erreur
        }
      } else {
        final response = await RamassageService.getRamassages(token);
        if (response.success) {
          _ramassages.value = response.data;
          _statistiques.value = response.statistiques;
          update(); // Forcer le rebuild de GetBuilder
        } else {
          _errorMessage.value = response.message;
          update(); // Forcer le rebuild même en cas d'erreur
        }
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      update(); // Forcer le rebuild même en cas d'erreur
    } finally {
      _isLoading.value = false;
      update(); // Forcer le rebuild pour mettre à jour l'état de loading
    }
  }

  /// Vérifier si l'utilisateur est connecté
  bool get isUserLoggedIn {
    try {
      final authController = Get.find<AuthController>();
      return authController.isLoggedIn && authController.authToken.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Charger la liste des ramassages
  Future<void> loadRamassages() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      // Vérifier si l'utilisateur est connecté
      if (!isUserLoggedIn) {
        _errorMessage.value =
            'Veuillez vous connecter pour voir les ramassages';
        return;
      }

      // Récupérer le token depuis AuthController
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      final response = await RamassageService.getRamassages(token);

      if (response.success) {
        _ramassages.value = response.data;
        _statistiques.value = response.statistiques;
        update(); // Forcer le rebuild de GetBuilder
      } else {
        _errorMessage.value = response.message;
        update(); // Forcer le rebuild même en cas d'erreur
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      update(); // Forcer le rebuild même en cas d'erreur
    } finally {
      _isLoading.value = false;
      update(); // Forcer le rebuild pour mettre à jour l'état de loading
    }
  }

  /// Rafraîchir la liste des ramassages
  Future<void> refreshRamassages() async {
    await loadRamassages();
  }

  /// Effacer le message d'erreur
  void clearError() {
    _errorMessage.value = '';
  }

  /// Obtenir le statut formaté
  String getStatutFormatted(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return 'Planifié';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  /// Obtenir la couleur du statut
  String getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return '#FFA500'; // Orange
      case 'en_cours':
        return '#007AFF'; // Bleu
      case 'termine':
        return '#34C759'; // Vert
      case 'annule':
        return '#FF3B30'; // Rouge
      default:
        return '#8E8E93'; // Gris
    }
  }

  /// Démarrer un ramassage
  Future<bool> startRamassage(int ramassageId) async {
    try {
      // Vérifier si l'utilisateur est connecté
      if (!isUserLoggedIn) {
        _errorMessage.value =
            'Veuillez vous connecter pour démarrer un ramassage';
        return false;
      }

      // Récupérer le token depuis AuthController
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        _errorMessage.value = 'Token d\'authentification manquant';
        return false;
      }

      // Appeler l'API pour démarrer le ramassage
      final response = await RamassageService.startRamassage(
        ramassageId,
        token,
      );

      if (response.success) {
        // Mettre à jour le statut du ramassage dans la liste locale
        _updateRamassageStatus(ramassageId, response.message);

        // Démarrer automatiquement le suivi de localisation
        try {
          final locationController = Get.find<LocationController>();
          await locationController.startLocationTracking();
        } catch (e) {}

        return true;
      } else {
        _errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    }
  }

  /// Mettre à jour le statut d'un ramassage dans la liste locale
  void _updateRamassageStatus(int ramassageId, String newStatus) {
    final index = _ramassages.indexWhere((r) => r.id == ramassageId);
    if (index != -1) {
      // Créer un nouveau ramassage avec le statut mis à jour
      final updatedRamassage = Ramassage(
        id: _ramassages[index].id,
        codeRamassage: _ramassages[index].codeRamassage,
        entrepriseId: _ramassages[index].entrepriseId,
        marchandId: _ramassages[index].marchandId,
        boutiqueId: _ramassages[index].boutiqueId,
        dateDemande: _ramassages[index].dateDemande,
        datePlanifiee: _ramassages[index].datePlanifiee,
        dateEffectuee: _ramassages[index].dateEffectuee,
        statut: newStatus, // Nouveau statut
        adresseRamassage: _ramassages[index].adresseRamassage,
        contactRamassage: _ramassages[index].contactRamassage,
        nombreColisEstime: _ramassages[index].nombreColisEstime,
        nombreColisReel: _ramassages[index].nombreColisReel,
        differenceColis: _ramassages[index].differenceColis,
        typeDifference: _ramassages[index].typeDifference,
        raisonDifference: _ramassages[index].raisonDifference,
        livreurId: _ramassages[index].livreurId,
        dateDebutRamassage: _ramassages[index].dateDebutRamassage,
        dateFinRamassage: _ramassages[index].dateFinRamassage,
        photoRamassage: _ramassages[index].photoRamassage,
        notesLivreur: _ramassages[index].notesLivreur,
        notesRamassage: _ramassages[index].notesRamassage,
        notes: _ramassages[index].notes,
        colisData: _ramassages[index].colisData,
        montantTotal: _ramassages[index].montantTotal,
        createdAt: _ramassages[index].createdAt,
        updatedAt: _ramassages[index].updatedAt,
        marchand: _ramassages[index].marchand,
        boutique: _ramassages[index].boutique,
        livreur: _ramassages[index].livreur,
      );

      // Remplacer l'ancien ramassage par le nouveau
      _ramassages[index] = updatedRamassage;
      update(); // Forcer le rebuild
    }
  }

  /// Finaliser un ramassage
  Future<bool> completeRamassage({
    required int ramassageId,
    required int nombreColisReel,
    String? notesRamassage,
    String? raisonDifference,
    required List<String> photosPaths,
  }) async {
    try {
      // Vérifier si l'utilisateur est connecté
      if (!isUserLoggedIn) {
        _errorMessage.value =
            'Veuillez vous connecter pour finaliser un ramassage';
        return false;
      }

      // Récupérer le token depuis AuthController
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        _errorMessage.value = 'Token d\'authentification manquant';
        return false;
      }

      // Appeler l'API pour finaliser le ramassage
      final response = await CompleteRamassageService.completeRamassage(
        ramassageId: ramassageId,
        nombreColisReel: nombreColisReel,
        notesRamassage: notesRamassage,
        raisonDifference: raisonDifference,
        photosPaths: photosPaths,
        token: token,
      );

      if (response.success) {
        // Mettre à jour le statut du ramassage dans la liste locale
        _updateRamassageStatus(ramassageId, response.message);

        // Arrêter automatiquement le suivi de localisation
        try {
          final locationController = Get.find<LocationController>();
          await locationController.stopLocationTracking();
        } catch (e) {}

        return true;
      } else {
        _errorMessage.value = response.message;
        return false;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    }
  }
}
