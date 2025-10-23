// Constantes pour l'API
class ApiConstants {
  // URL de base de l'API
  static const String baseUrl = 'http://192.168.1.4:8000';

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

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Headers par défaut
  static const Map<String, String> defaultHeaders = {
    'accept': 'application/json',
    'Content-Type': 'application/json',
  };
}
