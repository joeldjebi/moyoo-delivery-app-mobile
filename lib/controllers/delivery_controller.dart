import 'package:get/get.dart';
import '../models/delivery_models.dart';
import '../services/delivery_service.dart';
import 'auth_controller.dart';
import 'location_controller.dart';

class DeliveryController extends GetxController {
  // État des données
  final RxList<Colis> _colis = <Colis>[].obs;
  final Rx<DeliveryStatistiques?> _statistiques = Rx<DeliveryStatistiques?>(
    null,
  );
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Colis> get colis => _colis;
  DeliveryStatistiques? get statistiques => _statistiques.value;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  // Colis filtrés par statut
  List<Colis> get colisEnAttente => _colis.where((c) => c.isEnAttente).toList();
  List<Colis> get colisEnCours => _colis.where((c) => c.isEnCours).toList();
  List<Colis> get colisLivres => _colis.where((c) => c.isLivre).toList();
  List<Colis> get colisAnnules => _colis.where((c) => c.isAnnule).toList();

  @override
  void onInit() {
    super.onInit();
  }

  /// Charger les colis assignés
  Future<void> loadColis() async {
    if (_isLoading.value) {
      return;
    }

    try {
      _isLoading.value = true;
      _errorMessage.value = '';

      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await DeliveryService.getColisAssignes(token: token);

      if (response.success) {
        _colis.value = response.data;
        _statistiques.value = response.statistiques;
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      _errorMessage.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  /// Actualiser les colis
  Future<void> refreshColis() async {
    // Forcer le rafraîchissement même si isLoading est true
    _isLoading.value = false;
    await loadColis();
  }

  /// Charger les colis si la liste est vide
  Future<void> loadColisIfNeeded() async {
    if (_colis.isEmpty && !_isLoading.value) {
      await loadColis();
    }
  }

  /// Obtenir le statut formaté
  String getStatutFormatted(int status) {
    switch (status) {
      case 0:
        return 'En attente';
      case 1:
        return 'En cours';
      case 2:
        return 'Livré';
      case 3:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  /// Obtenir la couleur du statut
  String getStatutColor(int status) {
    switch (status) {
      case 0:
        return 'warning'; // En attente
      case 1:
        return 'primary'; // En cours
      case 2:
        return 'success'; // Livré
      case 3:
        return 'error'; // Annulé
      default:
        return 'secondary';
    }
  }

  /// Vider les données
  void clearData() {
    _colis.clear();
    _statistiques.value = null;
    _errorMessage.value = '';
  }

  /// Forcer le rechargement
  Future<void> forceLoadColis() async {
    _isLoading.value = false;
    _errorMessage.value = '';
    await loadColis();
  }

  /// Diagnostic de l'état du controller
  void diagnosticState() {
    if (_colis.isNotEmpty) {
      for (int i = 0; i < _colis.length; i++) {
        final colis = _colis[i];
        print('🔍 - Colis $i: ${colis.code} (statut: ${colis.status})');
      }
    }
    print('🔍 ==========================================');
  }

  /// Forcer la mise à jour de l'interface
  void forceUpdateUI() {
    update();
  }

  /// Démarrer une livraison
  Future<bool> startDelivery(int colisId) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        _errorMessage.value = 'Token d\'authentification manquant';
        return false;
      }

      final response = await DeliveryService.startDelivery(
        colisId: colisId,
        token: token,
      );

      if (response['success'] == true) {
        // Démarrer le suivi de localisation si disponible
        try {
          if (Get.isRegistered<LocationController>()) {
            final locationController = Get.find<LocationController>();
            await locationController.startLocationTracking();
          }
        } catch (e) {}

        // Rafraîchir la liste de manière transparente
        await refreshColis();
        return true;
      } else {
        // Gérer le cas spécifique des livraisons actives
        String errorMessage =
            response['message']?.toString() ??
            'Erreur lors du démarrage de la livraison';

        // Si c'est le cas des livraisons actives, formater le message avec les détails
        if (response['active_deliveries'] != null &&
            response['active_deliveries'] is List) {
          List<dynamic> activeDeliveries = response['active_deliveries'];
          if (activeDeliveries.isNotEmpty) {
            String activeDeliveryDetails = activeDeliveries
                .map((delivery) {
                  return '• ${delivery['code']} - ${delivery['client']} (${delivery['adresse']})';
                })
                .join('\n');

            errorMessage =
                '$errorMessage\n\nLivraisons en cours :\n$activeDeliveryDetails';
          }
        }

        _errorMessage.value = errorMessage;
        return false;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    }
  }

  /// Terminer une livraison
  Future<bool> completeDelivery({
    required int colisId,
    required String codeValidation,
    required String noteLivraison,
    String? photoProof,
    String? signatureData,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        _errorMessage.value = 'Token d\'authentification manquant';
        return false;
      }

      final response = await DeliveryService.completeDelivery(
        colisId: colisId,
        codeValidation: codeValidation,
        noteLivraison: noteLivraison,
        token: token,
        photoProof: photoProof,
        signatureData: signatureData,
        latitude: latitude,
        longitude: longitude,
      );

      if (response['success'] == true) {
        // Arrêter le suivi de localisation si disponible
        try {
          if (Get.isRegistered<LocationController>()) {
            final locationController = Get.find<LocationController>();
            await locationController.stopLocationTracking();
          }
        } catch (e) {}

        // Rafraîchir la liste de manière transparente
        await refreshColis();
        return true;
      } else {
        _errorMessage.value =
            response['message']?.toString() ??
            'Erreur lors de la finalisation de la livraison';
        return false;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    }
  }

  /// Annuler une livraison
  Future<bool> cancelDelivery({
    required int colisId,
    required String motifAnnulation,
    required String noteLivraison,
  }) async {
    try {
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        _errorMessage.value = 'Token d\'authentification manquant';
        return false;
      }

      final response = await DeliveryService.cancelDelivery(
        colisId: colisId,
        motifAnnulation: motifAnnulation,
        noteLivraison: noteLivraison,
        token: token,
      );

      if (response['success'] == true) {
        // Rafraîchir la liste de manière transparente
        await refreshColis();
        return true;
      } else {
        _errorMessage.value =
            response['message']?.toString() ??
            'Erreur lors de l\'annulation de la livraison';
        return false;
      }
    } catch (e) {
      _errorMessage.value = e.toString();
      return false;
    }
  }
}
