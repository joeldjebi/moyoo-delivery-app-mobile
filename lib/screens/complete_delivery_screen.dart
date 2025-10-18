import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:signature/signature.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_button.dart';
import '../services/delivery_service.dart';
import '../services/local_notification_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/delivery_controller.dart';

class CompleteDeliveryScreen extends StatefulWidget {
  final int colisId;
  final String codeColis;
  final String codeValidation;
  final String? fromPage;

  const CompleteDeliveryScreen({
    super.key,
    required this.colisId,
    required this.codeColis,
    required this.codeValidation,
    this.fromPage,
  });

  @override
  State<CompleteDeliveryScreen> createState() => _CompleteDeliveryScreenState();
}

class _CompleteDeliveryScreenState extends State<CompleteDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _noteController = TextEditingController();

  String _selectedNote = '';
  File? _selectedPhoto;
  String? _signatureData;
  double? _latitude;
  double? _longitude;
  bool _isLoading = false;
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: AppColors.primary,
    exportBackgroundColor: Colors.white,
  );

  // Notes prédéfinies pour la livraison
  final List<String> _predefinedNotes = [
    'Livraison effectuée avec succès',
    'Colis livré au destinataire',
    'Livraison effectuée, client satisfait',
    'Colis remis en main propre',
    'Livraison effectuée, signature obtenue',
    'Colis livré selon les instructions',
    'Livraison effectuée sans problème',
    'Colis remis au destinataire autorisé',
    'Livraison effectuée, paiement reçu',
    'Colis livré avec succès',
  ];

  @override
  void initState() {
    super.initState();
    _codeController.text = widget.codeValidation;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _noteController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Vérifier les permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permissions de localisation refusées');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permissions de localisation définitivement refusées');
        await LocalNotificationService().showWarningNotification(
          title: 'Permissions requises',
          message:
              'Les permissions de localisation sont nécessaires pour finaliser la livraison. Veuillez les activer dans les paramètres.',
          payload: 'location_permission_denied_forever',
        );
        return;
      }

      // Obtenir la position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });
      print('📍 Position obtenue: $_latitude, $_longitude');
    } catch (e) {
      print('❌ Erreur lors de la récupération de la position: $e');
      // Ne pas afficher d'erreur à l'utilisateur, la géolocalisation est optionnelle
    }
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

  Future<void> _pickPhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        setState(() {
          _selectedPhoto = File(image.path);
        });
      }
    } catch (e) {
      print('❌ Erreur lors de la sélection de la photo: $e');
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de la sélection de la photo',
        payload: 'photo_selection_error',
      );
    }
  }

  Future<void> _captureSignature() async {
    try {
      if (_signatureController.isEmpty) {
        await LocalNotificationService().showErrorNotification(
          title: 'Erreur',
          message: 'Veuillez signer avant de continuer',
          payload: 'signature_empty',
        );
        return;
      }

      final Uint8List? signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes != null) {
        final String base64Signature = base64Encode(signatureBytes);
        setState(() {
          _signatureData = 'data:image/png;base64,$base64Signature';
        });

        await LocalNotificationService().showSuccessNotification(
          title: 'Signature capturée',
          message: 'Signature capturée avec succès',
          payload: 'signature_captured',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la capture de la signature: $e');
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de la capture de la signature',
        payload: 'signature_capture_error',
      );
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

  Future<void> _completeDelivery() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedNote.isEmpty) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Veuillez sélectionner une note de livraison',
        payload: 'note_not_selected',
      );
      return;
    }

    if (_signatureData == null) {
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Veuillez capturer la signature du destinataire',
        payload: 'signature_not_captured',
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

      final response = await DeliveryService.completeDelivery(
        colisId: widget.colisId,
        codeValidation: _codeController.text.trim(),
        noteLivraison: _selectedNote,
        token: token,
        photoProof: _selectedPhoto?.path,
        signatureData: _signatureData,
        latitude: _latitude,
        longitude: _longitude,
      );

      if (response['success'] == true) {
        // Rafraîchir la liste des livraisons
        final deliveryController = Get.find<DeliveryController>();
        await deliveryController.refreshColis();

        await LocalNotificationService().showSuccessNotification(
          title: 'Livraison terminée',
          message:
              response['message']?.toString() ??
              'Livraison terminée avec succès',
          payload: 'delivery_completed_${widget.colisId}',
        );

        // Retourner à la page d'origine
        _navigateBackToOrigin();
      } else {
        await LocalNotificationService().showErrorNotification(
          title: 'Erreur',
          message:
              response['message']?.toString() ??
              'Erreur lors de la finalisation de la livraison',
          payload: 'delivery_complete_error_${widget.colisId}',
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la finalisation de la livraison: $e');
      await LocalNotificationService().showErrorNotification(
        title: 'Erreur',
        message: 'Erreur lors de la finalisation de la livraison: $e',
        payload: 'delivery_complete_exception_${widget.colisId}',
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
              _buildCodeValidationCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildNoteSelectionCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildPhotoCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildSignatureCard(),
              const SizedBox(height: AppDimensions.spacingM),
              _buildLocationCard(),
              const SizedBox(height: AppDimensions.spacingXL),
              _buildCompleteButton(),
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
        'Finaliser la livraison',
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
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
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
            child: const Icon(
              Icons.local_shipping,
              color: Colors.white,
              size: 24,
            ),
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
                  'Finalisation de la livraison',
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

  Widget _buildCodeValidationCard() {
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
              Icon(Icons.qr_code, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Code de validation',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          TextFormField(
            controller: _codeController,
            decoration: InputDecoration(
              hintText: 'Entrez le code de validation',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le code de validation est requis';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSelectionCard() {
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
                'Note de livraison',
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
                          ? 'Choisir une note de livraison'
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

  Widget _buildPhotoCard() {
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
              Icon(Icons.camera_alt, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Photo de preuve',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          if (_selectedPhoto != null) ...[
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                child: Image.file(_selectedPhoto!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
          ],
          AppButton(
            text:
                _selectedPhoto != null
                    ? 'Changer la photo'
                    : 'Prendre une photo',
            onPressed: _pickPhoto,
            type: AppButtonType.outline,
            icon: Icons.camera_alt,
          ),
        ],
      ),
    );
  }

  Widget _buildSignatureCard() {
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
              Icon(Icons.edit, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Signature du destinataire',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Effacer',
                  onPressed: () {
                    _signatureController.clear();
                    setState(() {
                      _signatureData = null;
                    });
                  },
                  type: AppButtonType.outline,
                  icon: Icons.clear,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: AppButton(
                  text: 'Capturer',
                  onPressed: _captureSignature,
                  type: AppButtonType.primary,
                  icon: Icons.check,
                ),
              ),
            ],
          ),
          if (_signatureData != null) ...[
            const SizedBox(height: AppDimensions.spacingS),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      'Signature capturée avec succès',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.success,
                      ),
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

  Widget _buildLocationCard() {
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
              Icon(Icons.location_on, color: AppColors.primary, size: 20),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                'Position GPS',
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),
          if (_latitude != null && _longitude != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 16),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      'Position obtenue: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_off,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: AppDimensions.spacingS),
                      Expanded(
                        child: Text(
                          'Position GPS non disponible',
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeS,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      text: 'Réessayer',
                      onPressed: _getCurrentLocation,
                      type: AppButtonType.outline,
                      icon: Icons.refresh,
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

  Widget _buildCompleteButton() {
    return AppButton(
      text: 'Finaliser la livraison',
      onPressed: _isLoading ? null : _completeDelivery,
      type: AppButtonType.success,
      isLoading: _isLoading,
      icon: Icons.check_circle,
    );
  }
}
