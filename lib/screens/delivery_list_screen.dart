import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../controllers/delivery_controller.dart';
import '../models/delivery_models.dart';
import '../services/notification_service.dart';
import '../widgets/delivery_widgets.dart';
import '../widgets/advanced_filter_widget.dart';
import 'delivery_details_screen.dart';
import 'delivery_statistics_screen.dart';
import 'complete_delivery_screen.dart';
import 'cancel_delivery_screen.dart';

class DeliveryListScreen extends StatefulWidget {
  const DeliveryListScreen({super.key});

  @override
  State<DeliveryListScreen> createState() => _DeliveryListScreenState();
}

class _DeliveryListScreenState extends State<DeliveryListScreen> {
  final DeliveryController _deliveryController = Get.find<DeliveryController>();
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'Tous';
  List<Colis> _filteredColis = [];

  // Variables pour le filtre avancé
  String _selectedDeliveryType = 'Tous';
  String _selectedPeriod = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasAdvancedFilter = false;

  // Variables pour la pagination
  static const int _itemsPerPage = 10;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasMoreData = true;
  List<Colis> _paginatedColis = [];

  // Statuts disponibles pour le filtre
  final List<String> _statusOptions = [
    'Tous',
    'En attente',
    'En cours',
    'Terminé',
    'Annulé',
  ];

