import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../models/location_api_models.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

/// Écran pour afficher l'historique des missions avec positions GPS
class MissionHistoryScreen extends StatefulWidget {
  final String missionType;
  final int missionId;

  const MissionHistoryScreen({
    super.key,
    required this.missionType,
    required this.missionId,
  });

  @override
  State<MissionHistoryScreen> createState() => _MissionHistoryScreenState();
}

class _MissionHistoryScreenState extends State<MissionHistoryScreen> {
  final LocationController locationController = Get.find<LocationController>();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMissionHistory();
  }

  Future<void> _loadMissionHistory() async {
    setState(() {
      _isLoading = true;
    });

    await locationController.loadMissionHistory(
      widget.missionType,
      widget.missionId,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique ${widget.missionType}'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMissionHistory,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Obx(() {
                final missionHistory = locationController.missionHistory;

                if (missionHistory == null) {
                  return const Center(
                    child: Text('Aucun historique disponible'),
                  );
                }

                return Column(
                  children: [
                    // Informations de la mission
                    _buildMissionInfo(missionHistory.mission),

                    // Statistiques
                    _buildStatistics(missionHistory),

                    // Liste des positions
                    Expanded(
                      child: _buildPositionsList(missionHistory.positions),
                    ),
                  ],
                );
              }),
    );
  }

  Widget _buildMissionInfo(Mission mission) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.missionType == 'ramassage'
                      ? Icons.local_shipping
                      : Icons.delivery_dining,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  'Mission ${widget.missionType.toUpperCase()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              'Code: ${mission.code}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Adresse: ${mission.adresse}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Client: ${mission.client}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              'Téléphone: ${mission.telephone}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(MissionHistory missionHistory) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              'Positions',
              '${missionHistory.count}',
              Icons.location_on,
              AppColors.primary,
            ),
            _buildStatItem(
              'Distance',
              '${missionHistory.distanceTotal.toStringAsFixed(1)}m',
              Icons.straighten,
              AppColors.success,
            ),
            _buildStatItem(
              'Durée',
              _formatDuration(missionHistory.dureeTotal),
              Icons.access_time,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildPositionsList(List<LocationData> positions) {
    if (positions.isEmpty) {
      return const Center(child: Text('Aucune position enregistrée'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final position = positions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.gps_fixed, color: AppColors.primary, size: 16),
                    const SizedBox(width: AppDimensions.spacingXS),
                    Text(
                      'Position ${index + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingXS,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(position.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        position.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  'Lat: ${position.latitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  'Lng: ${position.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (position.accuracy != null)
                  Text(
                    'Précision: ${position.accuracy!.toStringAsFixed(1)}m',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (position.speed != null && position.speed! > 0)
                  Text(
                    'Vitesse: ${(position.speed! * 3.6).toStringAsFixed(1)} km/h',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                Text(
                  'Heure: ${_formatTimestamp(position.timestamp)}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'en_cours':
        return AppColors.success;
      case 'en_pause':
        return AppColors.warning;
      case 'termine':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.day}/${timestamp.month} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
