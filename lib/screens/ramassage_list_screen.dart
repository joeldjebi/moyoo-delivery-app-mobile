import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../controllers/ramassage_controller.dart';
import '../models/ramassage_models.dart';
import '../services/notification_service.dart';
import '../services/local_notification_service.dart';
import '../services/cancel_ramassage_service.dart';
import '../controllers/auth_controller.dart';
import 'ramassage_details_screen.dart';
import 'complete_ramassage_screen.dart';
import '../widgets/formatted_amount_widget.dart';

class RamassageListScreen extends StatefulWidget {
  const RamassageListScreen({super.key});

  @override
  State<RamassageListScreen> createState() => _RamassageListScreenState();
}

class _RamassageListScreenState extends State<RamassageListScreen> {
  late RamassageController _ramassageController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Tous';

  // Options de filtrage par statut
  final List<String> _filterOptions = [
    'Tous',
    'Planifiés',
    'En cours',
    'Terminés',
    'Annulés',
  ];

  // Variables pour la pagination
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<Ramassage> _filteredRamassages = [];
  List<Ramassage> _paginatedRamassages = [];

  @override
  void initState() {
    super.initState();
    _ramassageController = Get.find<RamassageController>();
    _searchController.addListener(_filterRamassages);

    // Charger les ramassages une seule fois
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRamassagesIfNeeded();
      _checkNotificationRefreshFlags();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRamassagesIfNeeded() async {
    // Forcer le chargement des ramassages
    if (_ramassageController.ramassages.isEmpty &&
        !_ramassageController.isLoading) {
      await _ramassageController.forceLoadRamassages();
    }

    // Filtrer et paginer les ramassages
    _filterRamassages(loadInitialItems: true);
  }

  /// Vérifier les flags d'actualisation des notifications
  void _checkNotificationRefreshFlags() {
    try {
      NotificationService.checkAndProcessRefreshFlags();
    } catch (e) {}
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
    } catch (e) {}
  }

  /// Réinitialiser la pagination
  void _resetPagination() {
    _currentPage = 1;
    _isLoadingMore = false;
    _hasMoreData = true;
    _paginatedRamassages.clear();
  }

  /// Charger plus d'éléments pour la pagination
  void _loadMoreItems({bool isInitialLoad = false}) {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Pour le chargement initial, pas de délai artificiel
    // Pour les chargements suivants, simuler un délai de réseau
    final delay =
        isInitialLoad ? Duration.zero : const Duration(milliseconds: 300);

    Future.delayed(delay, () {
      final startIndex = (_currentPage - 1) * _itemsPerPage;
      final endIndex = startIndex + _itemsPerPage;

      if (startIndex < _filteredRamassages.length) {
        final newItems = _filteredRamassages.sublist(
          startIndex,
          endIndex > _filteredRamassages.length
              ? _filteredRamassages.length
              : endIndex,
        );

        setState(() {
          _paginatedRamassages.addAll(newItems);
          _currentPage++;
          _hasMoreData = endIndex < _filteredRamassages.length;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _hasMoreData = false;
          _isLoadingMore = false;
        });
      }
    });
  }

