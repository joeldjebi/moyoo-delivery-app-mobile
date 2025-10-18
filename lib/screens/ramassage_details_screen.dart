import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/api_constants.dart';
import '../models/ramassage_detail_models.dart';
import '../models/ramassage_models.dart';
import '../services/ramassage_service.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';
import '../services/cancel_ramassage_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ramassage_controller.dart';
import '../widgets/app_button.dart';
import '../widgets/clickable_phone_widget.dart';
import '../widgets/formatted_amount_widget.dart';
import 'complete_ramassage_screen.dart';
import 'ramassage_list_screen.dart';

class RamassageDetailsScreen extends StatefulWidget {
  final int ramassageId;
  final String codeRamassage;
  final String? fromPage; // Page d'origine pour le retour

  const RamassageDetailsScreen({
    super.key,
    required this.ramassageId,
    required this.codeRamassage,
    this.fromPage,
  });

  @override
  State<RamassageDetailsScreen> createState() => _RamassageDetailsScreenState();
}

class _RamassageDetailsScreenState extends State<RamassageDetailsScreen> {
  RamassageDetail? _ramassageDetail;
  bool _isLoading = true;
  String _errorMessage = '';
  late RamassageController _ramassageController;

  @override
  void initState() {
    super.initState();
    _ramassageController = Get.find<RamassageController>();
    _loadRamassageDetails();
    _checkNotificationRefreshFlags();
  }

  /// Vérifier les flags d'actualisation des notifications
  void _checkNotificationRefreshFlags() {
    try {
      print(
        '🔄 Vérification des flags d\'actualisation des notifications (RamassageDetailsScreen)',
      );
      NotificationService.checkAndProcessRefreshFlags();
    } catch (e) {
      print('❌ Erreur lors de la vérification des flags: $e');
    }
  }

