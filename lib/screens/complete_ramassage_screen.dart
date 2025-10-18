import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../controllers/ramassage_controller.dart';
import '../models/ramassage_models.dart';
import '../services/complete_ramassage_service.dart';
import '../services/local_notification_service.dart';
import '../services/cancel_ramassage_service.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_button.dart';

class CompleteRamassageScreen extends StatefulWidget {
  final Ramassage? ramassage;
  final String? fromPage; // Page d'origine pour le retour

  const CompleteRamassageScreen({super.key, this.ramassage, this.fromPage});

  @override
  State<CompleteRamassageScreen> createState() =>
      _CompleteRamassageScreenState();
}

class _CompleteRamassageScreenState extends State<CompleteRamassageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreColisController = TextEditingController();

  final List<String> _selectedPhotos = [];
  bool _isLoading = false;
  late AuthController _authController;

  // Variables pour les selects
  String? _selectedNote;
  String? _selectedRaison;

  // Options pour les selects
  final List<String> _notesOptions = [
    'Ramassage effectué sans problème',
    'Client absent, colis laissés chez un voisin',
    'Client absent, rendez-vous reporté',
    'Problème d\'accès à l\'adresse',
    'Colis endommagés lors du ramassage',
    'Client a refusé certains colis',
    'Autre',
  ];

  final List<String> _raisonsOptions = [
    'Client n\'avait pas tous les colis prêts',
    'Colis manquants chez le client',
    'Colis supplémentaires trouvés',
    'Erreur dans l\'estimation initiale',
    'Problème de conditionnement',
    'Autre',
  ];

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    if (widget.ramassage != null) {
      _nombreColisController.text =
          widget.ramassage!.nombreColisEstime.toString();
    }

    // Ajouter un listener pour déclencher la mise à jour de l'interface
    _nombreColisController.addListener(() {
      setState(() {});
    });
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

  @override
  void dispose() {
    _nombreColisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.ramassage == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Erreur')),
        body: const Center(child: Text('Aucun ramassage sélectionné')),
      );
    }

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
            colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.all(6),
        ),
      ),
      title: Text(
        'Finaliser le ramassage',
        style: GoogleFonts.montserrat(
          fontSize: AppDimensions.fontSizeS,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations du ramassage
            _buildRamassageInfo(),
            const SizedBox(height: AppDimensions.spacingM),

            // Formulaire
            _buildForm(),
            const SizedBox(height: AppDimensions.spacingM),

            // Bouton de finalisation
            _buildCompleteButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRamassageInfo() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.shopping_bag,
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
                      widget.ramassage!.boutique.libelle,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.ramassage!.codeRamassage,
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
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Colis estimés: ${widget.ramassage!.nombreColisEstime}',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nombre de colis réel
        _buildFormField(
          controller: _nombreColisController,
          label: 'Nombre de colis réel *',
          hint: 'Entrez le nombre réel de colis ramassés',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer le nombre de colis';
            }
            final number = int.tryParse(value);
            if (number == null || number < 0) {
              return 'Veuillez entrer un nombre valide';
            }
            return null;
          },
        ),
        const SizedBox(height: AppDimensions.spacingS),

        // Photos des colis
        _buildPhotosSection(),
        const SizedBox(height: AppDimensions.spacingS),

        // Notes du ramassage (select)
        _buildNotesSelect(),
        const SizedBox(height: AppDimensions.spacingS),

        // Raison de la différence (conditionnel et select)
        if (_shouldShowReasonField()) ...[
          _buildRaisonSelect(),
          const SizedBox(height: AppDimensions.spacingS),
        ],
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: GoogleFonts.montserrat(fontSize: AppDimensions.fontSizeXS),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(
              color: AppColors.textSecondary,
              fontSize: AppDimensions.fontSizeXS,
            ),
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
        ),
      ],
    );
  }

  /// Vérifier si le champ raison doit être affiché
  bool _shouldShowReasonField() {
    final nombreReel = int.tryParse(_nombreColisController.text);
    final nombreEstime = widget.ramassage?.nombreColisEstime ?? 0;
    return nombreReel != null && nombreReel != nombreEstime;
  }

  /// Widget pour le select des notes
  Widget _buildNotesSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes du ramassage *',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        GestureDetector(
          onTap: () => _showNotesPicker(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedNote ?? 'Sélectionnez une note',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color:
                          _selectedNote != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_selectedNote == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Veuillez sélectionner une note',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  /// Widget pour le select des raisons
  Widget _buildRaisonSelect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Raison de la différence *',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        GestureDetector(
          onTap: () => _showRaisonPicker(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedRaison ?? 'Sélectionnez une raison',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color:
                          _selectedRaison != null
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (_shouldShowReasonField() && _selectedRaison == null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Veuillez sélectionner une raison',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos des colis *',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXS,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),
        Text(
          'Ajoutez au moins une photo des colis ramassés',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXS,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingXS),

        // Bouton d'ajout de photo
        GestureDetector(
          onTap: _addPhoto,
          child: Container(
            width: double.infinity,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo, size: 24, color: Colors.grey.shade600),
                const SizedBox(height: AppDimensions.spacingXS),
                Text(
                  'Ajouter une photo',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Liste des photos sélectionnées
        if (_selectedPhotos.isNotEmpty) ...[
          const SizedBox(height: AppDimensions.spacingS),
          Text(
            'Photos sélectionnées (${_selectedPhotos.length})',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXS),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedPhotos.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: AppDimensions.spacingXS),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(_selectedPhotos[index]),
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  /// Vérifier si toutes les conditions sont remplies pour finaliser
  bool _canCompleteRamassage() {
    // 1. Notes du ramassage sélectionnées
    if (_selectedNote == null || _selectedNote!.isEmpty) {
      return false;
    }

    // 2. Nombre de colis réel saisi
    final nombreColisText = _nombreColisController.text.trim();
    if (nombreColisText.isEmpty) {
      return false;
    }

    final nombreColisReel = int.tryParse(nombreColisText);
    if (nombreColisReel == null || nombreColisReel <= 0) {
      return false;
    }

    // 3. Photos prises en fonction du nombre de colis
    final nombreColisEstime = widget.ramassage!.nombreColisEstime;
    if (_selectedPhotos.length < nombreColisEstime) {
      return false;
    }

    return true;
  }

  Widget _buildCompleteButton() {
    final canComplete = _canCompleteRamassage();

    return Column(
      children: [
        // Message d'aide si le bouton est désactivé
        if (!canComplete) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(
                color: AppColors.warning.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    Text(
                      'Conditions requises :',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXS),
                ..._buildRequiredConditionsList(),
              ],
            ),
          ),
        ],

        // Boutons de finalisation et d'annulation
        Column(
          children: [
            // Bouton de finalisation
            AppButton(
              text:
                  canComplete
                      ? 'Finaliser le ramassage'
                      : 'Finaliser le ramassage',
              onPressed:
                  (_isLoading || !canComplete) ? null : _completeRamassage,
              type:
                  canComplete ? AppButtonType.success : AppButtonType.secondary,
              icon: Icons.check_circle,
              isFullWidth: true,
              isLoading: _isLoading,
            ),

            const SizedBox(height: AppDimensions.spacingS),

            // Bouton d'annulation
            AppButton(
              text: 'Annuler le ramassage',
              onPressed: _isLoading ? null : _cancelRamassage,
              type: AppButtonType.outline,
              icon: Icons.cancel,
              isFullWidth: true,
            ),
          ],
        ),
      ],
    );
  }

  /// Construire la liste des conditions requises
  List<Widget> _buildRequiredConditionsList() {
    final conditions = <Widget>[];

    // 1. Notes du ramassage
    if (_selectedNote == null || _selectedNote!.isEmpty) {
      conditions.add(
        _buildConditionItem('Sélectionner une note du ramassage', false),
      );
    } else {
      conditions.add(
        _buildConditionItem('Note du ramassage sélectionnée', true),
      );
    }

    // 2. Nombre de colis réel
    final nombreColisText = _nombreColisController.text.trim();
    final nombreColisReel = int.tryParse(nombreColisText);
    if (nombreColisText.isEmpty ||
        nombreColisReel == null ||
        nombreColisReel <= 0) {
      conditions.add(
        _buildConditionItem('Saisir le nombre de colis réel', false),
      );
    } else {
      conditions.add(_buildConditionItem('Nombre de colis réel saisi', true));
    }

    // 3. Photos
    final nombreColisEstime = widget.ramassage!.nombreColisEstime;
    final photosManquantes = nombreColisEstime - _selectedPhotos.length;
    if (_selectedPhotos.length < nombreColisEstime) {
      conditions.add(
        _buildConditionItem(
          'Prendre $photosManquantes photo${photosManquantes > 1 ? 's' : ''} supplémentaire${photosManquantes > 1 ? 's' : ''} (${_selectedPhotos.length}/$nombreColisEstime)',
          false,
        ),
      );
    } else {
      conditions.add(
        _buildConditionItem(
          'Photos prises ($nombreColisEstime/$nombreColisEstime)',
          true,
        ),
      );
    }

    return conditions;
  }

  /// Construire un élément de condition
  Widget _buildConditionItem(String text, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 12,
            color: isCompleted ? AppColors.success : AppColors.warning,
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                color: isCompleted ? AppColors.success : AppColors.warning,
                fontWeight: isCompleted ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedPhotos.add(image.path);
        });
      }
    } catch (e) {
      // Envoyer une notification locale d'erreur
      await _showLocalNotification(
        title: '❌ Erreur',
        body: 'Impossible d\'ajouter la photo: $e',
        type: 'error',
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  Future<void> _cancelRamassage() async {
    // Afficher un dialog de confirmation avec saisie de raison
    final result = await Get.dialog<Map<String, String>?>(
      _CancelRamassageDialog(ramassage: widget.ramassage!),
    );

    if (result != null) {
      final raison = result['raison'] ?? '';
      final commentaire = result['commentaire'] ?? '';

      setState(() {
        _isLoading = true;
      });

      try {
        print('🔄 ===== ANNULATION RAMASSAGE - API CALL =====');
        print(
          '🔄 Ramassage ID: ${widget.ramassage!.id}, Code: ${widget.ramassage!.codeRamassage}',
        );
        print('🔄 Raison: $raison');
        print('🔄 Commentaire: $commentaire');

        // Appel à l'API d'annulation
        final response = await CancelRamassageService.cancelRamassage(
          ramassageId: widget.ramassage!.id,
          raison: raison,
          commentaire: commentaire,
          token: _authController.authToken,
        );

        if (response.success) {
          print('✅ Ramassage annulé avec succès via API');

          // Actualiser les données de manière transparente
          try {
            final ramassageController = Get.find<RamassageController>();
            await ramassageController.refreshRamassages();
          } catch (e) {
            print('⚠️ Erreur lors de l\'actualisation des données: $e');
          }

          // Envoyer une notification locale de succès
          await _showLocalNotification(
            title: '✅ Ramassage annulé',
            body:
                'Le ramassage ${widget.ramassage!.codeRamassage} a été annulé avec succès',
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
              case 'ramassage_details':
                Get.back(result: true);
                print('🔍 Retour aux détails du ramassage');
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
      } catch (e) {
        print('❌ Erreur lors de l\'annulation du ramassage: $e');
        // Envoyer une notification locale d'erreur
        await _showLocalNotification(
          title: '❌ Erreur',
          body: 'Erreur lors de l\'annulation: $e',
          type: 'error',
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('❌ Annulation de ramassage échouée ou annulée');
    }
  }

  Future<void> _completeRamassage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPhotos.isEmpty) {
      // Envoyer une notification locale d'erreur
      await _showLocalNotification(
        title: '❌ Erreur',
        body: 'Veuillez ajouter au moins une photo des colis',
        type: 'error',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = _authController.authToken;
      if (token.isEmpty) {
        throw Exception('Token d\'authentification manquant');
      }

      final response = await CompleteRamassageService.completeRamassage(
        ramassageId: widget.ramassage!.id,
        nombreColisReel: int.parse(_nombreColisController.text),
        notesRamassage: _selectedNote,
        raisonDifference: _shouldShowReasonField() ? _selectedRaison : null,
        photosPaths: _selectedPhotos,
        token: token,
      );

      print('🔍 Response success: ${response.success}');
      print('🔍 Response message: ${response.message}');

      if (response.success) {
        // Actualiser les données de manière transparente avant de retourner
        try {
          final ramassageController = Get.find<RamassageController>();
          await ramassageController.refreshRamassages();
        } catch (e) {
          print('⚠️ Erreur lors de l\'actualisation des données: $e');
        }

        // Envoyer une notification locale de succès
        await _showLocalNotification(
          title: '🎉 Ramassage finalisé avec succès !',
          body:
              'Le ramassage ${widget.ramassage!.codeRamassage} a été complété',
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
            case 'ramassage_details':
              Get.back(result: true);
              print('🔍 Retour aux détails du ramassage');
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
        // Envoyer une notification locale d'erreur
        await _showLocalNotification(
          title: '❌ Erreur',
          body: response.message,
          type: 'error',
        );
      }
    } catch (e) {
      // Envoyer une notification locale d'erreur
      await _showLocalNotification(
        title: '❌ Erreur',
        body: 'Erreur lors de la finalisation: $e',
        type: 'error',
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Afficher le picker natif pour les notes
  void _showNotesPicker() {
    if (Platform.isIOS) {
      _showCupertinoPicker(
        title: 'Sélectionner une note',
        items: _notesOptions,
        selectedIndex:
            _selectedNote != null ? _notesOptions.indexOf(_selectedNote!) : 0,
        onSelected: (index) {
          setState(() {
            _selectedNote = _notesOptions[index];
          });
        },
      );
    } else {
      _showAndroidPicker(
        title: 'Sélectionner une note',
        items: _notesOptions,
        selectedIndex:
            _selectedNote != null ? _notesOptions.indexOf(_selectedNote!) : 0,
        onSelected: (index) {
          setState(() {
            _selectedNote = _notesOptions[index];
          });
        },
      );
    }
  }

  /// Afficher le picker natif pour les raisons
  void _showRaisonPicker() {
    if (Platform.isIOS) {
      _showCupertinoPicker(
        title: 'Sélectionner une raison',
        items: _raisonsOptions,
        selectedIndex:
            _selectedRaison != null
                ? _raisonsOptions.indexOf(_selectedRaison!)
                : 0,
        onSelected: (index) {
          setState(() {
            _selectedRaison = _raisonsOptions[index];
          });
        },
      );
    } else {
      _showAndroidPicker(
        title: 'Sélectionner une raison',
        items: _raisonsOptions,
        selectedIndex:
            _selectedRaison != null
                ? _raisonsOptions.indexOf(_selectedRaison!)
                : 0,
        onSelected: (index) {
          setState(() {
            _selectedRaison = _raisonsOptions[index];
          });
        },
      );
    }
  }

  /// Afficher un CupertinoPicker pour iOS
  void _showCupertinoPicker({
    required String title,
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    int currentIndex = selectedIndex;

    showCupertinoModalPopup<void>(
      context: context,
      builder:
          (BuildContext context) => Container(
            height: 250,
            padding: const EdgeInsets.only(top: 4.0),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            color: CupertinoColors.systemBackground.resolveFrom(context),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // Header avec titre et bouton de fermeture
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: CupertinoColors.separator.resolveFrom(context),
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Annuler',
                            style: TextStyle(
                              color: CupertinoColors.systemBlue.resolveFrom(
                                context,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            onSelected(currentIndex);
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Confirmer',
                            style: TextStyle(
                              color: CupertinoColors.systemBlue.resolveFrom(
                                context,
                              ),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Picker
                  Expanded(
                    child: CupertinoPicker(
                      magnification: 1.1,
                      squeeze: 1.1,
                      useMagnifier: true,
                      itemExtent: 28.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: selectedIndex,
                      ),
                      onSelectedItemChanged: (int selectedItem) {
                        currentIndex = selectedItem;
                      },
                      children: List<Widget>.generate(items.length, (
                        int index,
                      ) {
                        return Center(
                          child: Text(
                            items[index],
                            style: const TextStyle(fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  /// Afficher un picker Android avec showModalBottomSheet
  void _showAndroidPicker({
    required String title,
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelected,
  }) {
    int currentIndex = selectedIndex;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (BuildContext context) => StatefulBuilder(
            builder:
                (context, setModalState) => Container(
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      // Header avec titre et bouton de fermeture
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 0.5,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text(
                                'Annuler',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                onSelected(currentIndex);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Confirmer',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Liste des options
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final isSelected = index == currentIndex;
                            return ListTile(
                              title: Text(
                                items[index],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                              trailing:
                                  isSelected
                                      ? Icon(
                                        Icons.check,
                                        color: AppColors.primary,
                                        size: 18,
                                      )
                                      : null,
                              onTap: () {
                                setModalState(() {
                                  currentIndex = index;
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }
}

/// Dialog pour l'annulation de ramassage
class _CancelRamassageDialog extends StatefulWidget {
  final Ramassage ramassage;

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
