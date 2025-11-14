import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:io';
import 'location_service.dart';
import 'socket_service.dart';
import '../controllers/location_controller.dart';

/// Service de diagnostic pour analyser les problèmes de l'application
class DiagnosticService extends GetxService {
  final RxString _diagnosticReport = ''.obs;
  final RxBool _isRunning = false.obs;

  String get diagnosticReport => _diagnosticReport.value;
  bool get isRunning => _isRunning.value;

  @override
  void onInit() {
    super.onInit();
  }

  /// Exécuter un diagnostic complet
  Future<String> runFullDiagnostic() async {
    _isRunning.value = true;
    _diagnosticReport.value = '';

    final report = StringBuffer();
    report.writeln('🔍 DIAGNOSTIC COMPLET DE L\'APPLICATION');
    report.writeln(
      'Date: ${DateTime.now().toLocal().toString().split('.')[0]}',
    );
    report.writeln('=' * 50);
    report.writeln();

    // 1. Diagnostic de géolocalisation
    await _diagnoseLocationServices(report);

    // 2. Diagnostic de connectivité
    await _diagnoseConnectivity(report);

    // 3. Diagnostic des services
    await _diagnoseServices(report);

    // 4. Diagnostic des permissions
    await _diagnosePermissions(report);

    // 5. Recommandations
    _addRecommendations(report);

    _diagnosticReport.value = report.toString();
    _isRunning.value = false;

    return _diagnosticReport.value;
  }

  /// Diagnostic des services de géolocalisation
  Future<void> _diagnoseLocationServices(StringBuffer report) async {
    report.writeln('📍 DIAGNOSTIC GÉOLOCALISATION');
    report.writeln('-' * 30);

    try {
      // Vérifier les permissions
      final permission = await Geolocator.checkPermission();
      report.writeln('Permission GPS: ${_getPermissionStatus(permission)}');

      // Vérifier si le service est activé
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      report.writeln(
        'Service GPS activé: ${serviceEnabled ? '✅ Oui' : '❌ Non'}',
      );

      // Tenter d'obtenir la position
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 30),
        );

        report.writeln(
          'Position actuelle: ${position.latitude}, ${position.longitude}',
        );
        report.writeln('Précision: ${position.accuracy}m');

        // Évaluer la qualité de la précision
        if (position.accuracy <= 10) {
          report.writeln('Qualité GPS: ✅ Excellente (≤10m)');
        } else if (position.accuracy <= 50) {
          report.writeln('Qualité GPS: ⚠️ Bonne (≤50m)');
        } else if (position.accuracy <= 100) {
          report.writeln('Qualité GPS: ⚠️ Moyenne (≤100m)');
        } else {
          report.writeln('Qualité GPS: ❌ Faible (>100m) - Problème de signal');
        }

