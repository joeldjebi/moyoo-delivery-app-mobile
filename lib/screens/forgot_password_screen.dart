import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_phone_field.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller = Get.put(
      ForgotPasswordController(),
    );
    final _formKey = GlobalKey<FormState>();
    final _phoneController = TextEditingController();

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
          'Mot de passe oublié',
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
                const SizedBox(height: AppDimensions.spacingS),

                // Icône
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Titre
                Text(
                  'Réinitialiser votre mot de passe',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Description
                Text(
                  'Entrez votre numéro de téléphone pour recevoir un code de vérification',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingXXL),

                // Champ Téléphone
                AppPhoneField(
                  label: 'Votre numéro de téléphone',
                  hintText: 'Entrez votre numéro',
                  controller: _phoneController,
                  onChanged: controller.setPhoneNumber,
                  validator: controller.validatePhoneNumber,
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Bouton Envoyer le code
                Obx(
                  () => AppButton(
                    text: 'Envoyer le code',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.sendOtpCode();
                      }
                    },
                    type: AppButtonType.primary,
                    isLoading: controller.isLoading,
                    icon: Icons.send,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Lien retour à la connexion
                Center(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Retour à la connexion',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
