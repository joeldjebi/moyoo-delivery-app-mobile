import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../controllers/auth_controller.dart';
import '../controllers/ramassage_controller.dart';
import '../controllers/delivery_controller.dart';
import '../models/ramassage_models.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';
import '../services/cancel_ramassage_service.dart';
import 'profile_screen.dart';
import 'ramassage_details_screen.dart';
import 'ramassage_list_screen.dart';
import 'complete_ramassage_screen.dart';
import '../widgets/formatted_amount_widget.dart';
import '../widgets/delivery_widgets.dart';
import 'delivery_details_screen.dart';
import 'delivery_list_screen.dart';
import 'complete_delivery_screen.dart';
import 'cancel_delivery_screen.dart';
import 'notifications_screen.dart';
import '../services/notification_manager_service.dart';
import '../widgets/notification_badge_widget.dart';
import '../widgets/location_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedTab = 0; // 0: Livraisons, 1: Ramassages
  int _selectedBottomNavIndex = 0; // Index pour le bottom navigation
  bool _dataLoaded = false; // Flag pour éviter les chargements multiples

  @override
  void initState() {
    super.initState();

    // Écouter les retours au dashboard
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInitialTab();
      _checkIfFromLogin();
      _loadData();
      _checkNotificationRefreshFlags();
      _ensureFcmTokenRegistered(); // Vérifier et enregistrer le token FCM
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Rafraîchir les données quand l'utilisateur revient sur cette page
    if (_dataLoaded) {
      _refreshData();
      // Vérifier l'enregistrement FCM au retour sur le dashboard
      _ensureFcmTokenRegistered();
    }
  }

  /// Vérifier et enregistrer le token FCM automatiquement
  void _checkIfFromLogin() {
    final currentRoute = Get.currentRoute;

    // Vérifier si on vient de la page de login
    if (currentRoute == '/dashboard' || currentRoute.contains('dashboard')) {
      // Vérifier l'historique de navigation pour détecter si on vient de login
      final previousRoute = Get.previousRoute;

      if (previousRoute == '/' ||
          previousRoute == '/login' ||
          previousRoute.isEmpty) {
        _registerFcmToken();
      }
    }
  }

  /// Enregistrer le token FCM automatiquement
  void _registerFcmToken() async {
    try {
      bool success = await NotificationService.registerFcmTokenOnServer();

      if (success) {
      } else {}
    } catch (e) {}
  }

  /// Vérifier et enregistrer le token FCM si nécessaire
  void _ensureFcmTokenRegistered() async {
    try {
      // Vérifier si le token FCM est déjà enregistré
      final isRegistered = await NotificationService.isFcmTokenRegistered();
      if (isRegistered) {
        return;
      }

      // Vérifier si le token FCM est disponible
      final fcmToken = NotificationService.fcmToken;
      if (fcmToken == null || fcmToken.isEmpty) {
        await NotificationService.forceReinitializeAndSetup();
        return;
      }

      // Vérifier si l'utilisateur est connecté
      final authController = Get.find<AuthController>();
      if (!authController.isLoggedIn || authController.authToken.isEmpty) {
        return;
      }

      // Enregistrer le token FCM
      _registerFcmToken();
    } catch (e) {}
  }

  /// Charger les données du dashboard
  void _loadData() {
    // Charger les ramassages seulement si la liste est vide
    final ramassageController = Get.find<RamassageController>();
    if (ramassageController.ramassages.isEmpty &&
        !ramassageController.isLoading) {
      ramassageController.loadRamassages();
    } else {}

    // Charger les colis de livraison seulement si la liste est vide
    final deliveryController = Get.find<DeliveryController>();
    if (deliveryController.colis.isEmpty && !deliveryController.isLoading) {
      deliveryController.loadColis();
    } else {}

    _dataLoaded = true;
  }

  /// Rafraîchir les données du dashboard
  void _refreshData() {
    // Rafraîchir les ramassages
    final ramassageController = Get.find<RamassageController>();
    if (!ramassageController.isLoading) {
      ramassageController.refreshRamassages();
    }

    // Rafraîchir les colis de livraison
    final deliveryController = Get.find<DeliveryController>();
    if (!deliveryController.isLoading) {
      deliveryController.refreshColis();
    }
  }

  /// Vérifier les flags d'actualisation des notifications
  void _checkNotificationRefreshFlags() {
    try {
      NotificationService.checkAndProcessRefreshFlags();
      NotificationService.forceRefreshLists();
      NotificationManagerService().initialize();
    } catch (e) {
      // Erreur silencieuse
    }
  }

  /// Envoyer une notification locale pour les actions de livraison
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
            payload: 'delivery_action_success',
          );
          break;
        case 'error':
          await localNotificationService.showErrorNotification(
            title: title,
            message: body,
            payload: 'delivery_action_error',
          );
          break;
        default: // 'info'
          await localNotificationService.showInfoNotification(
            title: title,
            message: body,
            payload: 'delivery_action_info',
          );
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildSimpleAppBar(authController),
      body: SafeArea(
        child: GetBuilder<RamassageController>(
          builder:
              (ramassageController) => Column(
                children: [
                  const SizedBox(height: AppDimensions.spacingS),
                  // Statistiques
                  _buildStatsSection(ramassageController),

                  // Contrôle segmenté List/Map
                  _buildSegmentedControl(ramassageController),

                  // Liste des commandes
                  Expanded(
                    child:
                        _selectedTab == 0
                            ? _buildDeliveriesList()
                            : _buildPickupsList(),
                  ),
                ],
              ),
        ),
      ),
      bottomNavigationBar: _buildNativeBottomNavigationBar(),
    );
  }

  /// Formater un montant avec des séparateurs de milliers
  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match match) => '${match[1]} ',
    );
  }

  PreferredSizeWidget _buildSimpleAppBar(AuthController authController) {
    return AppBar(
      backgroundColor: AppColors.surface, // Gris très clair
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          // Avatar utilisateur
          Obx(() {
            final authController = Get.find<AuthController>();
            final photoUrl = authController.livreurPhoto;
            return Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child:
                  photoUrl != null && photoUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          photoUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 22,
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            );
                          },
                        ),
                      )
                      : const Icon(Icons.person, color: Colors.white, size: 22),
            );
          }),

          const SizedBox(width: AppDimensions.spacingM),

          // Informations utilisateur
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Salut, Livreur !',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary, // Gris foncé
                  ),
                ),
                Obx(
                  () => Text(
                    authController.livreurName.isNotEmpty
                        ? authController.livreurName
                        : '${authController.livreurMobile}',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary, // Gris moyen
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Indicateur de localisation
        Container(
          margin: const EdgeInsets.only(right: AppDimensions.spacingS),
          child: const LocationIndicatorWidget(),
        ),

        // Bouton configuration
        GestureDetector(
          onTap: () {
            Get.toNamed('/config');
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.settings, color: Colors.white, size: 20),
          ),
        ),

        const SizedBox(width: AppDimensions.spacingS),

        // Bouton notifications
        GestureDetector(
          onTap: () {
            Get.to(() => const NotificationsScreen());
          },
          child: Container(
            margin: const EdgeInsets.only(right: AppDimensions.spacingM),
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: NotificationBadgeWidget(
              child: Center(
                child: Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                  size: AppDimensions.iconSizeS,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(RamassageController ramassageController) {
    // Utiliser les statistiques de l'API pour les ramassages
    final ramassageStats = ramassageController.statistiques;
    final ramassagesEnCours = ramassageStats?.colisEnCours ?? 0;
    final ramassagesTermines = ramassageStats?.colisTermines ?? 0;

    // Utiliser les statistiques de l'API pour les livraisons
    final deliveryController = Get.find<DeliveryController>();
    final deliveryStats = deliveryController.statistiques;
    final colisEnAttente = deliveryStats?.colisEnAttente ?? 0;
    final colisEnCours = deliveryStats?.colisEnCours ?? 0;
    final colisLivres = deliveryStats?.colisLivres ?? 0;
    final totalColis = deliveryStats?.total ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      child: Row(
        children:
            _selectedTab == 0
                ? _buildDeliveryStats(
                  colisEnAttente,
                  colisEnCours,
                  colisLivres,
                  totalColis,
                )
                : _buildRamassageStats(
                  ramassagesEnCours,
                  ramassagesTermines,
                  ramassageStats?.montantTotalEncaisse ?? 0,
                ),
      ),
    );
  }

  List<Widget> _buildDeliveryStats(
    int enAttente,
    int enCours,
    int livres,
    int total,
  ) {
    // Récupérer les statistiques complètes pour les livraisons
    final deliveryController = Get.find<DeliveryController>();
    final deliveryStats = deliveryController.statistiques;
    final colisAnnules = deliveryStats?.colisAnnules ?? 0;
    final montantEncaisse = deliveryStats?.montantTotalEncaisse ?? 0;

    return [
      // Container avec défilement horizontal
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Statistique 1: Colis en attente
              _buildStatCard(
                icon: Icons.schedule,
                title: 'En attente',
                value: '$enAttente',
                subtitle: 'Colis',
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 2: Colis en cours
              _buildStatCard(
                icon: Icons.local_shipping,
                title: 'En cours',
                value: '$enCours',
                subtitle: 'Colis',
                color: AppColors.primary,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 3: Colis livrés
              _buildStatCard(
                icon: Icons.check_circle,
                title: 'Livrés',
                value: '$livres',
                subtitle: 'Colis',
                color: AppColors.success,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 4: Colis annulés
              _buildStatCard(
                icon: Icons.cancel,
                title: 'Annulés',
                value: '$colisAnnules',
                subtitle: 'Colis',
                color: AppColors.error,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 5: Montant encaissé
              _buildStatCard(
                icon: Icons.account_balance_wallet,
                title: 'Encaissé',
                value: _formatAmount(montantEncaisse),
                subtitle: 'FCFA',
                color: AppColors.success,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildRamassageStats(
    int enCours,
    int termines,
    int montantEncaisse,
  ) {
    // Récupérer les statistiques complètes pour les ramassages
    final ramassageController = Get.find<RamassageController>();
    final ramassageStats = ramassageController.statistiques;
    final ramassagesAnnules = ramassageStats?.colisAnnules ?? 0;

    return [
      // Container avec défilement horizontal
      Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Statistique 1: Ramassages en cours
              _buildStatCard(
                icon: Icons.shopping_bag,
                title: 'En cours',
                value: '$enCours',
                subtitle: 'Ramassages',
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 2: Ramassages terminés
              _buildStatCard(
                icon: Icons.check_circle,
                title: 'Terminés',
                value: '$termines',
                subtitle: 'Ramassages',
                color: AppColors.success,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              // Statistique 3: Ramassages annulés
              _buildStatCard(
                icon: Icons.cancel,
                title: 'Annulés',
                value: '$ramassagesAnnules',
                subtitle: 'Ramassages',
                color: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      width: 100, // Largeur fixe pour le défilement horizontal
      padding: const EdgeInsets.all(AppDimensions.spacingS),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icône
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),

          const SizedBox(height: AppDimensions.spacingXS),

          // Valeur
          Text(
            value,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppDimensions.spacingXS),

          // Titre
          Text(
            title,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // Sous-titre
          Text(
            subtitle,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeXS,
              color: AppColors.textHint,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(RamassageController ramassageController) {
    // Utiliser les statistiques de l'API pour les ramassages
    final ramassageStats = ramassageController.statistiques;
    final ramassagesTermines = ramassageStats?.colisTermines ?? 0;
    final totalRamassages = ramassageStats?.total ?? 0;

    // Utiliser les statistiques de l'API pour les livraisons
    final deliveryController = Get.find<DeliveryController>();
    final deliveryStats = deliveryController.statistiques;
    final colisLivres = deliveryStats?.colisLivres ?? 0;
    final totalColis = deliveryStats?.total ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingM,
        vertical: AppDimensions.spacingS,
      ),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow:
                      _selectedTab == 0
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  'Livraisons ($colisLivres/$totalColis)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight:
                        _selectedTab == 0 ? FontWeight.w600 : FontWeight.w500,
                    color:
                        _selectedTab == 0
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.spacingS,
                ),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  boxShadow:
                      _selectedTab == 1
                          ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Text(
                  'Ramassages ($ramassagesTermines/$totalRamassages)',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeXS,
                    fontWeight:
                        _selectedTab == 1 ? FontWeight.w600 : FontWeight.w500,
                    color:
                        _selectedTab == 1
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveriesList() {
    return GetBuilder<DeliveryController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const DeliveryLoadingState();
        }

        // Vérifier s'il y a vraiment une erreur (pas juste pas de données)
        if (controller.errorMessage.isNotEmpty && controller.colis.isEmpty) {
          return DeliveryEmptyState(
            title: 'Erreur de chargement',
            subtitle: controller.errorMessage,
            icon: Icons.error_outline,
            onRetry: () => controller.refreshColis(),
          );
        }

        if (controller.colis.isEmpty) {
          return const DeliveryEmptyState(
            title: 'Aucun colis',
            subtitle: 'Aucun colis de livraison disponible pour le moment',
            icon: Icons.local_shipping_outlined,
          );
        }

        // Filtrer les colis pour afficher uniquement ceux en attente ou en cours
        final activeColis =
            controller.colis
                .where((colis) => colis.status == 0 || colis.status == 1)
                .toList();

        if (activeColis.isEmpty) {
          return const DeliveryEmptyState(
            title: 'Aucune livraison active',
            subtitle: 'Aucune livraison en attente ou en cours pour le moment',
            icon: Icons.local_shipping_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshColis(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            itemCount:
                _getDisplayedActiveColisCount(activeColis) +
                (activeColis.length > 10 ? 1 : 0),
            itemBuilder: (context, index) {
              // Si c'est le dernier élément et qu'il y a plus de 10 colis actifs, afficher le bouton "Voir plus"
              if (index == _getDisplayedActiveColisCount(activeColis) &&
                  activeColis.length > 10) {
                return _buildVoirPlusButtonDelivery(controller, activeColis);
              }

              final colis = activeColis[index];
              return DeliveryCard(
                colis: colis,
                onTap: () => _showDeliveryDetails(colis),
                onStart: () => _startDelivery(colis),
                onComplete: () => _completeDelivery(colis),
                onCancel: () => _cancelDelivery(colis),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPickupsList() {
    return GetBuilder<RamassageController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        // Vérifier s'il y a vraiment une erreur (pas juste pas de données)
        if (controller.errorMessage.isNotEmpty &&
            controller.ramassages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Erreur de chargement',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  controller.errorMessage,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                ElevatedButton(
                  onPressed: () => controller.refreshRamassages(),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (controller.ramassages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Aucun ramassage',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Aucun ramassage disponible pour le moment',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
              ],
            ),
          );
        }

        // Filtrer les ramassages pour afficher uniquement ceux planifiés ou en cours
        final activeRamassages =
            controller.ramassages
                .where(
                  (ramassage) =>
                      ramassage.statut == 'planifie' ||
                      ramassage.statut == 'en_cours',
                )
                .toList();

        if (activeRamassages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.shopping_bag_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: AppDimensions.spacingM),
                Text(
                  'Aucun ramassage actif',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacingS),
                Text(
                  'Aucun ramassage planifié ou en cours pour le moment',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: Colors.grey.shade500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDimensions.spacingM),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshRamassages(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingS,
            ),
            itemCount:
                _getDisplayedActiveRamassagesCount(activeRamassages) +
                (activeRamassages.length > 10 ? 1 : 0),
            itemBuilder: (context, index) {
              // Si c'est le dernier élément et qu'il y a plus de 10 ramassages actifs, afficher le bouton "Voir plus"
              if (index ==
                      _getDisplayedActiveRamassagesCount(activeRamassages) &&
                  activeRamassages.length > 10) {
                return _buildVoirPlusButton(controller, activeRamassages);
              }

              final ramassage = activeRamassages[index];
              return _buildRamassageCard(ramassage, controller);
            },
          ),
        );
      },
    );
  }

  Widget _buildRamassageCard(ramassage, RamassageController controller) {
    // Formater la date
    final datePlanifiee = DateTime.tryParse(ramassage.datePlanifiee);
    final timeFormatted =
        datePlanifiee != null
            ? '${datePlanifiee.hour.toString().padLeft(2, '0')}:${datePlanifiee.minute.toString().padLeft(2, '0')}'
            : '--:--';

    // Montant (sera formaté par le widget)
    final montant = ramassage.montantTotal;

    // Couleur du statut
    final statutColor = _getStatutColor(ramassage.statut);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingM),
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
        children: [
          // Barre de statut colorée
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: statutColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
            ),
          ),

          // Bloc principal cliquable pour les détails
          InkWell(
            onTap: () => _showPickupDetails(ramassage),
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec code et statut
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          ramassage.codeRamassage,
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeS,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.spacingXS),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: statutColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Text(
                          controller.getStatutFormatted(ramassage.statut),
                          style: GoogleFonts.montserrat(
                            fontSize: AppDimensions.fontSizeXS,
                            fontWeight: FontWeight.w500,
                            color: statutColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.spacingS),

                  // Informations du ramassage
                  Row(
                    children: [
                      // Icône et heure
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                        child: Icon(
                          Icons.shopping_bag,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(width: AppDimensions.spacingS),

                      // Détails
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              timeFormatted,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeS,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ramassage.boutique.libelle,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ramassage.adresseRamassage,
                              style: GoogleFonts.montserrat(
                                fontSize: AppDimensions.fontSizeXS,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Montant
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AmountListItem(
                            amount: montant,
                            currency: 'F',
                            textColor: AppColors.success,
                            fontSize: AppDimensions.fontSizeS,
                            fontWeight: FontWeight.w600,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${ramassage.nombreColisEstime} colis',
                            style: GoogleFonts.montserrat(
                              fontSize: AppDimensions.fontSizeXS,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Boutons d'action (séparés du bloc cliquable)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.spacingM,
              0,
              AppDimensions.spacingM,
              AppDimensions.spacingM,
            ),
            child: _buildActionButtons(ramassage),
          ),
        ],
      ),
    );
  }

  Color _getStatutColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return AppColors.warning;
      case 'en_cours':
        return AppColors.primary;
      case 'termine':
        return AppColors.success;
      case 'annule':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  void _showPickupDetails(ramassage) {
    Get.to(
      () => RamassageDetailsScreen(
        ramassageId: ramassage.id,
        codeRamassage: ramassage.codeRamassage,
        fromPage: 'dashboard',
      ),
    );
  }

  void _startPickup(Ramassage ramassage) async {
    // Afficher un dialog de confirmation
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Démarrer le ramassage',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir démarrer le ramassage ${ramassage.codeRamassage} ?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Démarrer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Démarrer le ramassage
      final ramassageController = Get.find<RamassageController>();
      final success = await ramassageController.startRamassage(ramassage.id);

      if (success) {
        // Mise à jour transparente de la liste
        await ramassageController.refreshRamassages();

        // Forcer la mise à jour de l'UI
        ramassageController.update();

        // Envoyer une notification locale
        await _showLocalNotification(
          title: '📦 Ramassage démarré',
          body: 'Vous avez commencé le ramassage ${ramassage.codeRamassage}',
          type: 'success',
        );
      } else {
        // Envoyer une notification locale d'erreur
        await _showLocalNotification(
          title: '❌ Erreur',
          body: ramassageController.errorMessage,
          type: 'error',
        );
      }
    }
  }

  void _finishPickup(Ramassage ramassage) async {
    // Naviguer vers l'écran de finalisation
    final result = await Get.to(
      () =>
          CompleteRamassageScreen(ramassage: ramassage, fromPage: 'dashboard'),
    );

    // Si la finalisation a réussi, rafraîchir la liste de manière transparente
    if (result == true) {
      // Rafraîchir la liste de manière transparente
      final ramassageController = Get.find<RamassageController>();
      await ramassageController.refreshRamassages();

      // Forcer la mise à jour de l'UI
      ramassageController.update();

      // Envoyer une notification locale
      await _showLocalNotification(
        title: '✅ Ramassage terminé',
        body:
            'Le ramassage ${ramassage.codeRamassage} a été terminé avec succès',
        type: 'success',
      );
    } else {}
  }

  void _cancelPickup(Ramassage ramassage) async {
    // Afficher un dialog de confirmation avec saisie de raison
    final result = await Get.dialog<Map<String, String>?>(
      _CancelRamassageDialog(ramassage: ramassage),
    );

    if (result != null) {
      final raison = result['raison'] ?? '';
      final commentaire = result['commentaire'] ?? '';

      // Appel à l'API d'annulation
      final authController = Get.find<AuthController>();
      final response = await CancelRamassageService.cancelRamassage(
        ramassageId: ramassage.id,
        raison: raison,
        commentaire: commentaire,
        token: authController.authToken,
      );

      if (response.success) {
        // Rafraîchir la liste de manière transparente
        final ramassageController = Get.find<RamassageController>();
        await ramassageController.refreshRamassages();

        // Forcer la mise à jour de l'UI
        ramassageController.update();

        // Envoyer une notification locale de succès
        await _showLocalNotification(
          title: '✅ Ramassage annulé',
          body:
              'Le ramassage ${ramassage.codeRamassage} a été annulé avec succès',
          type: 'success',
        );
      } else {
        // Envoyer une notification locale d'erreur
        await _showLocalNotification(
          title: '❌ Erreur',
          body: response.message,
          type: 'error',
        );
      }
    } else {}
  }

  Widget _buildActionButtons(Ramassage ramassage) {
    if (ramassage.statut == 'en_cours') {
      // Boutons pour ramassage en cours
      return Row(
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: () => _finishPickup(ramassage),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Terminer',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: ElevatedButton(
              onPressed: () => _cancelPickup(ramassage),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Annuler',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    } else if (ramassage.statut == 'planifie') {
      // Boutons pour ramassage planifié
      return Row(
        children: [
          Flexible(
            child: ElevatedButton(
              onPressed: () => _startPickup(ramassage),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 16, color: Colors.white),
                  const SizedBox(width: 2),
                  Text(
                    'Démarrer',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 2),
          Flexible(
            child: ElevatedButton(
              onPressed: () => _showPickupDetails(ramassage),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textPrimary,
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
                elevation: 0,
              ),
              child: ClipRect(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 14),
                    const SizedBox(width: 0),
                    Text(
                      'Détails',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeXS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Aucun bouton pour les ramassages terminés ou autres statuts
      return const SizedBox.shrink();
    }
  }

  Widget _buildNativeBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: _selectedBottomNavIndex,
      onTap: _handleBottomNavTap,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.iconSecondary,
      selectedLabelStyle: GoogleFonts.montserrat(
        fontSize: AppDimensions.fontSizeXS,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.montserrat(
        fontSize: AppDimensions.fontSizeXS,
        fontWeight: FontWeight.w500,
      ),
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Accueil',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_shipping_outlined),
          activeIcon: Icon(Icons.local_shipping),
          label: 'Livraisons',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag_outlined),
          activeIcon: Icon(Icons.shopping_bag),
          label: 'Ramassages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
    );
  }

  void _handleBottomNavTap(int index) {
    // Mise à jour immédiate de l'état pour la réactivité
    setState(() {
      _selectedBottomNavIndex = index;
    });

    // Gestion des actions selon l'index
    switch (index) {
      case 0:
        // Accueil - déjà sur le dashboard
        break;
      case 1:
        // Livraisons - navigation vers la liste
        Get.to(() => const DeliveryListScreen())?.then((_) {
          _resetToHomeTab();
        });
        break;
      case 2:
        // Ramassages - navigation vers la liste
        Get.to(() => const RamassageListScreen())?.then((_) {
          _resetToHomeTab();
        });
        break;
      case 3:
        // Profil - navigation vers le profil
        Get.to(() => const ProfileScreen())?.then((_) {
          _resetToHomeTab();
        });
        break;
    }
  }

  /// Gérer l'onglet initial selon les paramètres de l'URL
  void _handleInitialTab() {
    // Vérifier s'il y a un paramètre 'tab' dans l'URL
    final currentRoute = Get.currentRoute;

    if (currentRoute.contains('tab=ramassages')) {
      // Aller directement sur l'onglet Ramassages
      setState(() {
        _selectedBottomNavIndex = 0; // Rester sur l'onglet Accueil
        _selectedTab = 1; // Mais afficher l'onglet Ramassages
      });
    } else {
      // Comportement par défaut
      _resetToHomeTab();
    }
  }

  /// Remettre le focus sur l'onglet Accueil
  void _resetToHomeTab() {
    setState(() {
      _selectedBottomNavIndex = 0;
      _selectedTab = 0;
    });
  }

  /// Obtenir le nombre de ramassages à afficher (maximum 10)
  int _getDisplayedRamassagesCount(RamassageController controller) {
    return controller.ramassages.length > 10
        ? 10
        : controller.ramassages.length;
  }

  /// Obtenir le nombre de ramassages actifs à afficher (maximum 10)
  int _getDisplayedActiveRamassagesCount(List<dynamic> activeRamassages) {
    return activeRamassages.length > 10 ? 10 : activeRamassages.length;
  }

  /// Obtenir le nombre de colis à afficher (maximum 10)
  int _getDisplayedColisCount(DeliveryController controller) {
    return controller.colis.length > 10 ? 10 : controller.colis.length;
  }

  /// Obtenir le nombre de colis actifs à afficher (maximum 10)
  int _getDisplayedActiveColisCount(List<dynamic> activeColis) {
    return activeColis.length > 10 ? 10 : activeColis.length;
  }

  /// Construire le bouton "Voir plus" pour le dashboard
  Widget _buildVoirPlusButton(
    RamassageController controller, [
    List<dynamic>? activeRamassages,
  ]) {
    final totalRamassages =
        activeRamassages?.length ?? controller.ramassages.length;
    final displayedRamassages =
        activeRamassages != null
            ? _getDisplayedActiveRamassagesCount(activeRamassages)
            : _getDisplayedRamassagesCount(controller);
    final remainingRamassages = totalRamassages - displayedRamassages;

    return Container(
      margin: const EdgeInsets.only(
        top: AppDimensions.spacingS,
        bottom: AppDimensions.spacingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(() => const RamassageListScreen()),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, color: AppColors.primary, size: 18),
                const SizedBox(width: AppDimensions.spacingXS),
                Expanded(
                  child: Text(
                    'Voir plus ($remainingRamassages restants)',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Construire le bouton "Voir plus" pour les livraisons
  Widget _buildVoirPlusButtonDelivery(
    DeliveryController controller, [
    List<dynamic>? activeColis,
  ]) {
    final totalColis = activeColis?.length ?? controller.colis.length;
    final displayedColis =
        activeColis != null
            ? _getDisplayedActiveColisCount(activeColis)
            : _getDisplayedColisCount(controller);
    final remainingColis = totalColis - displayedColis;

    return Container(
      margin: const EdgeInsets.only(
        top: AppDimensions.spacingS,
        bottom: AppDimensions.spacingM,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.toNamed('/delivery-list');
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingM,
              vertical: AppDimensions.spacingM,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt, color: AppColors.primary, size: 18),
                const SizedBox(width: AppDimensions.spacingXS),
                Expanded(
                  child: Text(
                    'Voir plus ($remainingColis restants)',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingXS),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.primary,
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthodes d'action pour les livraisons
  void _showDeliveryDetails(colis) {
    Get.to(
      () => DeliveryDetailsScreen(colisId: colis.id, codeColis: colis.code),
    );
  }

  void _startDelivery(colis) async {
    // Afficher un dialog de confirmation
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Démarrer la livraison',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir démarrer la livraison du colis ${colis.code} ?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Démarrer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Démarrer la livraison avec rafraîchissement transparent
      final deliveryController = Get.find<DeliveryController>();
      final success = await deliveryController.startDelivery(colis.id);

      if (success) {
        // Rafraîchir la liste de manière transparente
        await deliveryController.refreshColis();

        // Forcer la mise à jour de l'UI
        deliveryController.update();

        // Envoyer une notification locale
        await _showLocalNotification(
          title: '🚚 Livraison démarrée',
          body: 'Vous avez commencé la livraison du colis ${colis.code}',
          type: 'success',
        );
      } else {
        // Vérifier si c'est le cas des livraisons actives pour afficher un dialog spécial
        if (deliveryController.errorMessage.contains(
          'Vous avez déjà une livraison en cours',
        )) {
          await _showActiveDeliveriesDialog(deliveryController.errorMessage);
        } else {
          // Envoyer une notification locale d'erreur pour les autres cas
          await _showLocalNotification(
            title: '❌ Erreur',
            body: deliveryController.errorMessage,
            type: 'error',
          );
        }
      }
    }
  }

  void _completeDelivery(colis) async {
    // Naviguer vers l'écran de finalisation
    final result = await Get.to(
      () => CompleteDeliveryScreen(
        colisId: colis.id,
        codeColis: colis.code,
        codeValidation: colis.livraison?.codeValidation ?? '',
        fromPage: 'dashboard',
      ),
    );

    // Si la finalisation a réussi, rafraîchir la liste de manière transparente
    if (result == true) {
      // Rafraîchir la liste de manière transparente
      final deliveryController = Get.find<DeliveryController>();
      await deliveryController.refreshColis();

      // Forcer la mise à jour de l'UI
      deliveryController.update();

      // Envoyer une notification locale
      await _showLocalNotification(
        title: '✅ Livraison terminée',
        body: 'La livraison du colis ${colis.code} a été terminée avec succès',
        type: 'success',
      );
    } else {}
  }

  void _cancelDelivery(colis) async {
    // Naviguer vers l'écran d'annulation
    final result = await Get.to(
      () => CancelDeliveryScreen(
        colisId: colis.id,
        codeColis: colis.code,
        fromPage: 'dashboard',
      ),
    );

    // Si l'annulation a réussi, rafraîchir la liste de manière transparente
    if (result == true) {
      // Rafraîchir la liste de manière transparente
      final deliveryController = Get.find<DeliveryController>();
      await deliveryController.refreshColis();

      // Forcer la mise à jour de l'UI
      deliveryController.update();

      // Envoyer une notification locale
      await _showLocalNotification(
        title: '❌ Livraison annulée',
        body: 'La livraison du colis ${colis.code} a été annulée',
        type: 'error',
      );
    } else {}
  }

  /// Afficher un dialog pour les livraisons actives
  Future<void> _showActiveDeliveriesDialog(String errorMessage) async {
    await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
                size: 20,
              ),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Expanded(
              child: Text(
                'Livraison en cours',
                style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimensions.fontSizeM,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vous avez déjà une livraison en cours. Terminez-la avant d\'en démarrer une nouvelle.',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingM),
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingS),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Livraison active :',
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacingXS),
                  Text(
                    errorMessage.split('Livraisons en cours :')[1].trim(),
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Compris',
              style: GoogleFonts.montserrat(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
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
