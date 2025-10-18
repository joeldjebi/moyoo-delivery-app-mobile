import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/delivery_models.dart';

class DeliveryStatisticsScreen extends StatelessWidget {
  final List<Colis> filteredColis;
  final String selectedDeliveryType;
  final String selectedStatus;
  final String selectedPeriod;
  final DateTime? startDate;
  final DateTime? endDate;

  const DeliveryStatisticsScreen({
    super.key,
    required this.filteredColis,
    required this.selectedDeliveryType,
    required this.selectedStatus,
    required this.selectedPeriod,
    this.startDate,
    this.endDate,
  });

  @override
  Widget build(BuildContext context) {
    print('🔍 [DeliveryStatistics] build() appelé');
    print(
      '🔍 [DeliveryStatistics] filteredColis.length: ${filteredColis.length}',
    );
    print(
      '🔍 [DeliveryStatistics] selectedDeliveryType: $selectedDeliveryType',
    );
    print('🔍 [DeliveryStatistics] selectedStatus: $selectedStatus');
    print('🔍 [DeliveryStatistics] selectedPeriod: $selectedPeriod');
    print('🔍 [DeliveryStatistics] startDate: $startDate');
    print('🔍 [DeliveryStatistics] endDate: $endDate');

    // Calculer les statistiques
    final statistics = _calculateStatistics();
    print(
      '🔍 [DeliveryStatistics] Statistiques calculées: ${statistics.toString()}',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec filtres appliqués
            _buildFilterSummary(),

            const SizedBox(height: AppDimensions.spacingM),

            // Statistiques principales
            _buildMainStatistics(statistics),

            const SizedBox(height: AppDimensions.spacingM),

            // Détails par type de livraison
            _buildDeliveryTypeBreakdown(statistics),

            const SizedBox(height: AppDimensions.spacingM),

            // Détails par statut
            _buildStatusBreakdown(statistics),

            const SizedBox(height: AppDimensions.spacingM),

            // Liste des livraisons filtrées
            _buildFilteredList(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Get.back(),
      ),
      title: Text(
        'Statistiques des Livraisons',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share, color: Colors.black),
          onPressed: _shareStatistics,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFilterSummary() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Filtres appliqués',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          _buildFilterChip('Type', selectedDeliveryType),
          _buildFilterChip('Statut', selectedStatus),
          _buildFilterChip('Période', _getPeriodDisplayText()),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            '${filteredColis.length} livraison(s) trouvée(s)',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              color: AppColors.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Text(
              value,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStatistics(DeliveryStatistics statistics) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistiques principales',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total encaissé',
                  '${_formatAmount(statistics.totalEncaisse)} F',
                  Icons.account_balance_wallet,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  'Frais de livraison',
                  '${_formatAmount(statistics.totalFraisLivraison)} F',
                  Icons.local_shipping,
                  AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Nombre de colis',
                  '${statistics.totalColis}',
                  Icons.inventory,
                  AppColors.warning,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: _buildStatCard(
                  'Montant moyen',
                  '${_formatAmount(statistics.montantMoyen)} F',
                  Icons.trending_up,
                  AppColors.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: AppDimensions.spacingXS),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryTypeBreakdown(DeliveryStatistics statistics) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par type de livraison',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ...statistics.parTypeLivraison.entries.map((entry) {
            return _buildBreakdownItem(
              entry.key,
              entry.value['count'] as int,
              entry.value['amount'] as int,
              statistics.totalColis,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatusBreakdown(DeliveryStatistics statistics) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Répartition par statut',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ...statistics.parStatut.entries.map((entry) {
            return _buildBreakdownItem(
              entry.key,
              entry.value['count'] as int,
              entry.value['amount'] as int,
              statistics.totalColis,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem(String label, int count, int amount, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '$count ($percentage%)',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_formatAmount(amount)} F',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w500,
                color: AppColors.success,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail des livraisons',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredColis.length,
            itemBuilder: (context, index) {
              final colis = filteredColis[index];
              return Container(
                margin: const EdgeInsets.only(bottom: AppDimensions.spacingXS),
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            colis.code,
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            colis.nomClient,
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${_formatAmount(colis.montantAEncaisse)} F',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w500,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  DeliveryStatistics _calculateStatistics() {
    int totalEncaisse = 0;
    int totalFraisLivraison = 0;
    Map<String, Map<String, int>> parTypeLivraison = {};
    Map<String, Map<String, int>> parStatut = {};

    for (final colis in filteredColis) {
      totalEncaisse += colis.montantAEncaisse;
      // Supposons que les frais de livraison sont 10% du montant
      totalFraisLivraison += (colis.montantAEncaisse * 0.1).round();

      // Par type de livraison
      final type = colis.modeLivraison.libelle;
      if (!parTypeLivraison.containsKey(type)) {
        parTypeLivraison[type] = {'count': 0, 'amount': 0};
      }
      parTypeLivraison[type]!['count'] =
          (parTypeLivraison[type]!['count'] as int) + 1;
      parTypeLivraison[type]!['amount'] =
          (parTypeLivraison[type]!['amount'] as int) + colis.montantAEncaisse;

      // Par statut
      final statut = colis.statutFormatted;
      if (!parStatut.containsKey(statut)) {
        parStatut[statut] = {'count': 0, 'amount': 0};
      }
      parStatut[statut]!['count'] = (parStatut[statut]!['count'] as int) + 1;
      parStatut[statut]!['amount'] =
          (parStatut[statut]!['amount'] as int) + colis.montantAEncaisse;
    }

    return DeliveryStatistics(
      totalColis: filteredColis.length,
      totalEncaisse: totalEncaisse,
      totalFraisLivraison: totalFraisLivraison,
      montantMoyen:
          filteredColis.isNotEmpty ? totalEncaisse ~/ filteredColis.length : 0,
      parTypeLivraison: parTypeLivraison,
      parStatut: parStatut,
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String _getPeriodDisplayText() {
    if (selectedPeriod == 'Période personnalisée' &&
        (startDate != null || endDate != null)) {
      if (startDate != null && endDate != null) {
        return 'Du ${_formatDate(startDate!)} au ${_formatDate(endDate!)}';
      } else if (startDate != null) {
        return 'À partir du ${_formatDate(startDate!)}';
      } else if (endDate != null) {
        return 'Jusqu\'au ${_formatDate(endDate!)}';
      }
    }
    return selectedPeriod;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _shareStatistics() {
    // TODO: Implémenter le partage des statistiques
    Get.snackbar(
      'Partage',
      'Fonctionnalité de partage à implémenter',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }
}

class DeliveryStatistics {
  final int totalColis;
  final int totalEncaisse;
  final int totalFraisLivraison;
  final int montantMoyen;
  final Map<String, Map<String, int>> parTypeLivraison;
  final Map<String, Map<String, int>> parStatut;

  DeliveryStatistics({
    required this.totalColis,
    required this.totalEncaisse,
    required this.totalFraisLivraison,
    required this.montantMoyen,
    required this.parTypeLivraison,
    required this.parStatut,
  });
}
