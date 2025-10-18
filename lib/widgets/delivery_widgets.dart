import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/delivery_models.dart';
import 'formatted_amount_widget.dart';

class DeliveryStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const DeliveryStatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icône
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),

          const SizedBox(height: AppDimensions.spacingXS),

          // Valeur
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          // Titre
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),

          // Sous-titre
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryCard extends StatelessWidget {
  final Colis colis;
  final VoidCallback? onTap;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const DeliveryCard({
    super.key,
    required this.colis,
    this.onTap,
    this.onStart,
    this.onComplete,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final statutColor = _getStatutColor(colis.status);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
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
        children: [
          // Barre de statut colorée
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statutColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
            ),
          ),

          // Bloc principal cliquable
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec code et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          colis.code,
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeXS,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statutColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Text(
                          colis.statutFormatted,
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeXS,
                            fontWeight: FontWeight.w500,
                            color: statutColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingXS),

                  // Informations du colis
                  Row(
                    children: [
                      // Icône et client
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: AppDimensions.spacingS),

                      // Détails
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              colis.nomClient,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeS,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              colis.commune.libelle,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              colis.adresseClient,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              colis.modeLivraison.libelle,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text(
                              _formatDate(colis.updatedAt),
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Montant
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AmountListItem(
                            amount: colis.montantAEncaisse.toString(),
                            currency: 'F',
                            textColor: AppColors.success,
                            fontSize: AppDimensions.fontSizeS,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            colis.poids.libelle,
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Boutons d'action
          if (_shouldShowActionButtons())
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppDimensions.spacingS,
                0,
                AppDimensions.spacingS,
                AppDimensions.spacingS,
              ),
              child: _buildActionButtons(),
            ),
        ],
      ),
    );
  }

  bool _shouldShowActionButtons() {
    return colis.isEnAttente || colis.isEnCours;
  }

  Widget _buildActionButtons() {
    if (colis.isEnAttente) {
      // Boutons pour colis en attente
      return Row(
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Démarrer',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Annuler',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (colis.isEnCours) {
      // Boutons pour colis en cours
      return Row(
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: onComplete,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Livrer',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: ElevatedButton(
              onPressed: onCancel,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Annuler',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Color _getStatutColor(int status) {
    switch (status) {
      case 0:
        return AppColors.warning; // En attente
      case 1:
        return AppColors.primary; // En cours
      case 2:
        return AppColors.success; // Livré
      case 3:
        return AppColors.error; // Annulé
      default:
        return AppColors.textSecondary;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      // Si c'est aujourd'hui, afficher l'heure
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }

      // Si c'est hier
      final yesterday = now.subtract(const Duration(days: 1));
      if (date.year == yesterday.year &&
          date.month == yesterday.month &&
          date.day == yesterday.day) {
        return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      }

      // Sinon, afficher la date complète
      final months = [
        'Jan',
        'Fév',
        'Mar',
        'Avr',
        'Mai',
        'Jun',
        'Jul',
        'Aoû',
        'Sep',
        'Oct',
        'Nov',
        'Déc',
      ];

      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }
}

class DeliveryEmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRetry;

  const DeliveryEmptyState({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(onPressed: onRetry, child: const Text('Réessayer')),
          ],
        ],
      ),
    );
  }
}

class DeliveryLoadingState extends StatelessWidget {
  const DeliveryLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}
