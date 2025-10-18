import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../services/delivery_service.dart';
import '../services/local_notification_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/delivery_controller.dart';

class CancelDeliveryScreen extends StatefulWidget {
  final int colisId;
  final String codeColis;
  final String? fromPage;

  const CancelDeliveryScreen({
    super.key,
    required this.colisId,
    required this.codeColis,
    this.fromPage,
  });

  @override
  State<CancelDeliveryScreen> createState() => _CancelDeliveryScreenState();
}

class _CancelDeliveryScreenState extends State<CancelDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();

  String _selectedMotif = '';
  String _selectedNote = '';
  bool _isLoading = false;

  // Motifs prédéfinis pour l'annulation
  final List<String> _predefinedMotifs = [
    'Client absent',
    'Client non joignable',
    'Adresse incorrecte',
    'Client refuse le colis',
    'Colis endommagé',
    'Problème de paiement',
    'Adresse inaccessible',
    'Client déménagé',
    'Numéro de téléphone incorrect',
    'Autre raison',
  ];

  // Notes prédéfinies pour l'annulation
  final List<String> _predefinedNotes = [
    'Client absent au moment de la livraison',
    'Client non joignable par téléphone',
    'Adresse de livraison incorrecte',
    'Client refuse de recevoir le colis',
    'Colis endommagé lors du transport',
    'Problème de paiement non résolu',
    'Adresse inaccessible par véhicule',
    'Client a déménagé sans laisser de contact',
    'Numéro de téléphone incorrect ou inexistant',
    'Autre raison non spécifiée',
  ];

  @override
  void dispose() {
    super.dispose();
  }

  void _showMotifSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Row(
                  children: [
                    Text(
                      'Sélectionner un motif',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Motifs list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                  ),
                  itemCount: _predefinedMotifs.length,
                  itemBuilder: (context, index) {
                    final motif = _predefinedMotifs[index];
                    final isSelected = _selectedMotif == motif;

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingS,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedMotif = motif;
                            });
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.error.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusS,
                              ),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.error
                                        : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.error
                                              : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    color:
                                        isSelected
                                            ? AppColors.error
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: AppDimensions.spacingM),
                                Expanded(
                                  child: Text(
                                    motif,
                                    style: GoogleFonts.montserrat(
                                      fontSize: AppDimensions.fontSizeS,
                                      color:
                                          isSelected
                                              ? AppColors.error
                                              : AppColors.textPrimary,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNoteSelectionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Row(
                  children: [
                    Text(
                      'Sélectionner une note',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeL,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Notes list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                  ),
                  itemCount: _predefinedNotes.length,
                  itemBuilder: (context, index) {
                    final note = _predefinedNotes[index];
                    final isSelected = _selectedNote == note;

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingS,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedNote = note;
                            });
                            Navigator.of(context).pop();
                          },
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(
                              AppDimensions.spacingM,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppColors.primary.withOpacity(0.1)
                                      : Colors.transparent,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusS,
                              ),
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : Colors.grey.shade400,
                                      width: 2,
                                    ),
                                    color:
                                        isSelected
                                            ? AppColors.primary
                                            : Colors.transparent,
                                  ),
                                  child:
                                      isSelected
                                          ? const Icon(
                                            Icons.check,
                                            size: 12,
                                            color: Colors.white,
                                          )
                                          : null,
                                ),
                                const SizedBox(width: AppDimensions.spacingM),
                                Expanded(
                                  child: Text(
                                    note,
                                    style: GoogleFonts.montserrat(
                                      fontSize: AppDimensions.fontSizeS,
                                      color:
                                          isSelected
                                              ? AppColors.primary
                                              : AppColors.textPrimary,
                                      fontWeight:
                                          isSelected
                                              ? FontWeight.w500
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _cancelDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMotif.isEmpty) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Veuillez sélectionner un motif d\'annulation',
        payload: 'motif_not_selected',
      );
      return;
    }

    if (_selectedNote.isEmpty) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Veuillez sélectionner une note d\'annulation',
        payload: 'note_not_selected',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authController = Get.find<AuthController>();
      final token = authController.authToken;

      if (token.isEmpty) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await DeliveryService.cancelDelivery(
        colisId: widget.colisId,
        motifAnnulation: _selectedMotif,
        noteLivraison: _selectedNote,
        token: token,
      );

      if (response['success'] == true) {
        // Rafraîchir la liste des livraisons
        final deliveryController = Get.find<DeliveryController>();
        await deliveryController.refreshColis();

        await LocalNotificationService().showSuccessNotification(
          title: 'Livraison annulée',
          message:
              response['message']?.toString() ??
              'Livraison annulée avec succès',
          payload: 'delivery_cancelled_${widget.colisId}',
        );

        // Retourner à la page d'origine
        _navigateBackToOrigin();
      } else {
        await LocalNotificationService().showErrorNotification(
          title: 'Erreur',
          message:
              response['message']?.toString() ??
              'Erreur lors de l\'annulation de la livraison',
          payload: 'delivery_cancel_error_${widget.colisId}',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de l\'annulation de la livraison: $e');
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de l\'annulation de la livraison: $e',
        payload: 'delivery_cancel_exception_${widget.colisId}',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateBackToOrigin() {
    final fromPage = widget.fromPage;
    print('🔍 Retour à la page d\'origine: $fromPage');

    if (fromPage == 'dashboard') {
      // Retourner au dashboard avec l'onglet Livraisons actif
      Get.offAllNamed('/dashboard?tab=deliveries');
    } else if (fromPage == 'delivery_details') {
      // Retourner à la page de détails de livraison
      Get.back(result: true);
    } else if (fromPage == 'delivery_list') {
      // Retourner à la liste des livraisons
      Get.back(result: true);
    } else {
      // Par défaut, retourner à la page précédente
      Get.back(result: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildMotifSelectionCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildNoteCard(),
              const SizedBox(height: AppDimensions.spacingXL),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        'Annuler la livraison',
        style: GoogleFonts.montserrat(
          fontSize: AppDimensions.fontSizeL,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.error, AppColors.error.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: const Icon(Icons.cancel, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Colis ${widget.codeColis}',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  'Annulation de la livraison',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotifSelectionCard() {
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
              Icon(Icons.cancel_outlined, color: AppColors.error, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Motif d\'annulation',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Sélectionnez un motif prédéfini :',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          GestureDetector(
            onTap: _showMotifSelectionModal,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedMotif.isEmpty
                          ? 'Choisir un motif d\'annulation'
                          : _selectedMotif,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color:
                            _selectedMotif.isEmpty
                                ? Colors.grey.shade500
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.error),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard() {
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
              Icon(Icons.note_alt, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Note d\'annulation',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Text(
            'Sélectionnez une note prédéfinie :',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          GestureDetector(
            onTap: _showNoteSelectionModal,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedNote.isEmpty
                          ? 'Choisir une note d\'annulation'
                          : _selectedNote,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color:
                            _selectedNote.isEmpty
                                ? Colors.grey.shade500
                                : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancelButton() {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _cancelDelivery,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          elevation: 0,
        ),
        child:
            _isLoading
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cancel, size: 20),
                    const SizedBox(width: AppDimensions.spacingS),
                    Text(
                      'Annuler la livraison',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeM,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
