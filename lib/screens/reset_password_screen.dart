import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatelessWidget {
  final bool isForgotPassword;

  const ResetPasswordScreen({super.key, this.isForgotPassword = true});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.find<ForgotPasswordController>();
    final _formKey = GlobalKey<FormState>();
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          isForgotPassword
              ? 'Nouveau mot de passe'
              : 'Modifier le mot de passe',
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeL,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingL,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.spacingL),

                // Icône
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Icon(
                      Icons.lock_open,
                      size: 30,
                      color: AppColors.success,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Titre
                Text(
                  isForgotPassword
                      ? 'Créer un nouveau mot de passe'
                      : 'Modifier votre mot de passe',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Description
                Obx(
                  () => Text(
                    isForgotPassword
                        ? 'Créez un nouveau mot de passe sécurisé pour ${controller.fullPhoneNumber}'
                        : 'Entrez votre mot de passe actuel et votre nouveau mot de passe',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Champ Mot de passe actuel (seulement pour la modification)
                if (!isForgotPassword) ...[
                  AppPasswordField(
                    label: 'Mot de passe actuel',
                    hintText: 'Entrez votre mot de passe actuel',
                    controller: _currentPasswordController,
                    onChanged: controller.setCurrentPassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer votre mot de passe actuel';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppDimensions.spacingS),
                ],

                // Champ Nouveau mot de passe
                AppPasswordField(
                  label: 'Nouveau mot de passe',
                  hintText: 'Entrez votre nouveau mot de passe',
                  controller: _newPasswordController,
                  onChanged: controller.setNewPassword,
                  validator: controller.validateNewPassword,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Champ Confirmer mot de passe
                AppPasswordField(
                  label: 'Confirmer le mot de passe',
                  hintText: 'Confirmez votre nouveau mot de passe',
                  controller: _confirmPasswordController,
                  onChanged: controller.setConfirmPassword,
                  validator: controller.validateConfirmPassword,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Indicateurs de sécurité
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingS),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre mot de passe doit contenir :',
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeXS,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingXS),
                      _buildRequirement('Au moins 6 caractères', true),
                      _buildRequirement(
                        'Une combinaison de lettres et chiffres',
                        true,
                      ),
                      _buildRequirement(
                        'Évitez les mots de passe courants',
                        true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),

                // Bouton Réinitialiser/Modifier
                Obx(
                  () => AppButton(
                    text:
                        isForgotPassword
                            ? 'Réinitialiser le mot de passe'
                            : 'Modifier le mot de passe',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (isForgotPassword) {
                          controller.resetPassword();
                        } else {
                          controller.changePassword();
                        }
                      }
                    },
                    type: AppButtonType.primary,
                    isLoading: controller.isLoading,
                    icon: Icons.security,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Lien retour
                Center(
                  child: TextButton(
                    onPressed: () {
                      if (isForgotPassword) {
                        Get.offAll(() => const LoginScreen());
                      } else {
                        Get.back();
                      }
                    },
                    child: Text(
                      isForgotPassword
                          ? 'Retour à la connexion'
                          : 'Retour au profil',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            size: 14,
            color: isValid ? AppColors.success : AppColors.error,
          ),
          const SizedBox(width: AppDimensions.spacingXS),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