  /// Envoyer une notification locale pour les actions de ramassage
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    required String type, // 'success', 'error', 'info'
  }) async {
    try {
      final localNotificationService = LocalNotificationService();

      // Utiliser les méthodes spécifiques selon le type
      switch (type) {
        case 'success':
          await localNotificationService.showSuccessNotification(
            title: title,
            message: body,
            payload: 'ramassage_action_success',
          );
          break;
        case 'error':
          await localNotificationService.showErrorNotification(
            title: title,
            message: body,
            payload: 'ramassage_action_error',
          );
          break;
        default: // 'info'
          await localNotificationService.showInfoNotification(
            title: title,
            message: body,
            payload: 'ramassage_action_info',
          );
      }

      print('✅ Notification locale envoyée: $title');
    } catch (e) {
      print('❌ Erreur lors de l\'envoi de la notification locale: $e');
    }
  }

  Future<void> _loadRamassageDetails() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        setState(() {
          _errorMessage = 'Token d\'authentification manquant';
          _isLoading = false;
        });
        return;
      }

      final response = await RamassageService.getRamassageDetails(
        widget.ramassageId,
        token,
      );

      if (response.success) {
        setState(() {
          _ramassageDetail = response.data;
          _isLoading = false;
        });
        print(
          '🔍 Screen - Ramassage details-->: ${_ramassageDetail!.notesLivreur}',
        );
        print(
          '🔍 Screen - Ramassage details: ${_ramassageDetail!.notesRamassage}',
        );
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.all(AppDimensions.spacingS),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détails du ramassage',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (_ramassageDetail != null)
            Text(
              _ramassageDetail!.codeRamassage,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
        ],
      ),
      actions: [
        if (_ramassageDetail != null)
          Container(
            margin: const EdgeInsets.only(right: AppDimensions.spacingS),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              _getStatutFormatted(_ramassageDetail!.statut),
              style: GoogleFonts.montserrat(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildShimmerLoading();
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: AppDimensions.spacingM),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeM,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              _errorMessage,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: _loadRamassageDetails,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_ramassageDetail == null) {
      return const Center(child: Text('Aucune donnée disponible'));
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: _loadRamassageDetails,
          child: CustomScrollView(
            slivers: [
              // Header avec informations principales
              SliverToBoxAdapter(child: _buildHeaderCard()),

              // Section des colis
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                  ),
                  child: _buildColisSectionHeader(),
                ),
              ),

              // Section des photos des colis
              if (_ramassageDetail!.photoRamassage != null &&
                  _ramassageDetail!.photoRamassage!.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    child: _buildPhotosSection(),
                  ),
                ),
              ] else
                ...[],

              // Section des photos des colis ramassés
              if (_extractPhotoUrls().isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    child: _buildColisPhotosSection(),
                  ),
                ),
              ],

              // Section des notes (toujours affichée si disponibles)
              if (_ramassageDetail!.notesLivreur != null &&
                  _ramassageDetail!.notesLivreur!.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    child: _buildNotesSection(),
                  ),
                ),

              // Bouton "Voir plus" si nécessaire
              if (_ramassageDetail!.colisLies.length > 10)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    child: _buildVoirPlusButton(),
                  ),
                ),

              // Espace en bas pour le bouton fixe
              SliverToBoxAdapter(
                child: SizedBox(
                  height:
                      (_ramassageDetail!.statut == 'planifie' ||
                              _ramassageDetail!.statut == 'en_cours')
                          ? 100
                          : 20,
                ),
              ),
            ],
          ),
        ),

        // Bouton fixe en bas
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildFixedActionButton(),
        ),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header avec icône et titre
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ramassageDetail!.boutique.libelle,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _ramassageDetail!.codeRamassage,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatutColor(
                      _ramassageDetail!.statut,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _getStatutColor(_ramassageDetail!.statut),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatutFormatted(_ramassageDetail!.statut),
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getStatutColor(_ramassageDetail!.statut),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Informations principales
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                _buildModernInfoRow(
                  Icons.location_on,
                  'Adresse',
                  _ramassageDetail!.adresseRamassage,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildPhoneInfoRow(
                  Icons.phone,
                  'Contact',
                  _ramassageDetail!.contactRamassage,
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Informations de dates
                _buildDateInfoRow(
                  Icons.calendar_today,
                  'Date de demande',
                  _formatDate(_ramassageDetail!.dateDemande),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildDateInfoRow(
                  Icons.schedule,
                  'Date planifiée',
                  _formatDate(_ramassageDetail!.datePlanifiee),
                ),
                if (_ramassageDetail!.dateEffectuee != null) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  _buildDateInfoRow(
                    Icons.check_circle,
                    'Date effectuée',
                    _formatDate(_ramassageDetail!.dateEffectuee!),
                  ),
                ],
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        Icons.inventory_2,
                        'Colis',
                        '${_ramassageDetail!.nombreColisEstime}',
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildStatCardWithFormattedAmount(
                        Icons.attach_money,
                        'Montant',
                        _ramassageDetail!.montantTotal,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),
                if (_ramassageDetail!.notes != null &&
                    _ramassageDetail!.notes!.isNotEmpty) ...[
                  const SizedBox(height: AppDimensions.spacingS),
                  _buildNotesCard(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoRow(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  value,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInfoRow(IconData icon, String label, String phoneNumber) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                PhoneNumberCard(phoneNumber: phoneNumber, icon: Icons.phone),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardWithFormattedAmount(
    IconData icon,
    String label,
    String amount,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          AmountCard(
            amount: amount,
            currency: 'F',
            textColor: color,
            fontSize: AppDimensions.fontSizeS,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.note, size: 16, color: AppColors.warning),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notes',
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  _ramassageDetail!.notes!,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return AppColors.warning;
      case 'en_cours':
        return AppColors.primary;
      case 'termine':
        return AppColors.success;
      case 'annule':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatutFormatted(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return 'Planifié';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut;
    }
  }

  Color _getColisStatutColor(int status) {
    switch (status) {
      case 0:
        return AppColors.warning;
      case 1:
        return AppColors.primary;
      case 2:
        return AppColors.success;
      case 3:
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Column(
          children: [
            // Shimmer pour la carte header
            _buildShimmerHeaderCard(),
            const SizedBox(height: AppDimensions.spacingL),

            // Shimmer pour l'en-tête de section
            _buildShimmerSectionHeader(),
            const SizedBox(height: AppDimensions.spacingM),

            // Shimmer pour les cartes de colis
            ...List.generate(3, (index) => _buildShimmerColisCard(index)),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header shimmer
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 120,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Informations shimmer
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),

          // Cartes statistiques shimmer
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerSectionHeader() {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Container(
          width: 150,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const Spacer(),
        Container(
          width: 30,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerColisCard(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header shimmer
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 100,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 50,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),

          // Contenu shimmer
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  height: 30,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFixedActionButton() {
    if (_ramassageDetail == null) {
      return const SizedBox.shrink();
    }

    // Aucun bouton pour les ramassages terminés ou autres statuts
    if (_ramassageDetail!.statut != 'planifie' &&
        _ramassageDetail!.statut != 'en_cours') {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Bouton principal selon le statut
            _ramassageDetail!.statut == 'planifie'
                ? AppButton(
                  text: 'Démarrer le ramassage',
                  onPressed: _startRamassage,
                  type: AppButtonType.primary,
                  icon: Icons.play_arrow,
                  isFullWidth: true,
                )
                : _ramassageDetail!.statut == 'en_cours'
                ? AppButton(
                  text: 'Terminer le ramassage',
                  onPressed: _finishPickup,
                  type: AppButtonType.success,
                  icon: Icons.check_circle,
                  isFullWidth: true,
                )
                : const SizedBox.shrink(),

            // Bouton d'annulation (visible pour planifié et en cours)
            if (_ramassageDetail!.statut == 'planifie' ||
                _ramassageDetail!.statut == 'en_cours') ...[
              const SizedBox(height: AppDimensions.spacingS),
              AppButton(
                text: 'Annuler le ramassage',
                onPressed: _cancelRamassage,
                type: AppButtonType.outline,
                icon: Icons.cancel,
                isFullWidth: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _startRamassage() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Démarrer le ramassage',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir démarrer le ramassage ${_ramassageDetail!.codeRamassage} ?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Démarrer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Démarrer le ramassage
      final success = await _ramassageController.startRamassage(
        _ramassageDetail!.id,
      );

      if (success) {
        Get.snackbar(
          '📦 Ramassage démarré',
          'Vous avez commencé le ramassage ${_ramassageDetail!.codeRamassage}',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );

        // Recharger les détails pour mettre à jour le statut
        _loadRamassageDetails();
      } else {
        Get.snackbar(
          '❌ Erreur',
          _ramassageController.errorMessage,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _cancelRamassage() async {
    // Afficher un dialog de confirmation avec saisie de raison
    final result = await Get.dialog<Map<String, String>?>(
      _CancelRamassageDialog(ramassage: _ramassageDetail!),
    );

    if (result != null) {
      final raison = result['raison'] ?? '';
      final commentaire = result['commentaire'] ?? '';

      print('🔄 ===== ANNULATION RAMASSAGE - API CALL =====');
      print(
        '🔄 Ramassage ID: ${_ramassageDetail!.id}, Code: ${_ramassageDetail!.codeRamassage}',
      );
      print('🔄 Raison: $raison');
      print('🔄 Commentaire: $commentaire');

      // Appel à l'API d'annulation
      final authController = Get.find<AuthController>();
      final response = await CancelRamassageService.cancelRamassage(
        ramassageId: _ramassageDetail!.id,
        raison: raison,
        commentaire: commentaire,
        token: authController.authToken,
      );

      if (response.success) {
        print('✅ Ramassage annulé avec succès via API');

        // Actualiser les données de manière transparente
        try {
          await _ramassageController.refreshRamassages();
        } catch (e) {
          print('⚠️ Erreur lors de l\'actualisation des données: $e');
        }

        // Envoyer une notification locale de succès
        await _showLocalNotification(
          title: '✅ Ramassage annulé',
          body:
              'Le ramassage ${_ramassageDetail!.codeRamassage} a été annulé avec succès',
          type: 'success',
        );

        // Attendre un court délai pour que l'utilisateur voie le message
        await Future.delayed(const Duration(milliseconds: 500));

        // Retourner à l'écran d'origine avec succès
        print(
          '🔍 Retour à l\'écran d\'origine: ${widget.fromPage ?? "inconnu"}',
        );

        // Utiliser la page d'origine pour le retour
        if (widget.fromPage != null) {
          switch (widget.fromPage) {
            case 'dashboard':
              Get.offAllNamed('/dashboard?tab=ramassages');
              print('🔍 Navigation vers le dashboard (onglet Ramassages)');
              break;
            case 'ramassage_list':
              Get.back(result: true);
              print('🔍 Retour à la liste des ramassages');
              break;
            default:
              // Fallback vers le dashboard avec onglet Ramassages
              Get.offAllNamed('/dashboard?tab=ramassages');
              print(
                '🔍 Navigation par défaut vers le dashboard (onglet Ramassages)',
              );
          }
        } else {
          // Si pas de page d'origine spécifiée, essayer Get.back()
          try {
            Get.back(result: true);
            print('🔍 Get.back() exécuté avec succès');
          } catch (e) {
            print('⚠️ Get.back() a échoué: $e');
            Get.offAllNamed('/dashboard');
            print('🔍 Navigation de secours vers le dashboard');
          }
        }
      } else {
        print('❌ Échec de l\'annulation du ramassage: ${response.message}');
        // Envoyer une notification locale d'erreur
        await _showLocalNotification(
          title: '❌ Erreur',
          body: response.message,
          type: 'error',
        );
      }
    } else {
      print('❌ Annulation de ramassage échouée ou annulée');
    }
  }

  /// Construire la section des notes
  Widget _buildNotesSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Notes du ramassage
          if (_ramassageDetail!.notesRamassage != null &&
              _ramassageDetail!.notesRamassage!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.success.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: AppDimensions.spacingXS),
                      Text(
                        'Notes du ramassage',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    _ramassageDetail!.notesRamassage!,
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _finishPickup() async {
    if (_ramassageDetail == null) return;

    // Créer un objet Ramassage temporaire avec les données disponibles
    final ramassage = Ramassage(
      id: _ramassageDetail!.id,
      codeRamassage: _ramassageDetail!.codeRamassage,
      entrepriseId: _ramassageDetail!.entrepriseId,
      marchandId: _ramassageDetail!.marchandId,
      boutiqueId: _ramassageDetail!.boutiqueId,
      dateDemande: _ramassageDetail!.dateDemande,
      datePlanifiee: _ramassageDetail!.datePlanifiee,
      dateEffectuee: _ramassageDetail!.dateEffectuee,
      statut: _ramassageDetail!.statut,
      adresseRamassage: _ramassageDetail!.adresseRamassage,
      contactRamassage: _ramassageDetail!.contactRamassage,
      nombreColisEstime: _ramassageDetail!.nombreColisEstime,
      nombreColisReel: _ramassageDetail!.nombreColisReel,
      differenceColis: _ramassageDetail!.differenceColis,
      typeDifference: _ramassageDetail!.typeDifference,
      raisonDifference: _ramassageDetail!.raisonDifference,
      livreurId: _ramassageDetail!.livreurId,
      dateDebutRamassage: _ramassageDetail!.dateDebutRamassage,
      dateFinRamassage: _ramassageDetail!.dateFinRamassage,
      photoRamassage: _ramassageDetail!.photoRamassage,
      notesLivreur: _ramassageDetail!.notesLivreur,
      notesRamassage: _ramassageDetail!.notesRamassage,
      notes: _ramassageDetail!.notes,
      colisData: _ramassageDetail!.colisData,
      montantTotal: _ramassageDetail!.montantTotal,
      createdAt: _ramassageDetail!.createdAt,
      updatedAt: _ramassageDetail!.updatedAt,
      marchand: _ramassageDetail!.marchand,
      boutique: _ramassageDetail!.boutique,
      livreur: _ramassageDetail!.livreur,
    );

    // Naviguer vers l'écran de finalisation
    final result = await Get.to(
      () => CompleteRamassageScreen(
        ramassage: ramassage,
        fromPage: widget.fromPage ?? 'ramassage_details',
      ),
    );

    // Si la finalisation a réussi, recharger les détails
    if (result == true) {
      await _loadRamassageDetails();
    }
  }

  /// Obtenir le nombre de colis à afficher (maximum 10)
  int _getDisplayedColisCount() {
    if (_ramassageDetail == null) return 0;
    final count =
        _ramassageDetail!.colisLies.length > 10
            ? 10
            : _ramassageDetail!.colisLies.length;
    print(
      '🔍 Displaying $count colis out of ${_ramassageDetail!.colisLies.length} total',
    );
    return count;
  }

  /// Extraire les URLs des photos depuis notesLivreur
  List<String> _extractPhotoUrls() {
    if (_ramassageDetail?.notesLivreur == null) return [];

    final notes = _ramassageDetail!.notesLivreur!;
    final List<String> photoUrls = [];

    // Chercher les noms de fichiers dans les notes
    final RegExp photoRegex = RegExp(r'colis_\d+_\d+_\d+\.jpg');
    final matches = photoRegex.allMatches(notes);

    for (final match in matches) {
      final fileName = match.group(0)!;
      final photoUrl =
          '${ApiConstants.baseUrl}/storage/ramassages/photos/$fileName';
      photoUrls.add(photoUrl);
    }

    print('🔍 Extracted ${photoUrls.length} photo URLs: $photoUrls');
    return photoUrls;
  }

  /// Construire la section des photos des colis ramassés
  Widget _buildColisPhotosSection() {
    final photoUrls = _extractPhotoUrls();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Header
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    'Photos des colis ramassés',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeS,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingS,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.success, width: 1),
                  ),
                  child: Text(
                    '${photoUrls.length} photo${photoUrls.length > 1 ? 's' : ''}',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grille des photos
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppDimensions.spacingS,
                mainAxisSpacing: AppDimensions.spacingS,
                childAspectRatio: 1.2,
              ),
              itemCount: photoUrls.length,
              itemBuilder: (context, index) {
                return _buildColisPhotoCard(photoUrls[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Construire une carte de photo de colis
  Widget _buildColisPhotoCard(String photoUrl, int index) {
    return GestureDetector(
      onTap: () => _showPhotoFullScreen(photoUrl),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Stack(
            children: [
              // Image
              Image.network(
                photoUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade100,
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        color: Colors.grey,
                        size: 24,
                      ),
                    ),
                  );
                },
              ),

              // Overlay avec numéro
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Icône de zoom
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Afficher une photo en plein écran
  void _showPhotoFullScreen(String photoUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              // Image en plein écran
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.network(
                    photoUrl,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Erreur de chargement de l\'image',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Bouton de fermeture
              Positioned(
                top: 40,
                right: 20,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Construire le bouton "Voir plus"
  Widget _buildVoirPlusButton() {
    final totalColis = _ramassageDetail?.colisLies.length ?? 0;
    final displayedColis = _getDisplayedColisCount();
    final remainingColis = totalColis - displayedColis;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _navigateToRamassageList,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, color: AppColors.primary, size: 20),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  'Voir plus ($remainingColis colis restants)',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Naviguer vers la liste complète des ramassages
  void _navigateToRamassageList() {
    Get.to(() => const RamassageListScreen());
  }

  /// Construire une ligne d'information pour les dates
  Widget _buildDateInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: AppDimensions.spacingS),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeXS,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Formater une date ISO en format lisible
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date).inDays;

      // Format de base
      final formattedDate =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
      final formattedTime =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

      // Ajouter un indicateur relatif
      String relativeIndicator = '';
      if (difference == 0) {
        relativeIndicator = ' (Aujourd\'hui)';
      } else if (difference == 1) {
        relativeIndicator = ' (Hier)';
      } else if (difference > 1 && difference <= 7) {
        relativeIndicator = ' (Il y a $difference jours)';
      } else if (difference < 0) {
        final futureDays = -difference;
        if (futureDays == 1) {
          relativeIndicator = ' (Demain)';
        } else {
          relativeIndicator = ' (Dans $futureDays jours)';
        }
      }

      return '$formattedDate à $formattedTime$relativeIndicator';
    } catch (e) {
      return dateString; // Retourner la chaîne originale en cas d'erreur
    }
  }

  /// Construire l'en-tête de la section des colis
  Widget _buildColisSectionHeader() {
    final colisCount = _ramassageDetail?.colisLies.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.inventory_2, color: Colors.white, size: 16),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colis du ramassage',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  colisCount > 0
                      ? '$colisCount colis trouvé${colisCount > 1 ? 's' : ''}'
                      : 'Aucun colis trouvé',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w500,
                    color:
                        colisCount > 0 ? AppColors.success : AppColors.warning,
                  ),
                ),
              ],
            ),
          ),
          if (colisCount == 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingS,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'Debug',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Construire la section des photos des colis
  Widget _buildPhotosSection() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Photo du ramassage',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Photo prise lors du ramassage',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Photo unique
          GestureDetector(
            onTap: () => _showPhotoDialog(_ramassageDetail!.photoRamassage!),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: _buildPhotoWidget(_ramassageDetail!.photoRamassage!),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construire le widget de photo
  Widget _buildPhotoWidget(String photoPath) {
    // Si c'est une URL complète
    if (photoPath.startsWith('http')) {
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPhotoError();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPhotoLoading();
        },
      );
    } else {
      // Si c'est un chemin relatif, construire l'URL complète
      final fullUrl = '${ApiConstants.baseUrl}/storage/$photoPath';
      return Image.network(
        fullUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPhotoError();
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildPhotoLoading();
        },
      );
    }
  }

  /// Widget d'erreur pour les photos
  Widget _buildPhotoError() {
    return Container(
      color: Colors.grey.shade200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.broken_image, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  /// Widget de chargement pour les photos
  Widget _buildPhotoLoading() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ),
    );
  }

  /// Afficher la photo en plein écran
  void _showPhotoDialog(String photoPath) {
    final fullUrl =
        photoPath.startsWith('http')
            ? photoPath
            : '${ApiConstants.baseUrl}/storage/$photoPath';

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Image en plein écran
                Center(
                  child: InteractiveViewer(
                    child: Image.network(
                      fullUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.broken_image,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Impossible de charger l\'image',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Bouton de fermeture
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

/// Dialog pour l'annulation de ramassage
class _CancelRamassageDialog extends StatefulWidget {
  final RamassageDetail ramassage;

  const _CancelRamassageDialog({required this.ramassage});

  @override
  State<_CancelRamassageDialog> createState() => _CancelRamassageDialogState();
}

class _CancelRamassageDialogState extends State<_CancelRamassageDialog> {
  final _raisonController = TextEditingController();
  final _commentaireController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _raisonsOptions = [
    'Problème technique avec le véhicule',
    'Client absent',
    'Adresse inaccessible',
    'Problème de sécurité',
    'Conditions météorologiques',
    'Autre',
  ];

  final List<String> _commentairesOptions = [
    'Véhicule en panne, impossible de se déplacer',
    'Client non joignable',
    'Adresse incorrecte ou introuvable',
    'Problème de sécurité dans la zone',
    'Conditions météorologiques dangereuses',
    'Client a annulé le rendez-vous',
    'Problème de communication',
    'Autre raison',
  ];

  String? _selectedRaison;
  String? _selectedCommentaire;

  @override
  void dispose() {
    _raisonController.dispose();
    _commentaireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.cancel, color: AppColors.error, size: 20),
          ),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              'Annuler le ramassage',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
          ),
        ],
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ramassage: ${widget.ramassage.codeRamassage}',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),

            // Raison
            Text(
              'Raison de l\'annulation *',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            DropdownButtonFormField<String>(
              value: _selectedRaison,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(AppDimensions.spacingS),
              ),
              hint: Text(
                'Sélectionnez une raison',
                style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary,
                  fontSize: AppDimensions.fontSizeXS,
                ),
              ),
              items:
                  _raisonsOptions.map((raison) {
                    return DropdownMenuItem(
                      value: raison,
                      child: Text(
                        raison,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                        ),
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRaison = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez sélectionner une raison';
                }
                return null;
              },
            ),
            const SizedBox(height: AppDimensions.spacingS),

            // Commentaire
            Text(
              'Commentaire (optionnel)',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingXS),
            DropdownButtonFormField<String>(
              value: _selectedCommentaire,
              isExpanded: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                contentPadding: const EdgeInsets.all(AppDimensions.spacingS),
              ),
              hint: Text(
                'Sélectionnez un commentaire',
                style: GoogleFonts.montserrat(
                  color: AppColors.textSecondary,
                  fontSize: AppDimensions.fontSizeXS,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              items:
                  _commentairesOptions.map((commentaire) {
                    return DropdownMenuItem(
                      value: commentaire,
                      child: Text(
                        commentaire,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCommentaire = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Annuler',
            style: GoogleFonts.montserrat(color: AppColors.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Get.back(
                result: {
                  'raison': _selectedRaison!,
                  'commentaire': _selectedCommentaire ?? '',
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          child: Text(
            'Confirmer l\'annulation',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
