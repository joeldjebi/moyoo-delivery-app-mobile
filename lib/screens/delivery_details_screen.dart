import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/delivery_detail_models.dart';
import '../services/delivery_service.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/delivery_controller.dart';
import '../widgets/formatted_amount_widget.dart';
import '../widgets/clickable_phone_widget.dart';
import '../widgets/app_button.dart';
import '../widgets/location_widget.dart';
import 'complete_delivery_screen.dart';
import 'cancel_delivery_screen.dart';

class DeliveryDetailsScreen extends StatefulWidget {
  final int colisId;
  final String codeColis;

  const DeliveryDetailsScreen({
    super.key,
    required this.colisId,
    required this.codeColis,
  });

  @override
  State<DeliveryDetailsScreen> createState() => _DeliveryDetailsScreenState();
}

class _DeliveryDetailsScreenState extends State<DeliveryDetailsScreen> {
  ColisDetail? _colisDetail;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadColisDetails();
    _checkNotificationRefreshFlags();
  }

  /// Vérifier les flags d'actualisation des notifications
  void _checkNotificationRefreshFlags() {
    try {
      print(
        '🔄 Vérification des flags d\'actualisation des notifications (DeliveryDetailsScreen)',
      );
      NotificationService.checkAndProcessRefreshFlags();
    } catch (e) {
      print('❌ Erreur lors de la vérification des flags: $e');
    }
  }

  Future<void> _loadColisDetails() async {
    try {
      print(
        '🔍 [DeliveryDetails] _loadColisDetails() - Début, colisId: ${widget.colisId}',
      );
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        print('❌ [DeliveryDetails] Token manquant');
        throw Exception('Token d\'authentification manquant');
      }

      print('🔍 [DeliveryDetails] Appel à DeliveryService.getColisDetails()');
      final response = await DeliveryService.getColisDetails(
        colisId: widget.colisId,
        token: token,
      );

      print('🔍 [DeliveryDetails] Réponse reçue:');
      print('   - success: ${response.success}');
      print('   - message: ${response.message}');
      print('   - data.id: ${response.data.id}');
      print('   - data.status: ${response.data.status}');
      print('   - data.code: ${response.data.code}');

      // Si la réponse est réussie OU si les données sont présentes (même si success est false)
      // Cela permet d'afficher les détails même pour les colis livrés qui pourraient avoir success: false
      if (response.success || response.data.id > 0) {
        print('✅ [DeliveryDetails] Données valides, affichage du contenu');
        setState(() {
          _colisDetail = response.data;
          _isLoading = false;
          _errorMessage = ''; // S'assurer que le message d'erreur est vidé
        });
      } else {
        // Si success est false ET qu'il n'y a pas de données valides
        print(
          '❌ [DeliveryDetails] Données invalides: success=${response.success}, id=${response.data.id}',
        );
        throw Exception(
          response.message.isNotEmpty
              ? response.message
              : 'Impossible de charger les détails du colis',
        );
      }
    } catch (e, stackTrace) {
      print('❌ [DeliveryDetails] Erreur lors du chargement: $e');
      print('❌ [DeliveryDetails] Stack trace: $stackTrace');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _colisDetail != null
              ? _buildContent()
              : const Center(child: Text('Aucune donnée disponible')),
      bottomNavigationBar: _colisDetail != null ? _buildActionButtons() : null,
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
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.all(AppDimensions.spacingS),
        ),
      ),
      title: Column(
        children: [
          Text(
            'Détails du colis',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeL,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          if (_colisDetail != null)
            Text(
              _colisDetail!.code,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
      centerTitle: true,
      actions: [
        // Indicateur de localisation
        Container(
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          child: const LocationIndicatorWidget(),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(AppDimensions.spacingL),
        padding: const EdgeInsets.all(AppDimensions.spacingXL),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
          boxShadow: [
            BoxShadow(
              color: AppColors.error.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.error.withOpacity(0.1),
                    AppColors.error.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusL),
              ),
              child: Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeL,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              _errorMessage,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppDimensions.spacingL),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _loadColisDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppDimensions.spacingM,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                ),
                child: Text(
                  'Réessayer',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final colis = _colisDetail!;
    final statutColor = _getStatutColor(colis.status);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec code et statut
          _buildHeaderCard(colis, statutColor),

          const SizedBox(height: AppDimensions.spacingS),

          // Informations du client
          _buildClientInfoCard(colis),

          const SizedBox(height: AppDimensions.spacingS),

          // Informations de livraison
          _buildDeliveryInfoCard(colis),

          const SizedBox(height: AppDimensions.spacingS),

          // Informations du colis (poids, mode, temp)
          _buildColisInfoCard(colis),

          const SizedBox(height: AppDimensions.spacingS),

          // Informations du marchand et boutique
          _buildMarchandBoutiqueCard(colis),

          const SizedBox(height: AppDimensions.spacingS),

          // Informations financières
          _buildFinancialInfoCard(colis),

          const SizedBox(height: AppDimensions.spacingS),

          // Historique de livraison
          _buildHistoryCard(colis),

          // Preuves de livraison (photo et signature) - uniquement si livré
          if (colis.status == 2) ...[
            const SizedBox(height: AppDimensions.spacingS),
            _buildProofCard(colis),
          ],

          const SizedBox(height: AppDimensions.spacingM),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ColisDetail colis, Color statutColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, statutColor.withOpacity(0.02)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: statutColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Barre de statut colorée avec gradient
          Container(
            height: 6,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statutColor, statutColor.withOpacity(0.7)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                // Icône et code du colis
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.spacingXS),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statutColor, statutColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statutColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_shipping,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            colis.code,
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeS,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppDimensions.spacingXS),
                          Text(
                            'Numéro de facture: ${colis.numeroFacture}',
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingM,
                        vertical: AppDimensions.spacingS,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [statutColor, statutColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusM,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statutColor.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        colis.statutFormatted,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
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

  Widget _buildClientInfoCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du client',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Détails du destinataire',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                _buildModernInfoRow(
                  'Nom',
                  colis.nomClient,
                  Icons.person_outline,
                ),
                _buildModernInfoRow(
                  'Téléphone',
                  colis.telephoneClient,
                  Icons.phone,
                  isPhone: true,
                ),
                _buildModernInfoRow(
                  'Adresse',
                  colis.adresseClient,
                  Icons.location_on,
                  isLocation: true,
                ),
                _buildModernInfoRow(
                  'Commune',
                  colis.commune.libelle,
                  Icons.location_city,
                  isLocation: true,
                ),
                if (colis.noteClient.isNotEmpty)
                  _buildModernInfoRow(
                    'Note client',
                    colis.noteClient,
                    Icons.note,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations de livraison',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Détails de l\'expédition',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                _buildModernInfoRow(
                  'Numéro de livraison',
                  colis.livraison.numeroDeLivraison,
                  Icons.confirmation_number,
                ),
                _buildModernInfoRow(
                  'Adresse de livraison',
                  colis.livraison.adresseDeLivraison,
                  Icons.location_on,
                ),
                _buildModernInfoRow(
                  'Code de validation',
                  colis.livraison.codeValidation,
                  Icons.verified_user,
                ),
                if (colis.livraison.noteLivraison != null &&
                    colis.livraison.noteLivraison!.isNotEmpty)
                  _buildModernInfoRow(
                    'Note de livraison',
                    colis.livraison.noteLivraison!,
                    Icons.note,
                  ),
                if (colis.instructionsLivraison != null &&
                    colis.instructionsLivraison!.isNotEmpty)
                  _buildModernInfoRow(
                    'Instructions',
                    colis.instructionsLivraison!,
                    Icons.assignment,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColisInfoCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.1),
                  AppColors.primary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du colis',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Caractéristiques du colis',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildModernInfoRow(
                        'Poids',
                        colis.poids.libelle,
                        Icons.fitness_center,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildModernInfoRow(
                        'Type de colis',
                        colis.typeColis.libelle,
                        Icons.inventory,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Row(
                  children: [
                    Expanded(
                      child: _buildModernInfoRow(
                        'Mode de livraison',
                        colis.modeLivraison.libelle,
                        Icons.local_shipping,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildModernInfoRow(
                        'Délai',
                        colis.delai.libelle,
                        Icons.timer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildModernInfoRow(
                  'Conditionnement',
                  colis.conditionnementColis.libelle,
                  Icons.inventory_2,
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildModernInfoRow(
                  'Période de livraison',
                  colis.temp.libelle,
                  Icons.access_time,
                ),
                if (colis.temp.description.isNotEmpty)
                  _buildModernInfoRow(
                    'Description',
                    colis.temp.description,
                    Icons.info_outline,
                  ),
                if (colis.temp.heureDebut.isNotEmpty &&
                    colis.temp.heureFin.isNotEmpty)
                  _buildModernInfoRow(
                    'Horaires',
                    '${colis.temp.heureDebut} - ${colis.temp.heureFin}',
                    Icons.schedule,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarchandBoutiqueCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.store, color: Colors.white, size: 18),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Marchand & Boutique',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Informations du vendeur',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                // Informations du marchand
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Text(
                            'Marchand',
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      _buildModernInfoRow(
                        'Nom',
                        colis.marchand.fullName,
                        Icons.person,
                      ),
                      _buildModernInfoRow(
                        'Téléphone',
                        colis.marchand.mobile,
                        Icons.phone,
                        isPhone: true,
                      ),
                      _buildModernInfoRow(
                        'Adresse',
                        colis.marchand.adresse,
                        Icons.location_on,
                        isLocation: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                // Informations de la boutique
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: AppDimensions.spacingS),
                          Text(
                            'Boutique',
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.spacingS),
                      _buildModernInfoRow(
                        'Nom',
                        colis.boutique.libelle,
                        Icons.store,
                      ),
                      _buildModernInfoRow(
                        'Téléphone',
                        colis.boutique.mobile,
                        Icons.phone,
                        isPhone: true,
                      ),
                      _buildModernInfoRow(
                        'Adresse',
                        colis.boutique.adresse,
                        Icons.location_on,
                        isLocation: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialInfoCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.warning.withOpacity(0.1),
                  AppColors.warning.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.warning,
                        AppColors.warning.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.warning.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations financières',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Détails des montants',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildModernAmountCard(
                        'Montant à encaisser',
                        colis.montantAEncaisse.toString(),
                        AppColors.primary,
                        Icons.money,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: _buildModernAmountCard(
                        'Prix de vente',
                        colis.prixDeVente.toString(),
                        AppColors.success,
                        Icons.sell,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),
                _buildModernAmountCard(
                  'Montant de la livraison',
                  colis.historiqueLivraison.montantDeLaLivraison.toString(),
                  AppColors.warning,
                  Icons.local_shipping,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ColisDetail colis) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.textSecondary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.textSecondary.withOpacity(0.1),
                  AppColors.textSecondary.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.textSecondary,
                        AppColors.textSecondary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Historique de livraison',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Suivi des modifications',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                _buildModernInfoRow(
                  'Statut historique',
                  colis.historiqueLivraison.status,
                  Icons.info,
                ),
                _buildModernInfoRow(
                  'Créé le',
                  _formatDate(colis.historiqueLivraison.createdAt),
                  Icons.add_circle,
                ),
                _buildModernInfoRow(
                  'Modifié le',
                  _formatDate(colis.historiqueLivraison.updatedAt),
                  Icons.edit,
                ),
                if (colis.historiqueLivraison.dateLivraisonEffective != null)
                  _buildModernInfoRow(
                    'Date de livraison effective',
                    _formatDate(
                      colis.historiqueLivraison.dateLivraisonEffective!,
                    ),
                    Icons.check_circle,
                  ),
                if (colis.historiqueLivraison.noteLivraison != null &&
                    colis.historiqueLivraison.noteLivraison!.isNotEmpty)
                  _buildModernInfoRow(
                    'Note de livraison',
                    colis.historiqueLivraison.noteLivraison!,
                    Icons.note,
                  ),
                if (colis.historiqueLivraison.motifAnnulation != null &&
                    colis.historiqueLivraison.motifAnnulation!.isNotEmpty)
                  _buildModernInfoRow(
                    'Motif d\'annulation',
                    colis.historiqueLivraison.motifAnnulation!,
                    Icons.cancel,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofCard(ColisDetail colis) {
    final historique = colis.historiqueLivraison;

    print(
      '🔍 [DeliveryDetails] _buildProofCard - photoProofPaths: ${historique.photoProofPaths}',
    );
    print(
      '🔍 [DeliveryDetails] _buildProofCard - photoProofPaths != null: ${historique.photoProofPaths != null}',
    );
    if (historique.photoProofPaths != null) {
      print(
        '🔍 [DeliveryDetails] _buildProofCard - photoProofPaths.length: ${historique.photoProofPaths!.length}',
      );
      print(
        '🔍 [DeliveryDetails] _buildProofCard - photoProofPaths.isNotEmpty: ${historique.photoProofPaths!.isNotEmpty}',
      );
    }

    final hasPhoto =
        historique.photoProofPaths != null &&
        historique.photoProofPaths!.isNotEmpty;
    final hasSignature =
        historique.signatureData != null &&
        historique.signatureData!.isNotEmpty;

    print(
      '🔍 [DeliveryDetails] _buildProofCard - hasPhoto: $hasPhoto, hasSignature: $hasSignature',
    );

    // Si aucune preuve n'est disponible, ne pas afficher la carte
    if (!hasPhoto && !hasSignature) {
      print(
        '⚠️ [DeliveryDetails] _buildProofCard - Aucune preuve disponible, carte masquée',
      );
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // En-tête avec gradient
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.success.withOpacity(0.1),
                  AppColors.success.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusL),
                topRight: Radius.circular(AppDimensions.radiusL),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.success.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.verified,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Preuves de livraison',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeM,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      Text(
                        'Photo et signature',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                // Photos de preuve
                if (hasPhoto) ...[
                  _buildPhotoProofs(historique.photoProofPaths!),
                  const SizedBox(height: AppDimensions.spacingM),
                ],
                // Signature
                if (hasSignature) ...[
                  _buildSignature(historique.signatureData!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoProofs(List<String> photoPaths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          photoPaths.length == 1
              ? 'Photo de preuve'
              : 'Photos de preuve (${photoPaths.length})',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        // Si une seule photo, afficher en grand
        if (photoPaths.length == 1)
          _buildSinglePhoto(photoPaths[0])
        else
          // Si plusieurs photos, afficher en grille
          _buildPhotoGrid(photoPaths),
      ],
    );
  }

  Widget _buildSinglePhoto(String photoPath) {
    // Construire l'URL complète
    final photoUrl =
        photoPath.startsWith('http')
            ? photoPath
            : 'http://192.168.1.8:8000/storage/$photoPath';

    return GestureDetector(
      onTap: () => _showPhotoFullScreen(photoUrl),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: AppColors.border.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            width: double.infinity,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Colors.grey, size: 32),
                      SizedBox(height: AppDimensions.spacingS),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoGrid(List<String> photoPaths) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingS,
        mainAxisSpacing: AppDimensions.spacingS,
        childAspectRatio: 1.0,
      ),
      itemCount: photoPaths.length,
      itemBuilder: (context, index) {
        final photoPath = photoPaths[index];
        // Construire l'URL complète
        final photoUrl =
            photoPath.startsWith('http')
                ? photoPath
                : 'http://192.168.1.8:8000/storage/$photoPath';

        return GestureDetector(
          onTap: () => _showPhotoFullScreen(photoUrl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              border: Border.all(
                color: AppColors.border.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photoUrl,
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
                  // Badge avec numéro si plusieurs photos
                  if (photoPaths.length > 1)
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
                          borderRadius: BorderRadius.circular(8),
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSignature(String signatureData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Signature',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: AppColors.border.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: _buildSignatureImage(signatureData),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureImage(String signatureData) {
    // Si la signature est en base64, la décoder
    if (signatureData.startsWith('data:image')) {
      // Format data:image/png;base64,...
      final base64String = signatureData.split(',').last;
      try {
        final bytes = base64Decode(base64String);
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (e) {
        print('❌ Erreur lors du décodage de la signature: $e');
      }
    } else if (signatureData.startsWith('http')) {
      // URL complète
      return Image.network(
        signatureData,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        },
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error_outline, color: Colors.grey, size: 32),
          );
        },
      );
    } else {
      // Essayer de traiter comme base64 pur
      try {
        final bytes = base64Decode(signatureData);
        return Image.memory(bytes, fit: BoxFit.contain);
      } catch (e) {
        print('❌ Erreur lors du décodage de la signature base64: $e');
      }
    }

    // Par défaut, afficher un message d'erreur
    return Container(
      color: Colors.grey.shade100,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.grey, size: 32),
            SizedBox(height: AppDimensions.spacingS),
            Text(
              'Signature non disponible',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

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
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModernInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isPhone = false,
    bool isLocation = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingXS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: Icon(icon, color: AppColors.primary, size: 14),
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
                const SizedBox(height: AppDimensions.spacingXS),
                isPhone
                    ? ClickablePhoneWidget(phoneNumber: value)
                    : Text(
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
          // Bouton d'appel pour les numéros de téléphone
          if (isPhone) ...[
            const SizedBox(width: AppDimensions.spacingS),
            GestureDetector(
              onTap: () => _makePhoneCall(value),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 16),
              ),
            ),
          ],
          // Bouton Maps pour les adresses et communes
          if (isLocation) ...[
            const SizedBox(width: AppDimensions.spacingS),
            GestureDetector(
              onTap: () => _openGoogleMaps(value),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.spacingS),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.map, color: Colors.white, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModernAmountCard(
    String title,
    String amount,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingXS),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                child: Icon(icon, color: color, size: 14),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),
          AmountListItem(
            amount: amount,
            currency: 'F',
            textColor: color,
            fontSize: AppDimensions.fontSizeM,
            fontWeight: FontWeight.bold,
          ),
        ],
      ),
    );
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
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      // Nettoyer le numéro de téléphone (enlever les espaces, tirets, etc.)
      final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // Ajouter le préfixe tel: si ce n'est pas déjà présent
      final uri =
          cleanNumber.startsWith('tel:')
              ? Uri.parse(cleanNumber)
              : Uri.parse('tel:$cleanNumber');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de lancer l\'appel vers $phoneNumber',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du lancement de l\'appel: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _openGoogleMaps(String address) async {
    try {
      // Nettoyer l'adresse (enlever les caractères spéciaux et remplacer les espaces par +)
      final cleanAddress = address
          .replaceAll(RegExp(r'[^\w\s]'), '')
          .replaceAll(' ', '+');

      // Essayer d'abord avec l'URL Google Maps native
      final googleMapsUrl = 'https://maps.google.com/maps?q=$cleanAddress';
      final uri = Uri.parse(googleMapsUrl);

      // Essayer de lancer l'URL
      bool launched = false;

      try {
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          launched = true;
        }
      } catch (e) {
        try {
          await launchUrl(uri);
          launched = true;
        } catch (e2) {}
      }

      // Si l'URL Google Maps échoue, essayer avec une URL de géolocalisation native
      if (!launched) {
        final geoUrl = 'geo:0,0?q=$cleanAddress';
        final geoUri = Uri.parse(geoUrl);

        try {
          if (await canLaunchUrl(geoUri)) {
            await launchUrl(geoUri, mode: LaunchMode.externalApplication);
            launched = true;
          }
        } catch (e) {}
      }

      // Si la géolocalisation native échoue, essayer avec une URL de recherche web
      if (!launched) {
        final webSearchUrl =
            'https://www.google.com/search?q=$cleanAddress+location';
        final webUri = Uri.parse(webSearchUrl);

        try {
          if (await canLaunchUrl(webUri)) {
            await launchUrl(webUri, mode: LaunchMode.externalApplication);
            launched = true;
          }
        } catch (e) {}
      }

      if (!launched) {
        Get.snackbar(
          'Google Maps requis',
          'Pour utiliser la navigation, veuillez installer Google Maps depuis le Play Store.',
          backgroundColor: AppColors.warning,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
          borderRadius: 10,
          icon: const Icon(Icons.map, color: Colors.white),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de l\'ouverture de la navigation: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Widget _buildActionButtons() {
    if (_colisDetail == null) return const SizedBox.shrink();

    final colis = _colisDetail!;
    final isEnAttente = colis.status == 0;
    final isEnCours = colis.status == 1;

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
        child: Row(
          children: [
            // Bouton Annuler (toujours visible sauf si livré)
            if (colis.status != 2) ...[
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _cancelDelivery(colis),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.buttonPaddingHorizontal,
                      vertical: AppDimensions.buttonPaddingVertical,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusM,
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.cancel,
                        size: AppDimensions.iconSizeM,
                        color: Colors.white,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Text(
                        'Annuler',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeS,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
            ],
            // Bouton Démarrer (visible si en attente)
            if (isEnAttente) ...[
              Expanded(
                child: AppButton(
                  text: 'Démarrer',
                  onPressed: () => _startDelivery(colis),
                  type: AppButtonType.primary,
                  icon: Icons.play_arrow,
                ),
              ),
            ],
            // Bouton Terminer (visible si en cours)
            if (isEnCours) ...[
              Expanded(
                child: AppButton(
                  text: 'Terminer',
                  onPressed: () => _completeDelivery(colis),
                  type: AppButtonType.success,
                  icon: Icons.check,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _startDelivery(ColisDetail colis) async {
    try {
      // Afficher un dialog de confirmation
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(
            'Démarrer la livraison',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Voulez-vous démarrer la livraison du colis ${colis.code} ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            AppButton(
              text: 'Annuler',
              onPressed: () => Get.back(result: false),
              type: AppButtonType.secondary,
            ),
            AppButton(
              text: 'Démarrer',
              onPressed: () => Get.back(result: true),
              type: AppButtonType.primary,
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Utiliser le controller pour démarrer la livraison avec rafraîchissement transparent
        final deliveryController = Get.find<DeliveryController>();
        final success = await deliveryController.startDelivery(colis.id);

        if (success) {
          await LocalNotificationService().showSuccessNotification(
            title: 'Livraison démarrée',
            message: 'Livraison démarrée avec succès',
            payload: 'delivery_started_${colis.id}',
          );

          // Recharger les détails du colis pour refléter le nouveau statut
          _loadColisDetails();
        } else {
          // Vérifier si c'est le cas des livraisons actives pour afficher un dialog spécial
          if (deliveryController.errorMessage.contains(
            'Vous avez déjà une livraison en cours',
          )) {
            await _showActiveDeliveriesDialog(deliveryController.errorMessage);
          } else {
            await LocalNotificationService().showErrorNotification(
              title: 'Erreur',
              message: deliveryController.errorMessage,
              payload: 'delivery_start_error_${colis.id}',
            );
          }
        }
      }
    } catch (e) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors du démarrage de la livraison: $e',
        payload: 'delivery_start_exception_${colis.id}',
      );
    }
  }

  Future<void> _completeDelivery(ColisDetail colis) async {
    try {
      // Afficher un dialog de confirmation
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: Text(
            'Terminer la livraison',
            style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Voulez-vous terminer la livraison du colis ${colis.code} ?',
            style: GoogleFonts.montserrat(),
          ),
          actions: [
            AppButton(
              text: 'Annuler',
              onPressed: () => Get.back(result: false),
              type: AppButtonType.secondary,
            ),
            AppButton(
              text: 'Terminer',
              onPressed: () => Get.back(result: true),
              type: AppButtonType.success,
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // Naviguer vers l'écran de finalisation
        final result = await Get.to(
          () => CompleteDeliveryScreen(
            colisId: colis.id,
            codeColis: colis.code,
            codeValidation: colis.livraison.codeValidation,
            fromPage: 'delivery_details',
          ),
        );

        // Si la finalisation a réussi, recharger les détails
        if (result == true) {
          _loadColisDetails();
        }
      }
    } catch (e) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de la finalisation de la livraison: $e',
        payload: 'delivery_complete_exception_${colis.id}',
      );
    }
  }

  Future<void> _cancelDelivery(ColisDetail colis) async {
    try {
      // Naviguer vers l'écran d'annulation
      final result = await Get.to(
        () => CancelDeliveryScreen(
          colisId: colis.id,
          codeColis: colis.code,
          fromPage: 'delivery_details',
        ),
      );

      // Si l'annulation a réussi, recharger les détails
      if (result == true) {
        _loadColisDetails();
      }
    } catch (e) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de l\'annulation de la livraison: $e',
        payload: 'delivery_cancel_exception_${colis.id}',
      );
    }
  }

  /// Afficher un dialog pour les livraisons actives
  Future<void> _showActiveDeliveriesDialog(String errorMessage) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                'Livraison en cours',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.fontSizeM,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous avez déjà une livraison en cours. Terminez-la avant d\'en démarrer une nouvelle.',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Livraison active :',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    errorMessage.split('Livraisons en cours :')[1].trim(),
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Compris',
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }
}