  @override
  void initState() {
    super.initState();
    _loadDeliveries();
    _searchController.addListener(_filterDeliveries);
    _checkNotificationRefreshFlags();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadDeliveries() async {
    await _deliveryController.loadColis();
    _filterDeliveries(loadInitialItems: true);
  }

  /// Réinitialiser la pagination
  void _resetPagination() {
    _currentPage = 1;
    _isLoadingMore = false;
    _hasMoreData = true;
    _paginatedColis.clear();
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

      if (startIndex < _filteredColis.length) {
        final newItems = _filteredColis.sublist(
          startIndex,
          endIndex > _filteredColis.length ? _filteredColis.length : endIndex,
        );

        setState(() {
          _paginatedColis.addAll(newItems);
          _currentPage++;
          _hasMoreData = endIndex < _filteredColis.length;
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

  /// Vérifier les flags d'actualisation des notifications
  void _checkNotificationRefreshFlags() {
    try {
      print(
        '🔄 Vérification des flags d\'actualisation des notifications (DeliveryListScreen)',
      );
      NotificationService.checkAndProcessRefreshFlags();
    } catch (e) {
      print('❌ Erreur lors de la vérification des flags: $e');
    }
  }

  void _filterDeliveries({bool loadInitialItems = false}) {
    final allColis = _deliveryController.colis;
    final searchQuery = _searchController.text.toLowerCase();

    setState(() {
      _filteredColis =
          allColis.where((colis) {
            // Filtre par statut
            bool statusMatch =
                _selectedStatus == 'Tous' ||
                _getStatusDisplayName(colis.status) == _selectedStatus;

            // Filtre par type de livraison (si filtre avancé actif)
            bool deliveryTypeMatch =
                !_hasAdvancedFilter ||
                _selectedDeliveryType == 'Tous' ||
                colis.modeLivraison.libelle == _selectedDeliveryType;

            // Filtre par période (si filtre avancé actif)
            bool periodMatch =
                !_hasAdvancedFilter ||
                _selectedPeriod == 'Tous' ||
                (_selectedPeriod == 'Période personnalisée' &&
                    _isInCustomPeriod(colis.updatedAt)) ||
                _isInPeriod(colis.updatedAt, _selectedPeriod);

            // Filtre par recherche
            bool searchMatch =
                searchQuery.isEmpty ||
                colis.code.toLowerCase().contains(searchQuery) ||
                colis.nomClient.toLowerCase().contains(searchQuery) ||
                colis.adresseClient.toLowerCase().contains(searchQuery) ||
                colis.commune.libelle.toLowerCase().contains(searchQuery);

            return statusMatch &&
                deliveryTypeMatch &&
                periodMatch &&
                searchMatch;
          }).toList();

      // Réinitialiser la pagination après filtrage
      _resetPagination();

      // Charger les éléments initiaux seulement si demandé
      if (loadInitialItems) {
        _loadMoreItems(isInitialLoad: true);
      }
    });
  }

  String _getStatusDisplayName(int status) {
    switch (status) {
      case 0:
        return 'En attente';
      case 1:
        return 'En cours';
      case 2:
        return 'Terminé';
      case 3:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  void _showStatusFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
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
                      'Filtrer par statut',
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
              // Status list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingM,
                  ),
                  itemCount: _statusOptions.length,
                  itemBuilder: (context, index) {
                    final status = _statusOptions[index];
                    final isSelected = _selectedStatus == status;

                    return Container(
                      margin: const EdgeInsets.only(
                        bottom: AppDimensions.spacingS,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedStatus = status;
                            });
                            _filterDeliveries(loadInitialItems: true);
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
                                    status,
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
                                // Icône de statut
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      status,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Icon(
                                    _getStatusIcon(status),
                                    size: 16,
                                    color: _getStatusColor(status),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'En attente':
        return AppColors.warning;
      case 'En cours':
        return AppColors.primary;
      case 'Terminé':
        return AppColors.success;
      case 'Annulé':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'En attente':
        return Icons.access_time;
      case 'En cours':
        return Icons.local_shipping;
      case 'Terminé':
        return Icons.check_circle;
      case 'Annulé':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  void _showDeliveryDetails(Colis colis) {
    Get.to(
      () => DeliveryDetailsScreen(colisId: colis.id, codeColis: colis.code),
    );
  }

  void _startDelivery(Colis colis) async {
    try {
      final success = await _deliveryController.startDelivery(colis.id);
      if (success) {
        Get.snackbar(
          'Succès',
          'Livraison démarrée avec succès',
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        _filterDeliveries(
          loadInitialItems: true,
        ); // Rafraîchir la liste filtrée avec pagination
      } else {
        // Vérifier si c'est le cas des livraisons actives pour afficher un dialog spécial
        if (_deliveryController.errorMessage.contains(
          'Vous avez déjà une livraison en cours',
        )) {
          await _showActiveDeliveriesDialog(_deliveryController.errorMessage);
        } else {
          Get.snackbar(
            'Erreur',
            _deliveryController.errorMessage,
            backgroundColor: AppColors.error,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors du démarrage de la livraison',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _completeDelivery(Colis colis) {
    Get.to(
      () => CompleteDeliveryScreen(
        colisId: colis.id,
        codeColis: colis.code,
        codeValidation: colis.livraison.codeValidation,
        fromPage: 'delivery_list',
      ),
    );
  }

  void _cancelDelivery(Colis colis) {
    Get.to(
      () => CancelDeliveryScreen(
        colisId: colis.id,
        codeColis: colis.code,
        fromPage: 'delivery_list',
      ),
    );
  }

  void _showAdvancedFilter() {
    print('🔍 [DeliveryList] _showAdvancedFilter() appelée');
    print(
      '🔍 [DeliveryList] Nombre total de colis: ${_deliveryController.colis.length}',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        print('🔍 [DeliveryList] Construction du AdvancedFilterWidget');
        return AdvancedFilterWidget(
          allColis: _deliveryController.colis,
          onFilterApplied: _onAdvancedFilterApplied,
        );
      },
    );
    print('🔍 [DeliveryList] showModalBottomSheet appelé');
  }

  void _onAdvancedFilterApplied(
    List<Colis> filteredColis,
    String deliveryType,
    String status,
    String period,
    DateTime? startDate,
    DateTime? endDate,
    bool showStatistics,
  ) {
    print('🔍 [DeliveryList] _onAdvancedFilterApplied() appelée');
    print('🔍 [DeliveryList] Nombre de colis filtrés: ${filteredColis.length}');
    print('🔍 [DeliveryList] Type: $deliveryType');
    print('🔍 [DeliveryList] Statut: $status');
    print('🔍 [DeliveryList] Période: $period');
    print('🔍 [DeliveryList] Date début: $startDate');
    print('🔍 [DeliveryList] Date fin: $endDate');
    print('🔍 [DeliveryList] Afficher statistiques: $showStatistics');

    setState(() {
      _selectedDeliveryType = deliveryType;
      _selectedStatus = status;
      _selectedPeriod = period;
      _startDate = startDate;
      _endDate = endDate;
      _hasAdvancedFilter =
          deliveryType != 'Tous' || status != 'Tous' || period != 'Tous';
      _filteredColis = filteredColis;
    });

    print('🔍 [DeliveryList] setState() terminé');
    print('🔍 [DeliveryList] _hasAdvancedFilter: $_hasAdvancedFilter');
    print('🔍 [DeliveryList] _filteredColis.length: ${_filteredColis.length}');

    // Redirection conditionnelle vers la page de statistiques
    if (showStatistics) {
      print(
        '🔍 [DeliveryList] showStatistics = true, appel de _navigateToStatistics() avec délai',
      );
      // Ajouter un petit délai pour s'assurer que le modal est fermé
      Future.delayed(const Duration(milliseconds: 100), () {
        print(
          '🔍 [DeliveryList] Délai écoulé, navigation vers les statistiques',
        );
        _navigateToStatistics();
      });
    } else {
      print('🔍 [DeliveryList] showStatistics = false, pas de redirection');
    }
  }

  void _navigateToStatistics() {
    print('🔍 [DeliveryList] _navigateToStatistics() appelée');
    print('🔍 [DeliveryList] _filteredColis.length: ${_filteredColis.length}');

    if (_filteredColis.isEmpty) {
      print('🔍 [DeliveryList] Liste vide, affichage du snackbar');
      Get.snackbar(
        'Aucune donnée',
        'Aucune livraison trouvée pour afficher les statistiques',
        backgroundColor: AppColors.warning,
        colorText: Colors.white,
      );
      return;
    }

    print('🔍 [DeliveryList] Navigation vers DeliveryStatisticsScreen');
    print('🔍 [DeliveryList] Paramètres:');
    print(
      '🔍 [DeliveryList] - filteredColis: ${_filteredColis.length} éléments',
    );
    print('🔍 [DeliveryList] - selectedDeliveryType: $_selectedDeliveryType');
    print('🔍 [DeliveryList] - selectedStatus: $_selectedStatus');
    print('🔍 [DeliveryList] - selectedPeriod: $_selectedPeriod');
    print('🔍 [DeliveryList] - startDate: $_startDate');
    print('🔍 [DeliveryList] - endDate: $_endDate');

    Get.to(
      () => DeliveryStatisticsScreen(
        filteredColis: _filteredColis,
        selectedDeliveryType: _selectedDeliveryType,
        selectedStatus: _selectedStatus,
        selectedPeriod: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
      ),
    );
    print('🔍 [DeliveryList] Get.to() appelé');
  }

  void _showStatistics() {
    _navigateToStatistics();
  }

  bool _isInPeriod(String dateString, String period) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();

      switch (period) {
        case 'Aujourd\'hui':
          return date.year == now.year &&
              date.month == now.month &&
              date.day == now.day;
        case 'Cette semaine':
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
              date.isBefore(endOfWeek.add(const Duration(days: 1)));
        case 'Ce mois':
          return date.year == now.year && date.month == now.month;
        case 'Ce trimestre':
          final quarterStart = DateTime(
            now.year,
            ((now.month - 1) ~/ 3) * 3 + 1,
          );
          final quarterEnd = DateTime(now.year, quarterStart.month + 3, 0);
          return date.isAfter(quarterStart.subtract(const Duration(days: 1))) &&
              date.isBefore(quarterEnd.add(const Duration(days: 1)));
        default:
          return true;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Barre de recherche
          _buildSearchBar(),

          // Indicateur de filtre actif
          if (_hasAdvancedFilter) _buildActiveFilterIndicator(),

          // Liste des livraisons
          Expanded(child: _buildDeliveriesList()),
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
        'Livraisons',
        style: GoogleFonts.montserrat(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      centerTitle: true,
      actions: [
        // Icône de statistiques
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  _hasAdvancedFilter
                      ? AppColors.success.withOpacity(0.1)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.analytics,
              color:
                  _hasAdvancedFilter ? AppColors.success : Colors.grey.shade600,
              size: 20,
            ),
          ),
          onPressed: _showStatistics,
        ),
        // Icône de filtre avancé
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  _hasAdvancedFilter
                      ? AppColors.primary.withOpacity(0.1)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.tune,
              color:
                  _hasAdvancedFilter ? AppColors.primary : Colors.grey.shade600,
              size: 20,
            ),
          ),
          onPressed: _showAdvancedFilter,
        ),
        // Icône de filtre simple
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color:
                  _selectedStatus != 'Tous'
                      ? AppColors.warning.withOpacity(0.1)
                      : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.filter_list,
              color:
                  _selectedStatus != 'Tous'
                      ? AppColors.warning
                      : Colors.grey.shade600,
              size: 20,
            ),
          ),
          onPressed: _showStatusFilterModal,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildActiveFilterIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingM),
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_alt, color: AppColors.primary, size: 16),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              'Filtre actif: ${_getActiveFilterText()}',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeXS,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: _clearAdvancedFilter,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(Icons.close, color: AppColors.primary, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _getActiveFilterText() {
    List<String> activeFilters = [];

    if (_selectedDeliveryType != 'Tous') {
      activeFilters.add('Type: $_selectedDeliveryType');
    }
    if (_selectedStatus != 'Tous') {
      activeFilters.add('Statut: $_selectedStatus');
    }
    if (_selectedPeriod != 'Tous') {
      if (_selectedPeriod == 'Période personnalisée' &&
          (_startDate != null || _endDate != null)) {
        activeFilters.add('Période: ${_getDateRangeText()}');
      } else {
        activeFilters.add('Période: $_selectedPeriod');
      }
    }

    return activeFilters.join(', ');
  }

  String _getDateRangeText() {
    if (_startDate != null && _endDate != null) {
      return 'Du ${_formatDate(_startDate!)} au ${_formatDate(_endDate!)}';
    } else if (_startDate != null) {
      return 'À partir du ${_formatDate(_startDate!)}';
    } else if (_endDate != null) {
      return 'Jusqu\'au ${_formatDate(_endDate!)}';
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  bool _isInCustomPeriod(String dateString) {
    if (_startDate == null && _endDate == null) return true;

    try {
      final date = DateTime.parse(dateString);
      final dateOnly = DateTime(date.year, date.month, date.day);

      if (_startDate != null && _endDate != null) {
        final startOnly = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        final endOnly = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        return dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAtSameMomentAs(endOnly) ||
            (dateOnly.isAfter(startOnly) && dateOnly.isBefore(endOnly));
      } else if (_startDate != null) {
        final startOnly = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        return dateOnly.isAtSameMomentAs(startOnly) ||
            dateOnly.isAfter(startOnly);
      } else if (_endDate != null) {
        final endOnly = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );
        return dateOnly.isAtSameMomentAs(endOnly) || dateOnly.isBefore(endOnly);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  void _clearAdvancedFilter() {
    setState(() {
      _selectedDeliveryType = 'Tous';
      _selectedStatus = 'Tous';
      _selectedPeriod = 'Tous';
      _startDate = null;
      _endDate = null;
      _hasAdvancedFilter = false;
    });
    _filterDeliveries(loadInitialItems: true);
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppDimensions.spacingM),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher par code, client, adresse...',
          hintStyle: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeS,
            color: Colors.grey.shade500,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade500, size: 20),
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
                      _filterDeliveries(loadInitialItems: true);
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingM,
            vertical: AppDimensions.spacingS,
          ),
        ),
        style: GoogleFonts.montserrat(
          fontSize: AppDimensions.fontSizeS,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildDeliveriesList() {
    return GetBuilder<DeliveryController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const DeliveryLoadingState();
        }

        if (_filteredColis.isEmpty) {
          return DeliveryEmptyState(
            title:
                _searchController.text.isNotEmpty || _selectedStatus != 'Tous'
                    ? 'Aucune livraison trouvée'
                    : 'Aucune livraison disponible',
            subtitle:
                _searchController.text.isNotEmpty || _selectedStatus != 'Tous'
                    ? 'Essayez de modifier vos critères de recherche'
                    : 'Vous n\'avez aucune livraison assignée',
            icon:
                _searchController.text.isNotEmpty || _selectedStatus != 'Tous'
                    ? Icons.search_off
                    : Icons.local_shipping_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: _loadDeliveries,
          color: AppColors.primary,
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
              ),
              itemCount: _paginatedColis.length + (_hasMoreData ? 1 : 0),
              itemBuilder: (context, index) {
                // Si c'est le dernier élément et qu'il y a plus de données, afficher l'indicateur de chargement
                if (index == _paginatedColis.length) {
                  return _buildLoadMoreIndicator();
                }

                final colis = _paginatedColis[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
                  child: DeliveryCard(
                    colis: colis,
                    onTap: () => _showDeliveryDetails(colis),
                    onStart: () => _startDelivery(colis),
                    onComplete: () => _completeDelivery(colis),
                    onCancel: () => _cancelDelivery(colis),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Construire l'indicateur de chargement pour plus d'éléments
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingM),
      child: Center(
        child:
            _isLoadingMore
                ? _buildShimmerLoadingCards()
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

  /// Construire des cartes shimmer pour le chargement
  Widget _buildShimmerLoadingCards() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(children: List.generate(3, (index) => _buildShimmerCard())),
    );
  }

  /// Construire une carte shimmer individuelle
  Widget _buildShimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
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
          // En-tête avec icône et statut
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 16,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingS),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Informations client
          Row(
            children: [
              Icon(Icons.person_outline, size: 16, color: Colors.grey.shade300),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),

          // Adresse
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: Colors.grey.shade300,
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Container(
                  height: 14,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingS),

          // Montant et date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 16,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Container(
                height: 14,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.spacingM),

          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingS),
              Expanded(
                child: Container(
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusS),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
