import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/config_service.dart';
import '../services/diagnostic_service.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Écran de configuration pour gérer les URLs et paramètres
class ConfigScreen extends StatefulWidget {
  const ConfigScreen({super.key});

  @override
  State<ConfigScreen> createState() => _ConfigScreenState();
}

class _ConfigScreenState extends State<ConfigScreen> {
  final ConfigService _configService = Get.find<ConfigService>();
  final DiagnosticService _diagnosticService = Get.find<DiagnosticService>();
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _socketUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiUrlController.text = _configService.apiUrl;
    _socketUrlController.text = _configService.socketUrl;
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _socketUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Obx(
        () => SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section URLs
              _buildSectionTitle('URLs de Configuration'),
              const SizedBox(height: AppDimensions.spacingM),

              _buildUrlField(
                label: 'URL API',
                controller: _apiUrlController,
                hint: 'http://192.168.1.4:8000',
              ),

              const SizedBox(height: AppDimensions.spacingM),

              _buildUrlField(
                label: 'URL Socket.IO',
                controller: _socketUrlController,
                hint: 'http://192.168.1.4:3000',
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Section Socket.IO
              _buildSectionTitle('Socket.IO'),
              const SizedBox(height: AppDimensions.spacingM),

              _buildSwitchTile(
                title: 'Utiliser Socket.IO',
                subtitle: 'Activer la communication en temps réel',
                value: _configService.useSocket,
                onChanged: (value) {
                  _configService.setUseSocket(value);
                },
              ),

              Obx(
                () => _buildInfoTile(
                  title: 'Statut Socket.IO',
                  subtitle:
                      _configService.socketAvailable
                          ? 'Disponible'
                          : 'Indisponible',
                  icon:
                      _configService.socketAvailable
                          ? Icons.check_circle
                          : Icons.error,
                  color:
                      _configService.socketAvailable
                          ? Colors.green
                          : Colors.red,
                ),
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Section Actions
              _buildSectionTitle('Actions'),
              const SizedBox(height: AppDimensions.spacingM),

              _buildActionButton(
                title: 'Réinitialiser la configuration',
                icon: Icons.refresh,
                onPressed: _resetConfig,
              ),

              const SizedBox(height: AppDimensions.spacingM),

              _buildActionButton(
                title: 'Diagnostic complet',
                icon: Icons.bug_report,
                onPressed: _runDiagnostic,
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Section Informations
              _buildSectionTitle('Informations'),
              const SizedBox(height: AppDimensions.spacingM),

              _buildInfoCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildUrlField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildInfoTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingM),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Obx(
      () => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configuration actuelle',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppDimensions.spacingS),

              Row(
                children: [
                  Text('Socket disponible: '),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _configService.socketAvailable
                              ? Colors.green
                              : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _configService.socketAvailable ? 'Oui' : 'Non',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.spacingS),
              Text(
                'Dernière mise à jour: ${DateTime.now().toString().split('.')[0]}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetConfig() {
    _configService.resetConfig();
    _apiUrlController.text = _configService.apiUrl;
    _socketUrlController.text = _configService.socketUrl;

    Get.snackbar(
      'Configuration réinitialisée',
      'Les paramètres ont été remis à zéro',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
  }

  void _runDiagnostic() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final report = await _diagnosticService.runFullDiagnostic();

      Get.back(); // Fermer le dialog de chargement

      // Afficher le rapport de diagnostic
      Get.dialog(
        AlertDialog(
          title: const Text('Rapport de Diagnostic'),
          content: SingleChildScrollView(
            child: Text(
              report,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Fermer'),
            ),
            TextButton(
              onPressed: () {
                Get.back();
                _diagnosticService.clearReport();
              },
              child: const Text('Effacer'),
            ),
          ],
        ),
      );
    } catch (e) {
      Get.back(); // Fermer le dialog de chargement
      Get.snackbar(
        'Erreur de diagnostic',
        'Impossible d\'exécuter le diagnostic: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
