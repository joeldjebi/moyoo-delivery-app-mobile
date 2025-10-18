import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../controllers/auth_controller.dart';
import 'edit_profile_screen.dart';
import 'reset_password_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Section profil utilisateur
          _buildProfileHeader(authController),

          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Section assistance, sécurité et paramètres
                _buildHistorySection(),

                // Espace flexible pour pousser le bouton de déconnexion vers le bas
                const Spacer(),
              ],
            ),
          ),

          // Section déconnexion en bas de page
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTeamSection(),
          ),
        ],
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
        'Profil',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProfileHeader(AuthController authController) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          // Photo de profil
          Obx(() {
            final photoUrl = authController.livreurPhoto;
            return Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child:
                  photoUrl != null && photoUrl.isNotEmpty
                      ? ClipOval(
                        child: Image.network(
                          photoUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.white,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const CircleAvatar(
                              backgroundColor: AppColors.primary,
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : const CircleAvatar(
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.person,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
            );
          }),

          const SizedBox(height: 12),

          // Nom utilisateur avec flèche
          InkWell(
            onTap: () => Get.to(EditProfileScreen()),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(
                  () => Text(
                    authController.livreurName.isNotEmpty
                        ? authController.livreurName
                        : '+225 ${authController.livreurMobile}',
                    style: GoogleFonts.montserrat(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Email ou mobile
          Obx(
            () => Text(
              authController.currentLivreur.value?.email ??
                  '+225 ${authController.livreurMobile}',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItemInCard(
            icon: Icons.headset_mic,
            title: 'Assistance',
            onTap: () => Get.toNamed('/assistance'),
            showDivider: true,
          ),

          _buildMenuItemInCard(
            icon: Icons.security,
            title: 'Sécurité',
            onTap:
                () => Get.to(
                  () => const ResetPasswordScreen(isForgotPassword: false),
                ),
            showDivider: true,
          ),

          // _buildMenuItemInCard(
          //   icon: Icons.settings,
          //   title: 'Paramètres',
          //   onTap: () => print('Paramètres'),
          //   showDivider: false,
          // ),
        ],
      ),
    );
  }

  Widget _buildTeamSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // _buildMenuItemInCard(
          //   icon: Icons.info,
          //   title: 'Informations',
          //   onTap: () => print('Informations'),
          //   showDivider: true,
          // ),
          _buildMenuItemInCard(
            icon: Icons.logout,
            title: 'Déconnexion',
            onTap: () => _handleLogout(),
            showDivider: false,
            iconColor: Colors.red,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  void _handleLogout() {
    final AuthController authController = Get.find<AuthController>();

    Get.dialog(
      AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.montserrat(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Fermer le dialog
              authController
                  .logout(); // Utiliser le contrôleur d'auth pour la déconnexion
            },
            child: Text(
              'Déconnexion',
              style: GoogleFonts.montserrat(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemInCard({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? rightWidget,
    required VoidCallback onTap,
    required bool showDivider,
    Color? iconColor,
    Color? textColor,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icône
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: (iconColor ?? const Color(0xFF7C3AED)).withOpacity(
                      0.1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? const Color(0xFF7C3AED),
                    size: 18,
                  ),
                ),

                const SizedBox(width: 12),

                // Titre et sous-titre
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? Colors.black,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Widget de droite (icône ou flèche)
                if (rightWidget != null) ...[
                  rightWidget,
                  const SizedBox(width: 8),
                ],

                // Flèche de navigation
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),

        // Divider
        if (showDivider)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            height: 1,
            color: Colors.grey.shade200,
          ),
      ],
    );
  }
}
