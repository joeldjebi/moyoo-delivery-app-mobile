import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_button.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _permisController = TextEditingController();
  final _mobileController = TextEditingController();

  late AuthController _authController;
  bool _isLoading = false;
  File? _selectedPhoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _prefillFields();

    // Écouter les changements du profil pour mettre à jour les champs
    _authController.currentLivreur.listen((livreur) {
      if (livreur != null) {
        _prefillFields();
      }
    });
  }

  void _prefillFields() {
    final livreur = _authController.currentLivreur.value;

    if (livreur != null) {
      _firstNameController.text = livreur.firstName ?? '';
      _lastNameController.text = livreur.lastName ?? '';
      _emailController.text = livreur.email ?? '';
      _addressController.text = livreur.adresse ?? '';
      _permisController.text = livreur.permis ?? '';
      _mobileController.text = livreur.mobile;
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _permisController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo de profil
              _buildProfilePhotoSection(),

              const SizedBox(height: AppDimensions.spacingL),

              // Informations personnelles
              _buildSectionTitle('Informations personnelles'),
              const SizedBox(height: AppDimensions.spacingS),

              // Prénom et Nom
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      controller: _firstNameController,
                      label: 'Prénom',
                      hintText: 'Entrez votre prénom',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le prénom est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: AppTextField(
                      controller: _lastNameController,
                      label: 'Nom',
                      hintText: 'Entrez votre nom',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Le nom est requis';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Email
              AppTextField(
                controller: _emailController,
                label: 'Email',
                hintText: 'Entrez votre email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!GetUtils.isEmail(value)) {
                      return 'Format d\'email invalide';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Numéro de téléphone
              AppTextField(
                controller: _mobileController,
                label: 'Numéro de téléphone',
                hintText: 'Entrez votre numéro',
                keyboardType: TextInputType.phone,
                enabled: false, // Non modifiable
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le numéro de téléphone est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Informations professionnelles
              _buildSectionTitle('Informations professionnelles'),
              const SizedBox(height: AppDimensions.spacingS),

              // Adresse
              AppTextField(
                controller: _addressController,
                label: 'Adresse',
                hintText: 'Entrez votre adresse',
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'L\'adresse est requise';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingM),

              // Numéro de permis
              AppTextField(
                controller: _permisController,
                label: 'Numéro de permis',
                hintText: 'Entrez votre numéro de permis',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le numéro de permis est requis';
                  }
                  return null;
                },
              ),

              const SizedBox(height: AppDimensions.spacingL),

              // Informations sur l'engin
              _buildEnginSection(),

              const SizedBox(height: AppDimensions.spacingL),

              // Zones d'activité
              _buildZonesSection(),

              const SizedBox(height: AppDimensions.spacingXL),

              // Bouton de sauvegarde
              AppButton(
                text: 'Sauvegarder les modifications',
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),

              const SizedBox(height: AppDimensions.spacingM),
            ],
          ),
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
        'Modifier le profil',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          // Photo de profil
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300, width: 2),
            ),
            child:
                _selectedPhoto != null
                    ? ClipOval(
                      child: Image.file(
                        _selectedPhoto!,
                        fit: BoxFit.cover,
                        width: 100,
                        height: 100,
                      ),
                    )
                    : Obx(() {
                      final photoUrl = _authController.livreurPhoto;
                      return photoUrl != null && photoUrl.isNotEmpty
                          ? ClipOval(
                            child: Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              width: 100,
                              height: 100,
                              errorBuilder: (context, error, stackTrace) {
                                return const CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: Icon(
                                    Icons.person,
                                    size: 50,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          )
                          : const CircleAvatar(
                            backgroundColor: AppColors.primary,
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                    }),
          ),

          const SizedBox(height: AppDimensions.spacingS),

          // Bouton modifier photo
          TextButton.icon(
            onPressed: _selectPhoto,
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text('Modifier la photo'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildEnginSection() {
    return Obx(() {
      final engin = _authController.currentLivreur.value?.engin;
      return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informations sur l\'engin',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Row(
              children: [
                Icon(Icons.motorcycle, color: AppColors.primary, size: 20),
                const SizedBox(width: AppDimensions.spacingS),
                Text(
                  engin?.type ?? 'Non défini',
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildZonesSection() {
    return Obx(() {
      final communes = _authController.livreurCommunesNames;
      return Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Zones d\'activité',
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            if (communes.isNotEmpty) ...[
              Wrap(
                spacing: AppDimensions.spacingXS,
                runSpacing: AppDimensions.spacingXS,
                children:
                    communes.map((commune) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingS,
                          vertical: AppDimensions.spacingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          commune,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ] else ...[
              Text(
                'Aucune zone définie',
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Future<void> _selectPhoto() async {
    try {
      // Afficher un dialog pour choisir la source
      final source = await Get.dialog<ImageSource>(
        AlertDialog(
          title: Text(
            'Sélectionner une photo',
            style: GoogleFonts.montserrat(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      );

      if (source != null) {
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 80,
        );

        if (image != null) {
          setState(() {
            _selectedPhoto = File(image.path);
          });

          Get.snackbar(
            'Succès',
            'Photo sélectionnée avec succès',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.snackbarSuccess,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la sélection de la photo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Appel à l'API de mise à jour du profil
      final updatedProfile = await AuthService.updateProfile(
        token: _authController.authToken,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        permis: _permisController.text.trim(),
        photo: _selectedPhoto,
      );

      if (updatedProfile != null) {
        // Mettre à jour le profil dans le contrôleur
        await _authController.updateLivreurInfo(updatedProfile);

        Get.snackbar(
          'Succès',
          'Profil mis à jour avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.snackbarSuccess,
          colorText: Colors.white,
        );

        Get.back();
      } else {
        Get.snackbar(
          'Erreur',
          'Erreur lors de la mise à jour du profil',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la mise à jour du profil: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
