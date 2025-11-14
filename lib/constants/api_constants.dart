// Constantes pour l'API
class ApiConstants {
  // URL de base de l'API
  static const String baseUrl =
      'https://blastodermatic-stefan-raggedly.ngrok-free.dev';

  // Endpoints d'authentification
  static const String loginEndpoint = '/api/livreur/login';
  static const String logoutEndpoint = '/api/livreur/logout';
  static const String verifyTokenEndpoint = '/api/livreur/verify-token';
  static const String refreshTokenEndpoint = '/api/livreur/refresh-token';
  static const String profileEndpoint = '/api/livreur/profile';

  // Endpoints des livraisons
  static const String deliveriesEndpoint = '/api/livreur/deliveries';
  static const String startDeliveryEndpoint =
      '/api/livreur/deliveries/{id}/start';
  static const String completeDeliveryEndpoint =
      '/api/livreur/deliveries/{id}/complete';

  // Endpoints des ramassages
  static const String pickupsEndpoint = '/api/livreur/ramassages';
  static const String pickupDetailsEndpoint =
      '/api/livreur/ramassages/{id}/details';
  static const String startPickupEndpoint =
      '/api/livreur/ramassages/{id}/start';
  static const String completePickupEndpoint =
      '/api/livreur/ramassages/{id}/complete';

  // Endpoints de localisation
  static const String locationUpdateEndpoint = '/api/livreur/location/update';
  static const String locationHistoryEndpoint = '/api/livreur/location/history';
  static const String locationStatusEndpoint = '/api/livreur/location/status';
  static const String currentMissionEndpoint =
      '/api/livreur/location/current-mission';
  static const String missionHistoryEndpoint =
      '/api/livreur/location/mission-history';

  // Socket.IO Configuration
  static const String socketUrl =
      'https://blastodermatic-stefan-raggedly.ngrok-free.dev';

  // URL de base pour les images et fichiers stockés
  static const String storageBaseUrl =
      'https://blastodermatic-stefan-raggedly.ngrok-free.dev/storage';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
