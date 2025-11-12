import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../constants/api_constants.dart';
import '../models/location_api_models.dart';
import '../storage/auth_storage.dart';

/// Service Socket.IO pour la géolocalisation en temps réel
class SocketService extends GetxService {
  IO.Socket? _socket;
  final RxBool _isConnected = false.obs;
  final RxString _connectionStatus = 'disconnected'.obs;
  final RxString _lastError = ''.obs;

  // Streams pour les événements
  final StreamController<LocationData> _locationUpdateController =
      StreamController<LocationData>.broadcast();
  final StreamController<String> _statusChangeController =
      StreamController<String>.broadcast();
  final StreamController<String> _errorController =
      StreamController<String>.broadcast();

  // Getters
  bool get isConnected => _isConnected.value;
  String get connectionStatus => _connectionStatus.value;
  String get lastError => _lastError.value;

  // Getters pour les observables (pour l'écoute des changements)
  RxBool get isConnectedRx => _isConnected;

  // Streams
  Stream<LocationData> get locationUpdateStream =>
      _locationUpdateController.stream;
  Stream<String> get statusChangeStream => _statusChangeController.stream;
  Stream<String> get errorStream => _errorController.stream;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    disconnect();
    _locationUpdateController.close();
    _statusChangeController.close();
    _errorController.close();
    super.onClose();
  }

  /// Se connecter au serveur Socket.IO
  Future<bool> connect() async {
    try {
      if (_socket != null && _socket!.connected) {
        return true;
      }

      // Récupérer le token d'authentification
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        _lastError.value = 'Token d\'authentification manquant';
        return false;
      }

      _socket = IO.io(
        ApiConstants.socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .setTimeout(3000) // Réduire encore plus le timeout
            .build(),
      );

      _setupEventListeners();

      _socket!.connect();

      // Attendre un court délai pour voir si la connexion réussit
      await Future.delayed(const Duration(milliseconds: 1000));

      if (!_socket!.connected) {
        _lastError.value =
            'Socket.IO non disponible, utilisation de l\'API REST';
        return false;
      }

      // Attendre la connexion
      await _waitForConnection();

      // Authentifier avec le token
      _socket!.emit('authenticate', {'token': token});

      return _isConnected.value;
    } catch (e, stackTrace) {
      _lastError.value = 'Erreur de connexion: $e';
      _connectionStatus.value = 'error';
      return false;
    }
  }

  /// Attendre la connexion
  Future<void> _waitForConnection() async {
    final completer = Completer<void>();
    Timer? timeout;

    // Timeout de 10 secondes
    timeout = Timer(const Duration(seconds: 10), () {
      if (!completer.isCompleted) {
        completer.completeError('Timeout de connexion');
      }
    });

    // Écouter l'événement de connexion
    _socket!.onConnect((_) {
      timeout?.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    try {
      await completer.future;
    } catch (e) {
      timeout?.cancel();
      rethrow;
    }
  }

  /// Configurer les écouteurs d'événements
  void _setupEventListeners() {
    if (_socket == null) {
      return;
    }

    // Connexion établie
    _socket!.onConnect((_) {
      _isConnected.value = true;
      _connectionStatus.value = 'connected';
      _lastError.value = '';
    });

    // Déconnexion
    _socket!.onDisconnect((reason) {
      _isConnected.value = false;
      _connectionStatus.value = 'disconnected';
    });

    // Erreur de connexion
    _socket!.onConnectError((error) {
      _lastError.value = 'Erreur de connexion: $error';
      _connectionStatus.value = 'error';
    });

    // Confirmation de position
    _socket!.on('location:updated', (data) {
      try {
        if (data is Map<String, dynamic>) {
          final locationData = LocationData.fromJson(data);
          _locationUpdateController.add(locationData);
        }
      } catch (e) {}
    });

    // Erreur de position
    _socket!.on('location:error', (data) {
      if (data is Map<String, dynamic> && data['message'] != null) {
        _errorController.add(data['message']);
        _lastError.value = data['message'];
      }
    });

    // Statut changé
    _socket!.on('location:status:changed', (data) {
      if (data is Map<String, dynamic> && data['status'] != null) {
        _statusChangeController.add(data['status']);
      }
    });

    // Livreur en ligne (pour les admins)
    _socket!.on('livreur:online', (data) {});

    // Livreur hors ligne (pour les admins)
    _socket!.on('livreur:offline', (data) {});

    // Position livreur (pour les admins)
    _socket!.on('admin:livreur:location', (data) {});

    // Statut livreur (pour les dispatchers)
    _socket!.on('dispatcher:livreur:status', (data) {});
  }

  /// Se déconnecter du serveur
  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _isConnected.value = false;
      _connectionStatus.value = 'disconnected';
    }
  }

  /// Tester la connexion Socket.IO avec un timeout
  Future<bool> testConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      // Si déjà connecté, retourner true
      if (_socket != null && _socket!.connected) {
        return true;
      }

      // Récupérer le token d'authentification
      final token = await AuthStorage.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }

      // Créer une nouvelle connexion pour le test avec la méthode simplifiée
      final testSocket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'timeout': timeout.inMilliseconds,
        'auth': {'token': token},
        'query': {
          'token': token,
        }, // Ajouter le token dans les query parameters aussi
      });

      bool connectionSuccess = false;
      String? lastError;
      final completer = Completer<bool>();

      // Écouter l'événement de connexion
      testSocket.on('connect', (data) {
        // Authentifier avec le token après la connexion
        testSocket.emit('authenticate', {'token': token});

        connectionSuccess = true;
        if (!completer.isCompleted) {
          completer.complete(true);
        }
      });

      // Écouter les erreurs de connexion
      testSocket.on('connect_error', (error) {
        lastError = 'Erreur de connexion: ${error.message}';
        connectionSuccess = false;
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Écouter les erreurs générales
      testSocket.on('error', (err) {
        lastError = 'Erreur générale: $err';
        connectionSuccess = false;
        if (!completer.isCompleted) {
          completer.complete(false);
        }
      });

      // Écouter les événements de déconnexion
      testSocket.on('disconnect', (reason) {
        if (!connectionSuccess) {
          lastError = 'Déconnexion: $reason';
          if (!completer.isCompleted) {
            completer.complete(false);
          }
        }
      });

      // Tenter la connexion
      testSocket.connect();

      // Attendre le résultat avec timeout

      try {
        final result = await completer.future.timeout(timeout);

        // Nettoyer la connexion de test
        testSocket.disconnect();

        if (result) {
          return true;
        } else {
          return false;
        }
      } catch (e) {
        // Nettoyer la connexion de test
        testSocket.disconnect();
        return false;
      }
    } catch (e, stackTrace) {
      return false;
    }
  }

  /// Envoyer une position via Socket.IO
  Future<bool> sendLocation(LocationUpdateRequest request) async {
    if (!_isConnected.value || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('location:update', request.toJson());
      return true;
    } catch (e) {
      _lastError.value = 'Erreur envoi: $e';
      return false;
    }
  }

  /// Changer le statut de localisation
  Future<bool> changeLocationStatus(String status) async {
    if (!_isConnected.value || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('location:status:change', {'status': status});
      return true;
    } catch (e) {
      _lastError.value = 'Erreur changement statut: $e';
      return false;
    }
  }

  /// Rejoindre une room d'administration
  Future<bool> joinAdminRoom() async {
    if (!_isConnected.value || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('admin:join');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Rejoindre une room de dispatcher
  Future<bool> joinDispatcherRoom() async {
    if (!_isConnected.value || _socket == null) {
      return false;
    }

    try {
      _socket!.emit('dispatcher:join');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Obtenir l'état de connexion
  Map<String, dynamic> getConnectionStatus() {
    return {
      'isConnected': _isConnected.value,
      'status': _connectionStatus.value,
      'lastError': _lastError.value,
      'socketId': _socket?.id,
    };
  }

  /// Reconnecter automatiquement
  Future<void> reconnect() async {
    disconnect();
    await Future.delayed(const Duration(seconds: 2));
    await connect();
  }
}
