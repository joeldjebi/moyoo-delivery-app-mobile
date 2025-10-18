import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AssistanceScreen extends StatefulWidget {
  const AssistanceScreen({super.key});

  @override
  State<AssistanceScreen> createState() => _AssistanceScreenState();
}

class _AssistanceScreenState extends State<AssistanceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Assistance',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildSearchBar(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildQuickActions(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildFaqSection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildContactSection(),
              const SizedBox(height: AppDimensions.spacingL),
              _buildGuidesSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.headset_mic, color: Colors.white, size: 24),
          ),
          const SizedBox(width: AppDimensions.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Centre d\'assistance',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Trouvez rapidement l\'aide dont vous avez besoin',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
        decoration: const InputDecoration(
          hintText: 'Rechercher dans l\'aide...',
          prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.phone,
                title: 'Appeler le support',
                subtitle: 'Urgent',
                color: AppColors.error,
                onTap: _callSupport,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.chat,
                title: 'Chat en direct',
                subtitle: 'Disponible',
                color: AppColors.success,
                onTap: _openChat,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppDimensions.spacingS),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqSection() {
    final faqs = _getFilteredFaqs();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Questions fréquentes',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        ...faqs.map((faq) => _buildFaqItem(faq)).toList(),
      ],
    );
  }

  Widget _buildFaqItem(Map<String, dynamic> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          faq['question'],
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingM,
              0,
              AppDimensions.spacingM,
              AppDimensions.spacingM,
            ),
            child: Text(
              faq['answer'],
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nous contacter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        _buildContactItem(
          icon: Icons.phone,
          title: 'Support téléphonique',
          subtitle: 'Lun-Ven 8h-18h',
          value: '+225 20 30 40 50',
          onTap: () => _makePhoneCall('+22520304050'),
        ),
        _buildContactItem(
          icon: Icons.email,
          title: 'Email support',
          subtitle: 'Réponse sous 24h',
          value: 'support@moyoo.ci',
          onTap: () => _sendEmail('support@moyoo.ci'),
        ),
        _buildContactItem(
          icon: Icons.location_on,
          title: 'Bureau principal',
          subtitle: 'Abidjan, Côte d\'Ivoire',
          value: 'Cocody, Deux Plateaux',
          onTap: _openLocation,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuidesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guides d\'utilisation',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingM),
        _buildGuideItem(
          icon: Icons.play_circle_outline,
          title: 'Tutoriel vidéo',
          subtitle: 'Comment utiliser l\'application',
          onTap: _openVideoTutorial,
        ),
        _buildGuideItem(
          icon: Icons.book_outlined,
          title: 'Guide du livreur',
          subtitle: 'Manuel complet',
          onTap: _openManual,
        ),
        _buildGuideItem(
          icon: Icons.security,
          title: 'Sécurité',
          subtitle: 'Bonnes pratiques',
          onTap: _openSecurityGuide,
        ),
      ],
    );
  }

  Widget _buildGuideItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
        padding: const EdgeInsets.all(AppDimensions.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppColors.info, size: 20),
            ),
            const SizedBox(width: AppDimensions.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getFilteredFaqs() {
    final allFaqs = _getAllFaqs();

    if (_searchQuery.isEmpty) {
      return allFaqs;
    }

    return allFaqs.where((faq) {
      return faq['question'].toLowerCase().contains(_searchQuery) ||
          faq['answer'].toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<Map<String, dynamic>> _getAllFaqs() {
    return [
      {
        'question': 'Comment démarrer une livraison ?',
        'answer':
            'Pour démarrer une livraison, allez dans l\'onglet "Livraisons" du tableau de bord, sélectionnez un colis en attente et cliquez sur "Démarrer". Assurez-vous d\'être à l\'adresse de livraison avant de démarrer.',
      },
      {
        'question': 'Comment marquer une livraison comme terminée ?',
        'answer':
            'Une fois arrivé chez le client, cliquez sur "Terminer" dans les détails de la livraison. Vous devrez saisir le code de validation, prendre une photo de preuve et obtenir une signature du client.',
      },
      {
        'question': 'Que faire si le client n\'est pas disponible ?',
        'answer':
            'Si le client n\'est pas disponible, vous pouvez annuler la livraison en cliquant sur "Annuler" et en sélectionnant le motif d\'annulation approprié. Le colis sera reprogrammé automatiquement.',
      },
      {
        'question': 'Comment gérer les ramassages ?',
        'answer':
            'Les ramassages fonctionnent de la même manière que les livraisons. Allez dans l\'onglet "Ramassages", sélectionnez un ramassage planifié et suivez les étapes pour le compléter.',
      },
      {
        'question': 'Problème de connexion internet ?',
        'answer':
            'Vérifiez votre connexion mobile ou WiFi. L\'application fonctionne hors ligne pour certaines fonctions, mais une connexion est nécessaire pour synchroniser les données.',
      },
      {
        'question': 'Comment changer mon mot de passe ?',
        'answer':
            'Allez dans votre profil, cliquez sur "Sécurité" puis "Changer le mot de passe". Vous devrez saisir votre mot de passe actuel et le nouveau mot de passe.',
      },
      {
        'question': 'Que faire en cas de problème technique ?',
        'answer':
            'Contactez le support technique via l\'onglet "Assistance" ou appelez directement le numéro de support. Nous vous aiderons à résoudre le problème rapidement.',
      },
      {
        'question': 'Comment voir mes statistiques ?',
        'answer':
            'Vos statistiques sont visibles sur le tableau de bord principal. Vous pouvez voir le nombre de livraisons/ramassages effectués, en cours et terminés.',
      },
    ];
  }

  // Actions
  void _callSupport() {
    _makePhoneCall('+22520304050');
  }

  void _openChat() {
    Get.snackbar(
      'Chat en direct',
      'Fonctionnalité bientôt disponible',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application téléphone',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Support - Application Livreur',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir l\'application email',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _openLocation() {
    Get.snackbar(
      'Localisation',
      'Ouverture de la carte...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
    // Ici vous pourriez ouvrir Google Maps avec l'adresse
  }

  void _openVideoTutorial() {
    Get.snackbar(
      'Tutoriel vidéo',
      'Ouverture du tutoriel...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _openManual() {
    Get.snackbar(
      'Guide du livreur',
      'Ouverture du manuel...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _openSecurityGuide() {
    Get.snackbar(
      'Guide de sécurité',
      'Ouverture du guide...',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }
}
