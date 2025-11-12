import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../models/location_api_models.dart';

/// Widget pour afficher la position actuelle du livreur
class LocationWidget extends StatelessWidget {
  final bool showDetails;
  final bool showTrackingStatus;
  final VoidCallback? onTap;

  const LocationWidget({
    super.key,
    this.showDetails = true,
    this.showTrackingStatus = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Obx(() {
      final currentLocation = locationController.currentLocation;
      final isTracking = locationController.isLocationTracking;
      final locationError = locationController.locationError;

      return Card(
        margin: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec icône et statut
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: isTracking ? Colors.green : Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Position du livreur',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (showTrackingStatus)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isTracking ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isTracking ? 'Actif' : 'Inactif',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Contenu principal
                if (locationError.isNotEmpty)
                  _buildErrorWidget(context, locationError)
                else if (currentLocation != null)
                  _buildLocationInfo(context, currentLocation)
                else
                  _buildNoLocationWidget(context),

                // Actions (seulement si showDetails est true)
                if (showDetails) ...[
                  const SizedBox(height: 8),
                  _buildActionButtons(context, locationController),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(BuildContext context, LocationData location) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.green.shade600, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Position GPS active',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoLocationWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, color: Colors.grey.shade600, size: 16),
          const SizedBox(width: 8),
          Text(
            'Position non disponible',
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    LocationController controller,
  ) {
    return Row(
      children: [
        Expanded(
          child: Obx(
            () => ElevatedButton.icon(
              onPressed:
                  controller.isLocationTracking
                      ? () => controller.stopLocationTracking()
                      : () => controller.startLocationTracking(),
              icon: Icon(
                controller.isLocationTracking
                    ? Icons.location_off
                    : Icons.location_on,
                size: 16,
              ),
              label: Text(
                controller.isLocationTracking ? 'Arrêter' : 'Démarrer',
                style: const TextStyle(fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.isLocationTracking
                        ? Colors.red.shade600
                        : Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.forceSendCurrentLocation(),
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Envoyer', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Get.toNamed('/location-history'),
        icon: const Icon(Icons.history, size: 16),
        label: const Text('Voir l\'historique'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
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
}

/// Widget compact pour afficher uniquement le statut de localisation
class LocationStatusWidget extends StatelessWidget {
  const LocationStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Obx(() {
      final isTracking = locationController.isLocationTracking;
      final hasLocation = locationController.currentLocation != null;
      final locationError = locationController.locationError;

      Color statusColor;
      IconData statusIcon;
      String statusText;

      if (locationError.isNotEmpty) {
        statusColor = Colors.red;
        statusIcon = Icons.error;
        statusText = 'Erreur GPS';
      } else if (isTracking && hasLocation) {
        statusColor = Colors.green;
        statusIcon = Icons.location_on;
        statusText = 'Suivi actif';
      } else if (hasLocation) {
        statusColor = Colors.orange;
        statusIcon = Icons.location_on_outlined;
        statusText = 'GPS disponible';
      } else {
        statusColor = Colors.grey;
        statusIcon = Icons.location_off;
        statusText = 'GPS indisponible';
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 16),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Widget minimal pour afficher juste une icône de statut GPS
class LocationIndicatorWidget extends StatelessWidget {
  const LocationIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final locationController = Get.find<LocationController>();

    return Obx(() {
      final isTracking = locationController.isLocationTracking;
      final hasLocation = locationController.currentLocation != null;
      final locationError = locationController.locationError;

      Color statusColor;
      IconData statusIcon;

      if (locationError.isNotEmpty) {
        statusColor = Colors.red;
        statusIcon = Icons.error;
      } else if (isTracking && hasLocation) {
        statusColor = Colors.green;
        statusIcon = Icons.location_on;
      } else if (hasLocation) {
        statusColor = Colors.orange;
        statusIcon = Icons.location_on_outlined;
      } else {
        statusColor = Colors.grey;
        statusIcon = Icons.location_off;
      }

      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(statusIcon, color: statusColor, size: 16),
      );
    });
  }
}