        report.writeln('Statut: ✅ GPS fonctionnel');
      } catch (e) {
        report.writeln('Erreur GPS: ❌ $e');

        // Ajouter des suggestions spécifiques selon le type d'erreur
        if (e.toString().contains('TimeoutException')) {
          report.writeln('💡 Suggestion: Le GPS met du temps à se stabiliser');
          report.writeln(
            '   - Sortez à l\'extérieur si vous êtes à l\'intérieur',
          );
          report.writeln('   - Attendez quelques secondes de plus');
          report.writeln(
            '   - Vérifiez que le mode économie d\'énergie est désactivé',
          );
        } else if (e.toString().contains('LocationServiceDisabledException')) {
          report.writeln('💡 Suggestion: Activez le service de localisation');
          report.writeln('   - Allez dans Paramètres > Localisation');
          report.writeln('   - Activez la localisation');
        } else if (e.toString().contains('PermissionDeniedException')) {
          report.writeln(
            '💡 Suggestion: Accordez les permissions de localisation',
          );
          report.writeln('   - Allez dans Paramètres > Applications > [App]');
          report.writeln('   - Activez les permissions de localisation');
        }
      }
    } catch (e) {
      report.writeln('Erreur diagnostic GPS: ❌ $e');
    }

    report.writeln();
  }

  /// Diagnostic de connectivité
  Future<void> _diagnoseConnectivity(StringBuffer report) async {
    report.writeln('🌐 DIAGNOSTIC CONNECTIVITÉ');
    report.writeln('-' * 30);

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      report.writeln(
        'Type de connexion: ${_getConnectivityType(connectivityResult)}',
      );

      // Tester la connectivité Internet
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          report.writeln('Internet: ✅ Connecté');
        } else {
          report.writeln('Internet: ❌ Non connecté');
        }
      } catch (e) {
        report.writeln('Internet: ❌ Erreur de connexion');
      }
    } catch (e) {
      report.writeln('Erreur diagnostic connectivité: ❌ $e');
    }

    report.writeln();
  }

  /// Diagnostic des services
  Future<void> _diagnoseServices(StringBuffer report) async {
    report.writeln('⚙️ DIAGNOSTIC SERVICES');
    report.writeln('-' * 30);

    // Vérifier les services GetX
    try {
      if (Get.isRegistered<LocationService>()) {
        report.writeln('LocationService: ✅ Enregistré');
      } else {
        report.writeln('LocationService: ❌ Non enregistré');
      }

      if (Get.isRegistered<SocketService>()) {
        report.writeln('SocketService: ✅ Enregistré');
      } else {
        report.writeln('SocketService: ❌ Non enregistré');
      }

      if (Get.isRegistered<LocationController>()) {
        report.writeln('LocationController: ✅ Enregistré');
      } else {
        report.writeln('LocationController: ❌ Non enregistré');
      }
    } catch (e) {
      report.writeln('Erreur diagnostic services: ❌ $e');
    }

    report.writeln();
  }

  /// Diagnostic des permissions
  Future<void> _diagnosePermissions(StringBuffer report) async {
    report.writeln('🔐 DIAGNOSTIC PERMISSIONS');
    report.writeln('-' * 30);

    try {
      final permission = await Geolocator.checkPermission();
      report.writeln('Permission GPS: ${_getPermissionStatus(permission)}');

      if (permission == LocationPermission.denied) {
        report.writeln('⚠️ Permission GPS refusée - Demander la permission');
      } else if (permission == LocationPermission.deniedForever) {
        report.writeln(
          '❌ Permission GPS refusée définitivement - Aller dans les paramètres',
        );
      } else if (permission == LocationPermission.whileInUse) {
        report.writeln('✅ Permission GPS accordée (utilisation)');
      } else if (permission == LocationPermission.always) {
        report.writeln('✅ Permission GPS accordée (toujours)');
      }
    } catch (e) {
      report.writeln('Erreur diagnostic permissions: ❌ $e');
    }

    report.writeln();
  }

  /// Ajouter des recommandations
  void _addRecommendations(StringBuffer report) {
    report.writeln('💡 RECOMMANDATIONS');
    report.writeln('-' * 30);

    report.writeln('1. Vérifiez que le GPS est activé sur votre appareil');
    report.writeln(
      '2. Accordez les permissions de localisation à l\'application',
    );
    report.writeln('3. Vérifiez votre connexion Internet');
    report.writeln(
      '4. Si Socket.IO ne fonctionne pas, l\'API REST sera utilisée automatiquement',
    );
    report.writeln('5. Pour améliorer la précision GPS:');
    report.writeln('   - Sortez à l\'extérieur si vous êtes à l\'intérieur');
    report.writeln('   - Évitez les zones avec des bâtiments élevés');
    report.writeln('   - Attendez quelques secondes pour stabiliser le signal');
    report.writeln(
      '   - Vérifiez que le mode économie d\'énergie est désactivé',
    );
    report.writeln('6. Redémarrez l\'application si les problèmes persistent');

    report.writeln();
    report.writeln(
      '📞 Support: Contactez l\'administrateur si les problèmes persistent',
    );
  }

  /// Obtenir le statut de permission
  String _getPermissionStatus(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.denied:
        return '❌ Refusée';
      case LocationPermission.deniedForever:
        return '❌ Refusée définitivement';
      case LocationPermission.whileInUse:
        return '✅ Accordée (utilisation)';
      case LocationPermission.always:
        return '✅ Accordée (toujours)';
      case LocationPermission.unableToDetermine:
        return '❓ Indéterminée';
    }
  }

  /// Obtenir le type de connectivité
  String _getConnectivityType(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.wifi)) {
      return 'WiFi';
    } else if (results.contains(ConnectivityResult.mobile)) {
      return 'Mobile';
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return 'Ethernet';
    } else {
      return 'Aucune connexion';
    }
  }

  /// Nettoyer le rapport
  void clearReport() {
    _diagnosticReport.value = '';
  }
}
