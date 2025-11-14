import 'package:get/get.dart';

/// Service de configuration pour gérer les URLs et paramètres
class ConfigService extends GetxService {
  static const String _defaultApiUrl = 'http://192.168.1.4:8000';
  static const String _defaultSocketUrl = 'http://192.168.1.4:3000';

  final RxString _apiUrl = _defaultApiUrl.obs;
  final RxString _socketUrl = _defaultSocketUrl.obs;
  final RxBool _useSocket = true.obs;
  final RxBool _socketAvailable = false.obs;

  String get apiUrl => _apiUrl.value;
  String get socketUrl => _socketUrl.value;
  bool get useSocket => _useSocket.value;
  bool get socketAvailable => _socketAvailable.value;

  // Getters pour les observables
  RxString get apiUrlRx => _apiUrl;
  RxString get socketUrlRx => _socketUrl;
  RxBool get useSocketRx => _useSocket;
  RxBool get socketAvailableRx => _socketAvailable;

  @override
  void onInit() {
    super.onInit();
    _checkSocketAvailability();
  }

  /// Vérifier la disponibilité du serveur Socket.IO
  Future<void> _checkSocketAvailability() async {
    try {
      // TODO: Implémenter une vérification de disponibilité
      // Pour l'instant, on assume que Socket.IO n'est pas disponible
      _socketAvailable.value = false;
      _useSocket.value = false;
    } catch (e) {
      _socketAvailable.value = false;
      _useSocket.value = false;
    }
  }

  /// Mettre à jour l'URL de l'API
  void updateApiUrl(String url) {
    _apiUrl.value = url;
  }

  /// Mettre à jour l'URL Socket.IO
  void updateSocketUrl(String url) {
    _socketUrl.value = url;
  }

  /// Activer/désactiver Socket.IO
  void setUseSocket(bool useSocket) {
    _useSocket.value = useSocket;
  }

  /// Marquer Socket.IO comme disponible
  void setSocketAvailable(bool available) {
    _socketAvailable.value = available;
    if (available) {
      _useSocket.value = true;
    }
    print(
      '🔄 Socket.IO marqué comme ${available ? 'disponible' : 'indisponible'}',
    );
  }

  /// Obtenir la configuration actuelle
  Map<String, dynamic> getCurrentConfig() {
    return {
      'apiUrl': _apiUrl.value,
      'socketUrl': _socketUrl.value,
      'useSocket': _useSocket.value,
      'socketAvailable': _socketAvailable.value,
    };
  }

  /// Réinitialiser la configuration
  void resetConfig() {
    _apiUrl.value = _defaultApiUrl;
    _socketUrl.value = _defaultSocketUrl;
    _useSocket.value = true;
    _socketAvailable.value = false;
  }
}
