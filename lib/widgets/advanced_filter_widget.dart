import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../models/delivery_models.dart';
import 'calendar_filter_widget.dart';

class AdvancedFilterWidget extends StatefulWidget {
  final List<Colis> allColis;
  final Function(
    List<Colis>,
    String,
    String,
    String,
    DateTime?,
    DateTime?,
    bool,
  )
  onFilterApplied;
  final bool showStatisticsOption;

  const AdvancedFilterWidget({
    super.key,
    required this.allColis,
    required this.onFilterApplied,
    this.showStatisticsOption = true,
  });

  @override
  State<AdvancedFilterWidget> createState() => _AdvancedFilterWidgetState();
}

class _AdvancedFilterWidgetState extends State<AdvancedFilterWidget> {
  String _selectedDeliveryType = 'Tous';
  String _selectedStatus = 'Tous';
  String _selectedPeriod = 'Tous';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showStatisticsAfterFilter = true;

  // Options disponibles
  List<String> _deliveryTypes = ['Tous'];
  List<String> _statuses = [
    'Tous',
    'En attente',
    'En cours',
    'Terminé',
    'Annulé',
  ];
  List<String> _periods = [
    'Tous',
    'Aujourd\'hui',
    'Cette semaine',
    'Ce mois',
    'Ce trimestre',
    'Période personnalisée',
  ];

  @override
  void initState() {
    super.initState();
    _extractDeliveryTypes();
  }

  void _extractDeliveryTypes() {
    final types =
        widget.allColis
            .map((colis) => colis.modeLivraison.libelle)
            .toSet()
            .toList();
    types.sort();
    _deliveryTypes = ['Tous', ...types];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
                  'Filtre avancé',
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

          // Filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type de livraison
                  _buildFilterSection(
                    'Type de livraison',
                    Icons.local_shipping,
                    _deliveryTypes,
                    _selectedDeliveryType,
                    (value) => setState(() => _selectedDeliveryType = value),
                  ),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Statut
                  _buildFilterSection(
                    'Statut',
                    Icons.flag,
                    _statuses,
                    _selectedStatus,
                    (value) => setState(() => _selectedStatus = value),
                  ),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Période
                  _buildPeriodSection(),

                  const SizedBox(height: AppDimensions.spacingM),

                  // Option d'affichage des statistiques
                  if (widget.showStatisticsOption) _buildStatisticsOption(),
                ],
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(AppDimensions.spacingM),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _resetFilters,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                      side: BorderSide(color: Colors.grey.shade400),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                    ),
                    child: Text(
                      'Réinitialiser',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _applyFilters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.spacingS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusS,
                        ),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Appliquer',
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    IconData icon,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 20),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Wrap(
          spacing: AppDimensions.spacingS,
          runSpacing: AppDimensions.spacingS,
          children:
              options.map((option) {
                final isSelected = selectedValue == option;
                return GestureDetector(
                  onTap: () => onChanged(option),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildPeriodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
            const SizedBox(width: AppDimensions.spacingS),
            Text(
              'Période',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeM,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingS),
        Wrap(
          spacing: AppDimensions.spacingS,
          runSpacing: AppDimensions.spacingS,
          children:
              _periods.map((period) {
                final isSelected = _selectedPeriod == period;
                return GestureDetector(
                  onTap: () {
                    if (period == 'Période personnalisée') {
                      _showCalendarFilter();
                    } else {
                      setState(() {
                        _selectedPeriod = period;
                        _startDate = null;
                        _endDate = null;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingM,
                      vertical: AppDimensions.spacingS,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? AppColors.primary : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusS,
                      ),
                      border: Border.all(
                        color:
                            isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      period,
                      style: GoogleFonts.montserrat(
                        fontSize: AppDimensions.fontSizeS,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.normal,
                        color:
                            isSelected ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
        ),
        // Affichage de la période personnalisée sélectionnée
        if (_startDate != null || _endDate != null)
          Container(
            margin: const EdgeInsets.only(top: AppDimensions.spacingS),
            padding: const EdgeInsets.all(AppDimensions.spacingS),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusS),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.date_range, color: AppColors.primary, size: 16),
                const SizedBox(width: AppDimensions.spacingS),
                Expanded(
                  child: Text(
                    _getDateRangeText(),
                    style: GoogleFonts.montserrat(
                      fontSize: AppDimensions.fontSizeXS,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                      _selectedPeriod = 'Tous';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.primary,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
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

  void _showCalendarFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CalendarFilterWidget(
          selectedStartDate: _startDate,
          selectedEndDate: _endDate,
          onDateRangeSelected: (startDate, endDate) {
            setState(() {
              _startDate = startDate;
              _endDate = endDate;
              _selectedPeriod = 'Période personnalisée';
            });
          },
        );
      },
    );
  }

  Widget _buildStatisticsOption() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingS),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.analytics, color: AppColors.primary, size: 20),
          const SizedBox(width: AppDimensions.spacingS),
          Expanded(
            child: Text(
              'Afficher les statistiques après filtrage',
              style: GoogleFonts.montserrat(
                fontSize: AppDimensions.fontSizeS,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Switch(
            value: _showStatisticsAfterFilter,
            onChanged: (value) {
              setState(() {
                _showStatisticsAfterFilter = value;
              });
            },
            activeColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withOpacity(0.3),
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      _selectedDeliveryType = 'Tous';
      _selectedStatus = 'Tous';
      _selectedPeriod = 'Tous';
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    final filteredColis = _filterColis();

    // Fermer le modal AVANT d'appeler le callback
    Navigator.of(context).pop();

    // Appeler le callback après la fermeture du modal
    widget.onFilterApplied(
      filteredColis,
      _selectedDeliveryType,
      _selectedStatus,
      _selectedPeriod,
      _startDate,
      _endDate,
      _showStatisticsAfterFilter,
    );
  }

  List<Colis> _filterColis() {
    return widget.allColis.where((colis) {
      // Filtre par type de livraison
      bool deliveryTypeMatch =
          _selectedDeliveryType == 'Tous' ||
          colis.modeLivraison.libelle == _selectedDeliveryType;

      // Filtre par statut
      bool statusMatch =
          _selectedStatus == 'Tous' ||
          _getStatusDisplayName(colis.status) == _selectedStatus;

      // Filtre par période
      bool periodMatch =
          _selectedPeriod == 'Tous' ||
          (_selectedPeriod == 'Période personnalisée' &&
              _isInCustomPeriod(colis.updatedAt)) ||
          _isInPeriod(colis.updatedAt, _selectedPeriod);

      return deliveryTypeMatch && statusMatch && periodMatch;
    }).toList();
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
}
