import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_otp_field.dart';

class OtpVerificationScreen extends StatelessWidget {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgotPasswordController controller =
        Get.find<ForgotPasswordController>();
    final _formKey = GlobalKey<FormState>();
    final _otpFieldKey = GlobalKey<AppOtpFieldState>();

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
          'Vérification',
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
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.sms,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Titre
                Text(
                  'Code de vérification',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXL,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingXS),

                // Description
                Obx(
                  () => Text(
                    'Nous avons envoyé un code à ${controller.fullPhoneNumber}',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingXL),

                // Champs OTP individuels
                AppOtpField(
                  key: _otpFieldKey,
                  length: 4,
                  onChanged: controller.setOtpCode,
                  validator: controller.validateOtpCode,
                ),

                const SizedBox(height: AppDimensions.spacingM),

                // Message d'aide
                Text(
                  'Entrez le code à 4 chiffres reçu par SMS',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppDimensions.spacingXL),

                // Bouton Vérifier
                Obx(
                  () => AppButton(
                    text: 'Vérifier le code',
                    onPressed: () {
                      if (_otpFieldKey.currentState?.validate() ?? false) {
                        controller.verifyOtpCode();
                      } else {
                        Get.snackbar(
                          'Erreur',
                          'Veuillez entrer le code complet',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.snackbarError,
                          colorText: Colors.white,
                        );
                      }
                    },
                    type: AppButtonType.primary,
                    isLoading: controller.isLoading,
                    icon: Icons.check,
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingS),

                // Lien renvoyer le code
                Center(
                  child: TextButton(
                    onPressed: controller.resendOtpCode,
                    child: Text(
                      'Renvoyer le code',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.spacingXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
