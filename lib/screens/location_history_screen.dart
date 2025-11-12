import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../models/location_api_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/location_widget.dart';

/// Écran pour afficher l'historique des positions du livreur
class LocationHistoryScreen extends StatefulWidget {
  const LocationHistoryScreen({super.key});

  @override
  State<LocationHistoryScreen> createState() => _LocationHistoryScreenState();
}

class _LocationHistoryScreenState extends State<LocationHistoryScreen> {
  final LocationController _locationController = Get.find<LocationController>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLocationHistory();
  }

  Future<void> _loadLocationHistory() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Charger l'historique des 7 derniers jours
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 7));

      await _locationController.loadLocationHistory(
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger l\'historique: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Historique des positions'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadLocationHistory,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Widget de position actuelle
            const Padding(
              padding: EdgeInsets.all(AppDimensions.spacingM),
              child: LocationWidget(showDetails: true),
            ),

            // En-tête de l'historique
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              child: Row(
                children: [
                  const Icon(Icons.history, color: AppColors.primary),
                  const SizedBox(width: AppDimensions.spacingS),
                  Text(
                    'Historique des positions',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Obx(
                    () => Text(
                      '${_locationController.locationHistory.length} positions',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Liste de l'historique
            Expanded(
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Obx(() => _buildLocationHistoryList()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHistoryList() {
    final history = _locationController.locationHistory;

    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Aucun historique disponible',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'L\'historique des positions apparaîtra ici',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      itemCount: history.length,
      itemBuilder: (context, index) {
        final location = history[index];
        final isLatest = index == 0;

        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLatest ? AppColors.primary : Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_on,
                color: isLatest ? Colors.white : Colors.grey.shade600,
                size: 20,
              ),
            ),
            title: Text(
              '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isLatest ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_formatTimestamp(location.timestamp)),
                if (location.accuracy != null)
                  Text(
                    'Précision: ${location.accuracy!.toStringAsFixed(1)}m',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (location.speed != null && location.speed! > 0)
                  Text(
                    'Vitesse: ${(location.speed! * 3.6).toStringAsFixed(1)} km/h',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
            trailing:
                isLatest
                    ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Actuel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : null,
            onTap: () => _showLocationDetails(location),
          ),
        );
      },
    );
  }

  void _showLocationDetails(LocationData location) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Détails de la position'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  'Latitude',
                  location.latitude.toStringAsFixed(8),
                ),
                _buildDetailRow(
                  'Longitude',
                  location.longitude.toStringAsFixed(8),
                ),
                if (location.accuracy != null)
                  _buildDetailRow(
                    'Précision',
                    '${location.accuracy!.toStringAsFixed(1)} mètres',
                  ),
                if (location.altitude != null)
                  _buildDetailRow(
                    'Altitude',
                    '${location.altitude!.toStringAsFixed(1)} mètres',
                  ),
                if (location.speed != null)
                  _buildDetailRow(
                    'Vitesse',
                    '${(location.speed! * 3.6).toStringAsFixed(1)} km/h',
                  ),
                if (location.heading != null)
                  _buildDetailRow(
                    'Direction',
                    '${location.heading!.toStringAsFixed(1)}°',
                  ),
                _buildDetailRow(
                  'Date/Heure',
                  _formatFullTimestamp(location.timestamp),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Fermer'),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Il y a ${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes}min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else {
      return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatFullTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month}/${timestamp.year} à ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}:${timestamp.second.toString().padLeft(2, '0')}';
  }
}
