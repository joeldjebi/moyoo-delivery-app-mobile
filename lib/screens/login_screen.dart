import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../widgets/app_button.dart';
import '../widgets/app_text_field.dart';
import '../widgets/app_phone_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    final _formKey = GlobalKey<FormState>();
    final _phoneController = TextEditingController();
    final _passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            // Contenu principal avec scroll
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingL,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppDimensions.spacingM),

                      // Logo MOYOO (style de la maquette)
                      Center(
                        child: Text(
                          'MOYOO',
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeXXL,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingM),

                      // Titre dynamique selon l'étape (style maquette)
                      Obx(
                        () => Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              controller.currentStep == 1
                                  ? 'SAISISSEZ VOTRE NUMÉRO DE TÉLÉPHONE'
                                  : 'ENTREZ VOTRE MOT DE PASSE',
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeM,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.start,
                            ),
                            const SizedBox(height: AppDimensions.spacingS),
                            Text(
                              controller.currentStep == 1
                                  ? 'Nous enverrons un code de confirmation à celui-ci'
                                  : 'Entrez votre mot de passe pour continuer',
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeS,
                                fontWeight: FontWeight.normal,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppDimensions.spacingM),

                      // Contenu dynamique selon l'étape
                      Obx(
                        () =>
                            controller.currentStep == 1
                                ? _buildPhoneStep(
                                  controller,
                                  _phoneController,
                                  _formKey,
                                )
                                : _buildPasswordStep(
                                  controller,
                                  _passwordController,
                                  _formKey,
                                ),
                      ),

                      const SizedBox(height: AppDimensions.spacingL),
                    ],
                  ),
                ),
              ),
            ),

            // Texte légal en bas de page (fixe)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingM,
              ),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'En continuant, je reconnais accepter les conditions de ',
                    ),
                    TextSpan(
                      text: 'Conditions d\'utilisation',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' et '),
                    TextSpan(
                      text: 'Contrat de licence Yango',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(
                      text:
                          ', et j\'accepte que mes données soient traitées conformément aux conditions de ',
                    ),
                    TextSpan(
                      text: 'Politique de confidentialité',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        color: AppColors.textSecondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneStep(
    LoginController controller,
    TextEditingController phoneController,
    GlobalKey<FormState> formKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Champ Téléphone (style personnalisé)
        AppPhoneField(
          hintText: '00 00 0 00000',
          controller: phoneController,
          onChanged: controller.setPhoneNumber,
          validator: controller.validatePhoneNumber,
          onFocusChanged: controller.setPhoneFieldFocus,
        ),

        // Bouton Continuer (affiché si le champ a le focus OU contient du texte)
        Obx(
          () =>
              (controller.isPhoneFieldFocused ||
                      controller.phoneNumber.isNotEmpty)
                  ? Column(
                    children: [
                      const SizedBox(height: AppDimensions.spacingXL),
                      AppButton(
                        text: 'Continuer',
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            controller.validatePhoneAndContinue();
                          }
                        },
                        type: AppButtonType.primary,
                        isLoading: controller.isLoading,
                      ),
                    ],
                  )
                  : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPasswordStep(
    LoginController controller,
    TextEditingController passwordController,
    GlobalKey<FormState> formKey,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Affichage du numéro de téléphone (style personnalisé)
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingS),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.phone,
                color: AppColors.primary,
                size: AppDimensions.iconSizeM,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Text(
                controller.fullPhoneNumber,
                style: GoogleFonts.montserrat(
                  fontSize: AppDimensions.fontSizeM,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: controller.previousStep,
                child: Text(
                  'Modifier',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppDimensions.spacingS),

        // Champ Mot de passe (style personnalisé)
        AppPasswordField(
          label: 'Mot de passe',
          hintText: 'Entrez votre mot de passe',
          controller: passwordController,
          onChanged: controller.setPassword,
          validator: controller.validatePassword,
        ),

        // Message d'erreur en dessous du champ mot de passe
        Obx(() {
          if (controller.errorMessage.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.only(top: AppDimensions.spacingS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              decoration: BoxDecoration(
                color: AppColors.snackbarError.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(
                  color: AppColors.snackbarError.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppColors.snackbarError,
                    size: AppDimensions.iconSizeS,
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                  Expanded(
                    child: Text(
                      controller.errorMessage,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.snackbarError,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Lien Mot de passe oublié
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Flexible(
              child: TextButton(
                onPressed: controller.forgotPassword,
                child: Text(
                  'Mot de passe oublié ?',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    color: AppColors.textPrimary,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Bouton Se connecter (style personnalisé)
        Obx(
          () => AppButton(
            text: 'Se connecter',
            onPressed: () {
              if (formKey.currentState!.validate()) {
                controller.login();
              }
            },
            type: AppButtonType.primary,
            isLoading: controller.isLoading,
          ),
        ),
      ],
    );
  }
}