  /// Filtrer les ramassages avec pagination
  void _filterRamassages({bool loadInitialItems = false}) {
    final allRamassages = _ramassageController.ramassages;
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredRamassages =
          allRamassages.where((ramassage) {
            // Filtre par statut
            bool statusMatch =
                _selectedFilter == 'Tous' ||
                _getStatusDisplayName(ramassage.statut) == _selectedFilter;

            // Filtre par recherche
            bool searchMatch =
                searchQuery.isEmpty ||
                ramassage.codeRamassage.toLowerCase().contains(searchQuery) ||
                ramassage.adresseRamassage.toLowerCase().contains(
                  searchQuery,
                ) ||
                ramassage.contactRamassage.toLowerCase().contains(
                  searchQuery,
                ) ||
                ramassage.marchand.firstName.toLowerCase().contains(
                  searchQuery,
                ) ||
                ramassage.marchand.lastName.toLowerCase().contains(
                  searchQuery,
                ) ||
                ramassage.boutique.libelle.toLowerCase().contains(searchQuery);

            return statusMatch && searchMatch;
          }).toList();

      // Réinitialiser la pagination après filtrage
      _resetPagination();

      // Charger les éléments initiaux seulement si demandé
      if (loadInitialItems) {
        _loadMoreItems(isInitialLoad: true);
      }
    });
  }

  /// Obtenir le nom d'affichage du statut
  String _getStatusDisplayName(String status) {
    switch (status) {
      case 'planifie':
        return 'Planifiés';
      case 'en_cours':
        return 'En cours';
      case 'termine':
        return 'Terminés';
      case 'annule':
        return 'Annulés';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(child: _buildRamassageList()),
        ],
      ),
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
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
        ),
      ),
      leading: Container(
        margin: const EdgeInsets.all(AppDimensions.spacingS),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
          padding: const EdgeInsets.all(AppDimensions.spacingS),
        ),
      ),
      title: Text(
        'Liste des ramassages',
        style: GoogleFonts.montserrat(
          fontSize: AppDimensions.fontSizeM,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        // Bouton de filtre
        Container(
          margin: const EdgeInsets.only(right: AppDimensions.spacingM),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
            onPressed: _showFilterDropdown,
            padding: const EdgeInsets.all(AppDimensions.spacingS),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un ramassage...',
                hintStyle: GoogleFonts.montserrat(
                  color: Colors.grey.shade500,
                  fontSize: AppDimensions.fontSizeS,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.grey.shade500,
                  size: 20,
                ),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: Colors.grey.shade500,
                            size: 20,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _filterRamassages(loadInitialItems: true);
                          },
                        )
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingM,
                  vertical: AppDimensions.spacingS,
                ),
              ),
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                color: AppColors.textPrimary,
              ),
              onChanged: (value) => setState(() {}),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamassageList() {
    return GetBuilder<RamassageController>(
      builder: (controller) {
        if (controller.isLoading) {
          return _buildShimmerLoading();
        }

        if (controller.errorMessage.isNotEmpty) {
          return _buildErrorState(controller);
        }

        // Utiliser les ramassages paginés au lieu des filtrés
        if (_paginatedRamassages.isEmpty && !controller.isLoading) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.forceLoadRamassages();
            _filterRamassages(loadInitialItems: true);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                      scrollInfo.metrics.maxScrollExtent &&
                  _hasMoreData &&
                  !_isLoadingMore) {
                _loadMoreItems();
              }
              return false;
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingM,
                vertical: AppDimensions.spacingS,
              ),
              itemCount: _paginatedRamassages.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Si c'est le dernier élément et qu'il y a plus de données, afficher l'indicateur de chargement
                if (index == _paginatedRamassages.length) {
                  return _buildLoadMoreIndicator();
                }

                final ramassage = _paginatedRamassages[index];
                return _buildRamassageCard(ramassage, controller);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingM,
          vertical: AppDimensions.spacingS,
        ),
        itemCount: 5,
        itemBuilder: (context, index) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
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
          // Barre de statut
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusM),
                topRight: Radius.circular(AppDimensions.radiusM),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            child: Column(
              children: [
                // En-tête
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 100,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Container(
                      width: 60,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingS),

                // Contenu principal
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 150,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 60,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 40,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingM),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppDimensions.spacingS),
                    Expanded(
                      child: Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusS,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(RamassageController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
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
            onPressed: () => controller.forceLoadRamassages(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
            ),
            child: Text(
              'Réessayer',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
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
            _searchController.text.isNotEmpty || _selectedFilter != 'Tous'
                ? 'Aucun ramassage ne correspond à vos critères'
                : 'Aucun ramassage disponible pour le moment',
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          if (_searchController.text.isNotEmpty ||
              _selectedFilter != 'Tous') ...[
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedFilter = 'Tous');
                _filterRamassages(loadInitialItems: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: Text(
                'Réinitialiser les filtres',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ] else ...[
            // Bouton de chargement manuel si pas de filtres
            const SizedBox(height: AppDimensions.spacingM),
            ElevatedButton(
              onPressed: () async {
                await _ramassageController.forceLoadRamassages();
                _filterRamassages(loadInitialItems: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              child: Text(
                'Charger les ramassages',
                style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construire l'indicateur de chargement pour plus d'éléments
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Center(
        child:
            _isLoadingMore
                ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Text(
                      'Chargement...',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )
                : Text(
                  'Aucun autre élément à charger',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
      ),
    );
  }

  Widget _buildRamassageCard(
    Ramassage ramassage,
    RamassageController controller,
  ) {
    // Formater la date et l'heure
    final datePlanifiee = DateTime.tryParse(ramassage.datePlanifiee);
    final timeFormatted =
        datePlanifiee != null
            ? _formatDateTime(datePlanifiee)
            : '--/--/---- --:--';

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
                        width: Get.width * 0.1,
                        height: Get.height * 0.05,
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
                                fontSize: 11,
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

  void _showPickupDetails(Ramassage ramassage) {
    Get.to(
      () => RamassageDetailsScreen(
        ramassageId: ramassage.id,
        codeRamassage: ramassage.codeRamassage,
        fromPage: 'ramassage_list',
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
      final success = await _ramassageController.startRamassage(ramassage.id);

      if (success) {
        // Mise à jour transparente de la liste
        await _ramassageController.refreshRamassages();

        Get.snackbar(
          '📦 Ramassage démarré',
          'Vous avez commencé le ramassage ${ramassage.codeRamassage}',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          icon: const Icon(Icons.check_circle, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          '❌ Erreur',
          _ramassageController.errorMessage,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          icon: const Icon(Icons.error, color: Colors.white),
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    }
  }

  void _finishPickup(Ramassage ramassage) async {
    // Naviguer vers l'écran de finalisation
    final result = await Get.to(
      () => CompleteRamassageScreen(
        ramassage: ramassage,
        fromPage: 'ramassage_list',
      ),
    );

    // Si la finalisation a réussi, recharger les données de manière transparente
    if (result == true) {
      // Les données sont déjà actualisées par CompleteRamassageScreen
      // Le message de succès est aussi affiché par CompleteRamassageScreen
      // Pas besoin de dupliquer ici
    }
  }

  void _cancelPickup(Ramassage ramassage) async {
    // Afficher un dialog de confirmation
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.spacingXS),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              ),
              child: const Icon(Icons.cancel, color: AppColors.error, size: 20),
            ),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Annuler le ramassage',
              style: GoogleFonts.montserrat(
                fontWeight: FontWeight.w600,
                fontSize: AppDimensions.fontSizeM,
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir annuler le ramassage ${ramassage.codeRamassage} ?',
          style: GoogleFonts.montserrat(),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              'Non',
              style: GoogleFonts.montserrat(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              'Annuler',
              style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
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
          await _ramassageController.refreshRamassages();

          // Forcer la mise à jour de l'UI
          _ramassageController.update();

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
                  const Icon(
                    Icons.check_circle,
                    size: AppDimensions.iconSizeS,
                    color: Colors.white,
                  ),
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
                  const Icon(
                    Icons.cancel,
                    size: AppDimensions.iconSizeS,
                    color: Colors.white,
                  ),
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
                  const Icon(
                    Icons.play_arrow,
                    size: AppDimensions.iconSizeS,
                    color: Colors.white,
                  ),
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

  /// Afficher le dropdown de filtrage par statut
  void _showFilterDropdown() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: AppDimensions.spacingS),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Titre
              Padding(
                padding: const EdgeInsets.all(AppDimensions.spacingM),
                child: Text(
                  'Filtrer par statut',
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeM,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // Liste des options
              ListView.builder(
                shrinkWrap: true,
                itemCount: _filterOptions.length,
                itemBuilder: (context, index) {
                  final option = _filterOptions[index];
                  final isSelected = _selectedFilter == option;

                  return ListTile(
                    leading: Icon(
                      _getFilterIcon(option),
                      color:
                          isSelected
                              ? AppColors.primary
                              : AppColors.textSecondary,
                      size: 20,
                    ),
                    title: Text(
                      option,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color:
                            isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Icon(
                              Icons.check_circle,
                              color: AppColors.primary,
                              size: 20,
                            )
                            : null,
                    onTap: () {
                      setState(() {
                        _selectedFilter = option;
                      });
                      _filterRamassages(loadInitialItems: true);
                      Navigator.pop(context);
                    },
                  );
                },
              ),

              // Espace en bas
              const SizedBox(height: AppDimensions.spacingM),
            ],
          ),
        );
      },
    );
  }

  /// Obtenir l'icône correspondant au filtre
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'Tous':
        return Icons.list_alt;
      case 'Planifiés':
        return Icons.schedule;
      case 'En cours':
        return Icons.play_circle_outline;
      case 'Terminés':
        return Icons.check_circle_outline;
      case 'Annulés':
        return Icons.cancel_outlined;
      default:
        return Icons.filter_list;
    }
  }

  /// Formater une date en format date et heure lisible
  String _formatDateTime(DateTime date) {
    final formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    final formattedTime =
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    return '$formattedDate $formattedTime';
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
