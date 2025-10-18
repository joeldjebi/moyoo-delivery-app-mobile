// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:get/get.dart';
// import 'package:shimmer/shimmer.dart';
// import '../constants/app_colors.dart';
// import '../constants/app_dimensions.dart';
// import '../constants/api_constants.dart';
// import '../models/ramassage_detail_models.dart';
// import '../models/ramassage_models.dart';
// import '../services/ramassage_service.dart';
// import '../controllers/auth_controller.dart';
// import '../controllers/ramassage_controller.dart';
// import '../widgets/app_button.dart';
// import '../widgets/clickable_phone_widget.dart';
// import '../widgets/formatted_amount_widget.dart';
// import 'complete_ramassage_screen.dart';
// import 'ramassage_list_screen.dart';

// class RamassageDetailsScreen extends StatefulWidget {
//   final int ramassageId;
//   final String codeRamassage;

//   const RamassageDetailsScreen({
//     super.key,
//     required this.ramassageId,
//     required this.codeRamassage,
//   });

//   @override
//   State<RamassageDetailsScreen> createState() => _RamassageDetailsScreenState();
// }

// class _RamassageDetailsScreenState extends State<RamassageDetailsScreen> {
//   RamassageDetail? _ramassageDetail;
//   bool _isLoading = true;
//   String _errorMessage = '';
//   late RamassageController _ramassageController;

//   @override
//   void initState() {
//     super.initState();
//     _ramassageController = Get.find<RamassageController>();
//     _loadRamassageDetails();
//   }

//   Future<void> _loadRamassageDetails() async {
//     try {
//       setState(() {
//         _isLoading = true;
//         _errorMessage = '';
//       });

//       final authController = Get.find<AuthController>();
//       final token = authController.authToken;

//       if (token.isEmpty) {
//         setState(() {
//           _errorMessage = 'Token d\'authentification manquant';
//           _isLoading = false;
//         });
//         return;
//       }

//       final response = await RamassageService.getRamassageDetails(
//         widget.ramassageId,
//         token,
//       );

//       if (response.success) {
//         print('🔍 Ramassage details loaded successfully');
//         print('🔍 Ramassage statut: ${response.data.statut}');
//         print('🔍 Colis count: ${response.data.colisLies.length}');
//         print('🔍 Colis data string: ${response.data.colisData}');
        
//         // Debug pour les photos et notes
//         print('🔍 Photo ramassage: ${response.data.photoRamassage}');
//         print('🔍 Photo ramassage length: ${response.data.photoRamassage.length}');
//         print('🔍 Notes livreur: ${response.data.notesLivreur}');
//         print('🔍 Notes ramassage: ${response.data.notesRamassage}');
        
//         if (response.data.colisLies.isEmpty) {
//           print(
//             '⚠️ Aucun colis trouvé dans colisLies pour le statut: ${response.data.statut}',
//           );
//         } else {
//           for (int i = 0; i < response.data.colisLies.length; i++) {
//             final colis = response.data.colisLies[i];
//             print(
//               '🔍 Colis $i: ${colis.code} - ${colis.nomClient} - ${colis.montantAEncaisse}',
//             );
//           }
//         }
        
//         setState(() {
//           _ramassageDetail = response.data;
//           _isLoading = false;
//         });
//       } else {
//         setState(() {
//           _errorMessage = response.message;
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: _buildAppBar(),
//       body: _buildBody(),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.transparent,
//       elevation: 0,
//       flexibleSpace: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
//           ),
//         ),
//       ),
//       leading: Container(
//         margin: const EdgeInsets.all(AppDimensions.spacingS),
//         decoration: BoxDecoration(
//           color: Colors.white.withOpacity(0.2),
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
//           onPressed: () => Get.back(),
//           padding: const EdgeInsets.all(AppDimensions.spacingS),
//         ),
//       ),
//       title: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Détails du ramassage',
//             style: GoogleFonts.montserrat(
//               fontSize: AppDimensions.fontSizeM,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//             ),
//           ),
//           if (_ramassageDetail != null)
//             Text(
//               _ramassageDetail!.codeRamassage,
//               style: GoogleFonts.montserrat(
//                 fontSize: AppDimensions.fontSizeXS,
//                 fontWeight: FontWeight.w400,
//                 color: Colors.white.withOpacity(0.8),
//               ),
//             ),
//         ],
//       ),
//       actions: [
//         if (_ramassageDetail != null)
//           Container(
//             margin: const EdgeInsets.only(right: AppDimensions.spacingS),
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppDimensions.spacingS,
//               vertical: 4,
//             ),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(16),
//               border: Border.all(
//                 color: Colors.white.withOpacity(0.3),
//                 width: 1,
//               ),
//             ),
//             child: Text(
//               _getStatutFormatted(_ramassageDetail!.statut),
//               style: GoogleFonts.montserrat(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return _buildShimmerLoading();
//     }

//     if (_errorMessage.isNotEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
//             const SizedBox(height: AppDimensions.spacingM),
//             Text(
//               'Erreur de chargement',
//               style: GoogleFonts.montserrat(
//                 fontSize: AppDimensions.fontSizeM,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: AppDimensions.spacingS),
//             Text(
//               _errorMessage,
//               style: GoogleFonts.montserrat(
//                 fontSize: AppDimensions.fontSizeS,
//                 color: Colors.grey.shade500,
//               ),
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: AppDimensions.spacingM),
//             ElevatedButton(
//               onPressed: _loadRamassageDetails,
//               child: const Text('Réessayer'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_ramassageDetail == null) {
//       return const Center(child: Text('Aucune donnée disponible'));
//     }

//     return Stack(
//       children: [
//         RefreshIndicator(
//           onRefresh: _loadRamassageDetails,
//           child: CustomScrollView(
//             slivers: [
//               // Header avec informations principales
//               SliverToBoxAdapter(child: _buildHeaderCard()),

//               // Section des colis
//               SliverToBoxAdapter(
//                 child: Padding(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppDimensions.spacingM,
//                   ),
//                   child: _buildColisSectionHeader(),
//                 ),
//               ),

//               // Liste des colis (limité à 10)
//               SliverPadding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: AppDimensions.spacingM,
//                 ),
//                 sliver: SliverList(
//                   delegate: SliverChildBuilderDelegate((context, index) {
//                     final colis = _ramassageDetail!.colisLies[index];
//                     return _buildColisCard(colis, index);
//                   }, childCount: _getDisplayedColisCount()),
//                 ),
//               ),

//               // Section des photos des colis
//               if (_ramassageDetail!.photoRamassage.isNotEmpty) ...[
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppDimensions.spacingM,
//                       vertical: AppDimensions.spacingS,
//                     ),
//                     child: _buildPhotosSection(),
//                   ),
//                 ),
//               ] else ...[
//                 // Debug: Afficher pourquoi la section photos ne s'affiche pas
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppDimensions.spacingM,
//                       vertical: AppDimensions.spacingS,
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.all(AppDimensions.spacingS),
//                       decoration: BoxDecoration(
//                         color: AppColors.warning.withOpacity(0.1),
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(
//                           color: AppColors.warning.withOpacity(0.3),
//                           width: 1,
//                         ),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Debug: Aucune photo trouvée. photoRamassage.length = ${_ramassageDetail!.photoRamassage.length}',
//                             style: GoogleFonts.montserrat(
//                               fontSize: AppDimensions.fontSizeXS,
//                               color: AppColors.warning,
//                             ),
//                           ),
//                           if (_ramassageDetail!.notesLivreur != null && 
//                               _ramassageDetail!.notesLivreur!.isNotEmpty) ...[
//                             const SizedBox(height: AppDimensions.spacingXS),
//                             Text(
//                               'Notes livreur disponibles: ${_ramassageDetail!.notesLivreur!.length} caractères',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: AppDimensions.fontSizeXS,
//                                 color: AppColors.info,
//                               ),
//                             ),
//                           ],
//                           if (_ramassageDetail!.notesRamassage != null && 
//                               _ramassageDetail!.notesRamassage!.isNotEmpty) ...[
//                             const SizedBox(height: AppDimensions.spacingXS),
//                             Text(
//                               'Notes ramassage disponibles: ${_ramassageDetail!.notesRamassage!.length} caractères',
//                               style: GoogleFonts.montserrat(
//                                 fontSize: AppDimensions.fontSizeXS,
//                                 color: AppColors.info,
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],

//               // Section des notes (toujours affichée si disponibles)
//               if (_ramassageDetail!.notesLivreur != null && 
//                   _ramassageDetail!.notesLivreur!.isNotEmpty)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppDimensions.spacingM,
//                       vertical: AppDimensions.spacingS,
//                     ),
//                     child: _buildNotesSection(),
//                   ),
//                 ),

//               // Bouton "Voir plus" si nécessaire
//               if (_ramassageDetail!.colisLies.length > 10)
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: AppDimensions.spacingM,
//                       vertical: AppDimensions.spacingS,
//                     ),
//                     child: _buildVoirPlusButton(),
//                   ),
//                 ),

//               // Espace en bas pour le bouton fixe
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   height:
//                       (_ramassageDetail!.statut == 'planifie' ||
//                               _ramassageDetail!.statut == 'en_cours')
//                           ? 100
//                           : 20,
//                 ),
//               ),
//             ],
//           ),
//         ),

//         // Bouton fixe en bas
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: 0,
//           child: _buildFixedActionButton(),
//         ),
//       ],
//     );
//   }

//   Widget _buildHeaderCard() {
//     return Container(
//       margin: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header avec icône et titre
//           Container(
//             padding: const EdgeInsets.all(AppDimensions.spacingM),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primary.withOpacity(0.1),
//                   AppColors.primary.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.shopping_bag,
//                     color: Colors.white,
//                     size: 20,
//                   ),
//                 ),
//                 const SizedBox(width: AppDimensions.spacingS),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         _ramassageDetail!.boutique.libelle,
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeM,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(
//                         _ramassageDetail!.codeRamassage,
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeXS,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppDimensions.spacingS,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getStatutColor(
//                       _ramassageDetail!.statut,
//                     ).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(16),
//                     border: Border.all(
//                       color: _getStatutColor(_ramassageDetail!.statut),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     _getStatutFormatted(_ramassageDetail!.statut),
//                     style: GoogleFonts.montserrat(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: _getStatutColor(_ramassageDetail!.statut),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Informations principales
//           Padding(
//             padding: const EdgeInsets.all(AppDimensions.spacingM),
//             child: Column(
//               children: [
//                 _buildModernInfoRow(
//                   Icons.location_on,
//                   'Adresse',
//                   _ramassageDetail!.adresseRamassage,
//                 ),
//                 const SizedBox(height: AppDimensions.spacingS),
//                 _buildPhoneInfoRow(
//                   Icons.phone,
//                   'Contact',
//                   _ramassageDetail!.contactRamassage,
//                 ),
//                 const SizedBox(height: AppDimensions.spacingS),

//                 // Informations de dates
//                 _buildDateInfoRow(
//                   Icons.calendar_today,
//                   'Date de demande',
//                   _formatDate(_ramassageDetail!.dateDemande),
//                 ),
//                 const SizedBox(height: AppDimensions.spacingS),
//                 _buildDateInfoRow(
//                   Icons.schedule,
//                   'Date planifiée',
//                   _formatDate(_ramassageDetail!.datePlanifiee),
//                 ),
//                 if (_ramassageDetail!.dateEffectuee != null) ...[
//                   const SizedBox(height: AppDimensions.spacingS),
//                   _buildDateInfoRow(
//                     Icons.check_circle,
//                     'Date effectuée',
//                     _formatDate(_ramassageDetail!.dateEffectuee!),
//                   ),
//                 ],
//                 const SizedBox(height: AppDimensions.spacingS),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         Icons.inventory_2,
//                         'Colis',
//                         '${_ramassageDetail!.nombreColisEstime}',
//                         AppColors.info,
//                       ),
//                     ),
//                     const SizedBox(width: AppDimensions.spacingS),
//                     Expanded(
//                       child: _buildStatCardWithFormattedAmount(
//                         Icons.attach_money,
//                         'Montant',
//                         _ramassageDetail!.montantTotal,
//                         AppColors.success,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (_ramassageDetail!.notes != null &&
//                     _ramassageDetail!.notes!.isNotEmpty) ...[
//                   const SizedBox(height: AppDimensions.spacingS),
//                   _buildNotesCard(),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildModernInfoRow(IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(icon, size: 16, color: AppColors.primary),
//           ),
//           const SizedBox(width: AppDimensions.spacingS),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   value,
//                   style: GoogleFonts.montserrat(
//                     fontSize: AppDimensions.fontSizeXS,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPhoneInfoRow(IconData icon, String label, String phoneNumber) {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: AppColors.primary.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(icon, size: 16, color: AppColors.primary),
//           ),
//           const SizedBox(width: AppDimensions.spacingS),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   label,
//                   style: GoogleFonts.montserrat(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 PhoneNumberCard(phoneNumber: phoneNumber, icon: Icons.phone),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     IconData icon,
//     String label,
//     String value,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 4),
//           Text(
//             value,
//             style: GoogleFonts.montserrat(
//               fontSize: AppDimensions.fontSizeS,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//           ),
//           const SizedBox(height: 1),
//           Text(
//             label,
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatCardWithFormattedAmount(
//     IconData icon,
//     String label,
//     String amount,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 20),
//           const SizedBox(height: 4),
//           AmountCard(
//             amount: amount,
//             currency: 'F',
//             textColor: color,
//             fontSize: AppDimensions.fontSizeS,
//             fontWeight: FontWeight.w700,
//           ),
//           const SizedBox(height: 1),
//           Text(
//             label,
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNotesCard() {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: AppColors.warning.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: AppColors.warning.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(
//               color: AppColors.warning.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: const Icon(Icons.note, size: 16, color: AppColors.warning),
//           ),
//           const SizedBox(width: AppDimensions.spacingS),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Notes',
//                   style: GoogleFonts.montserrat(
//                     fontSize: 10,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//                 const SizedBox(height: 1),
//                 Text(
//                   _ramassageDetail!.notes!,
//                   style: GoogleFonts.montserrat(
//                     fontSize: AppDimensions.fontSizeXS,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisCard(ColisLie colis, int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header du colis
//           Container(
//             padding: const EdgeInsets.all(AppDimensions.spacingS),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//                 colors: [
//                   AppColors.primary.withOpacity(0.1),
//                   AppColors.primary.withOpacity(0.05),
//                 ],
//               ),
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(6),
//                   decoration: BoxDecoration(
//                     color: AppColors.primary,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Text(
//                     '${index + 1}',
//                     style: GoogleFonts.montserrat(
//                       fontSize: AppDimensions.fontSizeXS,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: AppDimensions.spacingS),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         colis.code,
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeS,
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.textPrimary,
//                         ),
//                       ),
//                       const SizedBox(height: 1),
//                       Text(
//                         colis.nomClient,
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeXS,
//                           fontWeight: FontWeight.w500,
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: AppDimensions.spacingS,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: _getColisStatutColor(colis.status).withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(10),
//                     border: Border.all(
//                       color: _getColisStatutColor(colis.status),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     colis.statutFormatted,
//                     style: GoogleFonts.montserrat(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: _getColisStatutColor(colis.status),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Contenu du colis
//           Padding(
//             padding: const EdgeInsets.all(AppDimensions.spacingS),
//             child: Column(
//               children: [
//                 _buildColisPhoneRow(
//                   Icons.phone,
//                   'Téléphone',
//                   colis.telephoneClient,
//                 ),
//                 const SizedBox(height: 6),
//                 _buildColisDetailRow(
//                   Icons.location_on,
//                   'Adresse',
//                   colis.adresseClient,
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildColisStatCardWithFormattedAmount(
//                         Icons.attach_money,
//                         'Montant',
//                         colis.montantAEncaisse.toString(),
//                         AppColors.success,
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: _buildColisStatCard(
//                         Icons.receipt,
//                         'Facture',
//                         colis.numeroFacture,
//                         AppColors.primary,
//                       ),
//                     ),
//                   ],
//                 ),
//                 if (colis.noteClient != null &&
//                     colis.noteClient!.isNotEmpty) ...[
//                   const SizedBox(height: 6),
//                   _buildColisNoteCard(colis.noteClient!),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisDetailRow(IconData icon, String label, String value) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: AppColors.textSecondary),
//           const SizedBox(width: 6),
//           Text(
//             '$label:',
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.montserrat(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w600,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisPhoneRow(IconData icon, String label, String phoneNumber) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: AppColors.textSecondary),
//           const SizedBox(width: 6),
//           Text(
//             '$label:',
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//           ),
//           const SizedBox(width: 6),
//           Expanded(
//             child: PhoneNumberListItem(
//               phoneNumber: phoneNumber,
//               icon: Icons.phone,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisStatCard(
//     IconData icon,
//     String label,
//     String value,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 14),
//           const SizedBox(height: 3),
//           Text(
//             value,
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               fontWeight: FontWeight.w700,
//               color: color,
//             ),
//             textAlign: TextAlign.center,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 1),
//           Text(
//             label,
//             style: GoogleFonts.montserrat(
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisStatCardWithFormattedAmount(
//     IconData icon,
//     String label,
//     String amount,
//     Color color,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Column(
//         children: [
//           Icon(icon, color: color, size: 14),
//           const SizedBox(height: 3),
//           AmountListItem(
//             amount: amount,
//             currency: 'F',
//             textColor: color,
//             fontSize: 10,
//             fontWeight: FontWeight.w700,
//           ),
//           const SizedBox(height: 1),
//           Text(
//             label,
//             style: GoogleFonts.montserrat(
//               fontSize: 9,
//               fontWeight: FontWeight.w500,
//               color: AppColors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildColisNoteCard(String note) {
//     return Container(
//       padding: const EdgeInsets.all(6),
//       decoration: BoxDecoration(
//         color: AppColors.warning.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: AppColors.warning.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.note, size: 14, color: AppColors.warning),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               note,
//               style: GoogleFonts.montserrat(
//                 fontSize: 10,
//                 fontWeight: FontWeight.w500,
//                 color: AppColors.textPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatutColor(String statut) {
//     switch (statut.toLowerCase()) {
//       case 'planifie':
//         return AppColors.warning;
//       case 'en_cours':
//         return AppColors.primary;
//       case 'termine':
//         return AppColors.success;
//       case 'annule':
//         return AppColors.error;
//       default:
//         return AppColors.textSecondary;
//     }
//   }

//   String _getStatutFormatted(String statut) {
//     switch (statut.toLowerCase()) {
//       case 'planifie':
//         return 'Planifié';
//       case 'en_cours':
//         return 'En cours';
//       case 'termine':
//         return 'Terminé';
//       case 'annule':
//         return 'Annulé';
//       default:
//         return statut;
//     }
//   }

//   Color _getColisStatutColor(int status) {
//     switch (status) {
//       case 0:
//         return AppColors.warning;
//       case 1:
//         return AppColors.primary;
//       case 2:
//         return AppColors.success;
//       case 3:
//         return AppColors.error;
//       default:
//         return AppColors.textSecondary;
//     }
//   }

//   Widget _buildShimmerLoading() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppDimensions.spacingM),
//         child: Column(
//           children: [
//             // Shimmer pour la carte header
//             _buildShimmerHeaderCard(),
//             const SizedBox(height: AppDimensions.spacingL),

//             // Shimmer pour l'en-tête de section
//             _buildShimmerSectionHeader(),
//             const SizedBox(height: AppDimensions.spacingM),

//             // Shimmer pour les cartes de colis
//             ...List.generate(3, (index) => _buildShimmerColisCard(index)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildShimmerHeaderCard() {
//     return Container(
//       margin: const EdgeInsets.all(AppDimensions.spacingS),
//       padding: const EdgeInsets.all(AppDimensions.spacingM),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 15,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header shimmer
//           Row(
//             children: [
//               Container(
//                 width: 40,
//                 height: 40,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               const SizedBox(width: AppDimensions.spacingS),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: double.infinity,
//                       height: 20,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Container(
//                       width: 120,
//                       height: 14,
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade300,
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 width: 60,
//                 height: 24,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppDimensions.spacingM),

//           // Informations shimmer
//           Container(
//             width: double.infinity,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingS),
//           Container(
//             width: double.infinity,
//             height: 50,
//             decoration: BoxDecoration(
//               color: Colors.grey.shade300,
//               borderRadius: BorderRadius.circular(10),
//             ),
//           ),
//           const SizedBox(height: AppDimensions.spacingS),

//           // Cartes statistiques shimmer
//           Row(
//             children: [
//               Expanded(
//                 child: Container(
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: AppDimensions.spacingS),
//               Expanded(
//                 child: Container(
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildShimmerSectionHeader() {
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(6),
//           ),
//         ),
//         const SizedBox(width: AppDimensions.spacingS),
//         Container(
//           width: 150,
//           height: 20,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(4),
//           ),
//         ),
//         const Spacer(),
//         Container(
//           width: 30,
//           height: 20,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade300,
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildShimmerColisCard(int index) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: AppDimensions.spacingS),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           // Header shimmer
//           Container(
//             padding: const EdgeInsets.all(AppDimensions.spacingS),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade200,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 const SizedBox(width: AppDimensions.spacingS),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         width: double.infinity,
//                         height: 16,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 2),
//                       Container(
//                         width: 100,
//                         height: 12,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Container(
//                   width: 50,
//                   height: 20,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ],
//             ),
//           ),

//           // Contenu shimmer
//           Padding(
//             padding: const EdgeInsets.all(AppDimensions.spacingS),
//             child: Column(
//               children: [
//                 Container(
//                   width: double.infinity,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Container(
//                   width: double.infinity,
//                   height: 30,
//                   decoration: BoxDecoration(
//                     color: Colors.grey.shade300,
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Container(
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 6),
//                     Expanded(
//                       child: Container(
//                         height: 50,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.shade300,
//                           borderRadius: BorderRadius.circular(6),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFixedActionButton() {
//     if (_ramassageDetail == null) {
//       return const SizedBox.shrink();
//     }

//     // Aucun bouton pour les ramassages terminés ou autres statuts
//     if (_ramassageDetail!.statut != 'planifie' &&
//         _ramassageDetail!.statut != 'en_cours') {
//       return const SizedBox.shrink();
//     }

//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingM),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: SafeArea(
//         child:
//             _ramassageDetail!.statut == 'planifie'
//                 ? AppButton(
//                   text: 'Démarrer le ramassage',
//                   onPressed: _startRamassage,
//                   type: AppButtonType.primary,
//                   icon: Icons.play_arrow,
//                   isFullWidth: true,
//                 )
//                 : AppButton(
//                   text: 'Terminer le ramassage',
//                   onPressed: _finishPickup,
//                   type: AppButtonType.primary,
//                   icon: Icons.check_circle,
//                   isFullWidth: true,
//                 ),
//       ),
//     );
//   }

//   void _startRamassage() async {
//     final confirmed = await Get.dialog<bool>(
//       AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         title: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(6),
//               decoration: BoxDecoration(
//                 color: AppColors.primary.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(6),
//               ),
//               child: const Icon(
//                 Icons.play_arrow,
//                 color: AppColors.primary,
//                 size: 20,
//               ),
//             ),
//             const SizedBox(width: AppDimensions.spacingS),
//             Text(
//               'Démarrer le ramassage',
//               style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
//             ),
//           ],
//         ),
//         content: Text(
//           'Êtes-vous sûr de vouloir démarrer le ramassage ${_ramassageDetail!.codeRamassage} ?',
//           style: GoogleFonts.montserrat(),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Get.back(result: false),
//             child: Text(
//               'Annuler',
//               style: GoogleFonts.montserrat(color: AppColors.textSecondary),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Get.back(result: true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(6),
//               ),
//             ),
//             child: Text(
//               'Démarrer',
//               style: GoogleFonts.montserrat(fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );

//     if (confirmed == true) {
//       // Démarrer le ramassage
//       final success = await _ramassageController.startRamassage(
//         _ramassageDetail!.id,
//       );

//       if (success) {
//         Get.snackbar(
//           '📦 Ramassage démarré',
//           'Vous avez commencé le ramassage ${_ramassageDetail!.codeRamassage}',
//           backgroundColor: AppColors.success,
//           colorText: Colors.white,
//           icon: const Icon(Icons.check_circle, color: Colors.white),
//           snackPosition: SnackPosition.TOP,
//           duration: const Duration(seconds: 3),
//         );

//         // Recharger les détails pour mettre à jour le statut
//         _loadRamassageDetails();
//       } else {
//         Get.snackbar(
//           '❌ Erreur',
//           _ramassageController.errorMessage,
//           backgroundColor: AppColors.error,
//           colorText: Colors.white,
//           icon: const Icon(Icons.error, color: Colors.white),
//           snackPosition: SnackPosition.TOP,
//           duration: const Duration(seconds: 3),
//       );
//     }
//   }

//   /// Construire la section des notes
//   Widget _buildNotesSection() {
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingM),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête de la section
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.info,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.note,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: AppDimensions.spacingS),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Notes du ramassage',
//                       style: GoogleFonts.montserrat(
//                         fontSize: AppDimensions.fontSizeS,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       'Informations détaillées',
//                       style: GoogleFonts.montserrat(
//                         fontSize: AppDimensions.fontSizeXS,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppDimensions.spacingM),

//           // Notes du livreur
//           if (_ramassageDetail!.notesLivreur != null && 
//               _ramassageDetail!.notesLivreur!.isNotEmpty) ...[
//             Container(
//               padding: const EdgeInsets.all(AppDimensions.spacingS),
//               decoration: BoxDecoration(
//                 color: AppColors.info.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: AppColors.info.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.person,
//                         size: 14,
//                         color: AppColors.info,
//                       ),
//                       const SizedBox(width: AppDimensions.spacingXS),
//                       Text(
//                         'Notes du livreur',
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeXS,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.info,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: AppDimensions.spacingXS),
//                   Text(
//                     _ramassageDetail!.notesLivreur!,
//                     style: GoogleFonts.montserrat(
//                       fontSize: AppDimensions.fontSizeXS,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: AppDimensions.spacingS),
//           ],

//           // Notes du ramassage
//           if (_ramassageDetail!.notesRamassage != null && 
//               _ramassageDetail!.notesRamassage!.isNotEmpty) ...[
//             Container(
//               padding: const EdgeInsets.all(AppDimensions.spacingS),
//               decoration: BoxDecoration(
//                 color: AppColors.success.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: AppColors.success.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.shopping_bag,
//                         size: 14,
//                         color: AppColors.success,
//                       ),
//                       const SizedBox(width: AppDimensions.spacingXS),
//                       Text(
//                         'Notes du ramassage',
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeXS,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.success,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: AppDimensions.spacingXS),
//                   Text(
//                     _ramassageDetail!.notesRamassage!,
//                     style: GoogleFonts.montserrat(
//                       fontSize: AppDimensions.fontSizeXS,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Future<void> _finishPickup() async {
//     if (_ramassageDetail == null) return;

//     // Créer un objet Ramassage temporaire avec les données disponibles
//     final ramassage = Ramassage(
//       id: _ramassageDetail!.id,
//       codeRamassage: _ramassageDetail!.codeRamassage,
//       entrepriseId: _ramassageDetail!.entrepriseId,
//       marchandId: _ramassageDetail!.marchandId,
//       boutiqueId: _ramassageDetail!.boutiqueId,
//       dateDemande: _ramassageDetail!.dateDemande,
//       datePlanifiee: _ramassageDetail!.datePlanifiee,
//       dateEffectuee: _ramassageDetail!.dateEffectuee,
//       statut: _ramassageDetail!.statut,
//       adresseRamassage: _ramassageDetail!.adresseRamassage,
//       contactRamassage: _ramassageDetail!.contactRamassage,
//       nombreColisEstime: _ramassageDetail!.nombreColisEstime,
//       nombreColisReel: _ramassageDetail!.nombreColisReel,
//       differenceColis: _ramassageDetail!.differenceColis,
//       typeDifference: _ramassageDetail!.typeDifference,
//       raisonDifference: _ramassageDetail!.raisonDifference,
//       livreurId: _ramassageDetail!.livreurId,
//       dateDebutRamassage: _ramassageDetail!.dateDebutRamassage,
//       dateFinRamassage: _ramassageDetail!.dateFinRamassage,
//       photoRamassage:
//           _ramassageDetail!.photoRamassage.isNotEmpty
//               ? _ramassageDetail!.photoRamassage.first
//               : null,
//       notesLivreur: _ramassageDetail!.notesLivreur,
//       notesRamassage: _ramassageDetail!.notesRamassage,
//       notes: _ramassageDetail!.notes,
//       colisData: _ramassageDetail!.colisData,
//       montantTotal: _ramassageDetail!.montantTotal,
//       createdAt: _ramassageDetail!.createdAt,
//       updatedAt: _ramassageDetail!.updatedAt,
//       marchand: _ramassageDetail!.marchand,
//       boutique: _ramassageDetail!.boutique,
//       livreur: _ramassageDetail!.livreur,
//     );

//     // Naviguer vers l'écran de finalisation
//     final result = await Get.to(
//       () => CompleteRamassageScreen(ramassage: ramassage),
//     );

//     // Si la finalisation a réussi, recharger les détails
//     if (result == true) {
//       await _loadRamassageDetails();
//     }
//   }

//   /// Obtenir le nombre de colis à afficher (maximum 10)
//   int _getDisplayedColisCount() {
//     if (_ramassageDetail == null) return 0;
//     return _ramassageDetail!.colisLies.length > 10
//         ? 10
//         : _ramassageDetail!.colisLies.length;
//   }

//   /// Construire le bouton "Voir plus"
//   Widget _buildVoirPlusButton() {
//     final totalColis = _ramassageDetail?.colisLies.length ?? 0;
//     final displayedColis = _getDisplayedColisCount();
//     final remainingColis = totalColis - displayedColis;

//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//         border: Border.all(color: AppColors.primary.withOpacity(0.3)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Material(
//         color: Colors.transparent,
//         child: InkWell(
//           onTap: _navigateToRamassageList,
//           borderRadius: BorderRadius.circular(AppDimensions.radiusM),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: AppDimensions.spacingM,
//               vertical: AppDimensions.spacingM,
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.list_alt, color: AppColors.primary, size: 20),
//                 const SizedBox(width: AppDimensions.spacingS),
//                 Text(
//                   'Voir plus ($remainingColis colis restants)',
//                   style: GoogleFonts.montserrat(
//                     fontSize: AppDimensions.fontSizeS,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.primary,
//                   ),
//                 ),
//                 const SizedBox(width: AppDimensions.spacingS),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   color: AppColors.primary,
//                   size: 16,
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Naviguer vers la liste complète des ramassages
//   void _navigateToRamassageList() {
//     Get.to(() => const RamassageListScreen());
//   }

//   /// Construire une ligne d'information pour les dates
//   Widget _buildDateInfoRow(IconData icon, String label, String value) {
//     return Row(
//       children: [
//         Container(
//           width: 32,
//           height: 32,
//           decoration: BoxDecoration(
//             color: AppColors.primary.withOpacity(0.1),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Icon(icon, size: 16, color: AppColors.primary),
//         ),
//         const SizedBox(width: AppDimensions.spacingS),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: GoogleFonts.montserrat(
//                   fontSize: AppDimensions.fontSizeXS,
//                   fontWeight: FontWeight.w500,
//                   color: AppColors.textSecondary,
//                 ),
//               ),
//               const SizedBox(height: 1),
//               Text(
//                 value,
//                 style: GoogleFonts.montserrat(
//                   fontSize: 11,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   /// Formater une date ISO en format lisible
//   String _formatDate(String dateString) {
//     try {
//       final date = DateTime.parse(dateString);
//       final now = DateTime.now();
//       final difference = now.difference(date).inDays;

//       // Format de base
//       final formattedDate =
//           '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
//       final formattedTime =
//           '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

//       // Ajouter un indicateur relatif
//       String relativeIndicator = '';
//       if (difference == 0) {
//         relativeIndicator = ' (Aujourd\'hui)';
//       } else if (difference == 1) {
//         relativeIndicator = ' (Hier)';
//       } else if (difference > 1 && difference <= 7) {
//         relativeIndicator = ' (Il y a $difference jours)';
//       } else if (difference < 0) {
//         final futureDays = -difference;
//         if (futureDays == 1) {
//           relativeIndicator = ' (Demain)';
//         } else {
//           relativeIndicator = ' (Dans $futureDays jours)';
//         }
//       }

//       return '$formattedDate à $formattedTime$relativeIndicator';
//     } catch (e) {
//       return dateString; // Retourner la chaîne originale en cas d'erreur
//     }
//   }

//   /// Construire l'en-tête de la section des colis
//   Widget _buildColisSectionHeader() {
//     final colisCount = _ramassageDetail?.colisLies.length ?? 0;

//     return Container(
//       padding: const EdgeInsets.symmetric(
//         horizontal: AppDimensions.spacingM,
//         vertical: AppDimensions.spacingS,
//       ),
//       decoration: BoxDecoration(
//         color: AppColors.primary.withOpacity(0.05),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppColors.primary.withOpacity(0.1), width: 1),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: AppColors.primary,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: const Icon(Icons.inventory_2, color: Colors.white, size: 16),
//           ),
//           const SizedBox(width: AppDimensions.spacingS),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Colis du ramassage',
//                   style: GoogleFonts.montserrat(
//                     fontSize: AppDimensions.fontSizeS,
//                     fontWeight: FontWeight.w600,
//                     color: AppColors.textPrimary,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   colisCount > 0
//                       ? '$colisCount colis trouvé${colisCount > 1 ? 's' : ''}'
//                       : 'Aucun colis trouvé',
//                   style: GoogleFonts.montserrat(
//                     fontSize: AppDimensions.fontSizeXS,
//                     fontWeight: FontWeight.w500,
//                     color:
//                         colisCount > 0 ? AppColors.success : AppColors.warning,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (colisCount == 0)
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: AppDimensions.spacingS,
//                 vertical: 4,
//               ),
//               decoration: BoxDecoration(
//                 color: AppColors.warning.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: AppColors.warning.withOpacity(0.3),
//                   width: 1,
//                 ),
//               ),
//               child: Text(
//                 'Debug',
//                 style: GoogleFonts.montserrat(
//                   fontSize: 10,
//                   fontWeight: FontWeight.w600,
//                   color: AppColors.warning,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   /// Construire la section des photos des colis
//   Widget _buildPhotosSection() {
//     print('🔍 Building photos section with ${_ramassageDetail!.photoRamassage.length} photos');
//     print('🔍 Photos: ${_ramassageDetail!.photoRamassage}');
//     print('🔍 Notes livreur: ${_ramassageDetail!.notesLivreur}');
    
//     return Container(
//       padding: const EdgeInsets.all(AppDimensions.spacingM),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // En-tête de la section
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: AppColors.primary,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Icon(
//                   Icons.photo_library,
//                   color: Colors.white,
//                   size: 16,
//                 ),
//               ),
//               const SizedBox(width: AppDimensions.spacingS),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Photos des colis',
//                       style: GoogleFonts.montserrat(
//                         fontSize: AppDimensions.fontSizeS,
//                         fontWeight: FontWeight.w600,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//                     Text(
//                       '${_ramassageDetail!.photoRamassage.length} photo${_ramassageDetail!.photoRamassage.length > 1 ? 's' : ''}',
//                       style: GoogleFonts.montserrat(
//                         fontSize: AppDimensions.fontSizeXS,
//                         fontWeight: FontWeight.w500,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: AppDimensions.spacingM),

//           // Grille des photos
//           GridView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//               crossAxisCount: 2,
//               crossAxisSpacing: AppDimensions.spacingS,
//               mainAxisSpacing: AppDimensions.spacingS,
//               childAspectRatio: 1.2,
//             ),
//             itemCount: _ramassageDetail!.photoRamassage.length,
//             itemBuilder: (context, index) {
//               final photoPath = _ramassageDetail!.photoRamassage[index];
//               return _buildPhotoCard(photoPath, index);
//             },
//           ),

//           // Notes du livreur si disponibles
//           if (_ramassageDetail!.notesLivreur != null &&
//               _ramassageDetail!.notesLivreur!.isNotEmpty) ...[
//             const SizedBox(height: AppDimensions.spacingM),
//             Container(
//               padding: const EdgeInsets.all(AppDimensions.spacingS),
//               decoration: BoxDecoration(
//                 color: AppColors.info.withOpacity(0.05),
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: AppColors.info.withOpacity(0.2),
//                   width: 1,
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       const Icon(Icons.note, size: 14, color: AppColors.info),
//                       const SizedBox(width: AppDimensions.spacingXS),
//                       Text(
//                         'Notes du livreur',
//                         style: GoogleFonts.montserrat(
//                           fontSize: AppDimensions.fontSizeXS,
//                           fontWeight: FontWeight.w600,
//                           color: AppColors.info,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: AppDimensions.spacingXS),
//                   Text(
//                     _ramassageDetail!.notesLivreur!,
//                     style: GoogleFonts.montserrat(
//                       fontSize: AppDimensions.fontSizeXS,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   /// Construire une carte de photo
//   Widget _buildPhotoCard(String photoPath, int index) {
//     return GestureDetector(
//       onTap: () => _showPhotoDialog(photoPath),
//       child: Container(
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//           border: Border.all(color: Colors.grey.shade300, width: 1),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: Stack(
//             children: [
//               // Image
//               Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 color: Colors.grey.shade100,
//                 child: _buildPhotoWidget(photoPath),
//               ),
//               // Overlay avec numéro
//               Positioned(
//                 top: 4,
//                 right: 4,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 6,
//                     vertical: 2,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.6),
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   child: Text(
//                     '${index + 1}',
//                     style: GoogleFonts.montserrat(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// Construire le widget de photo
//   Widget _buildPhotoWidget(String photoPath) {
//     // Si c'est une URL complète
//     if (photoPath.startsWith('http')) {
//       return Image.network(
//         photoPath,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildPhotoError();
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return _buildPhotoLoading();
//         },
//       );
//     } else {
//       // Si c'est un chemin relatif, construire l'URL complète
//       final fullUrl = '${ApiConstants.baseUrl}/storage/$photoPath';
//       return Image.network(
//         fullUrl,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return _buildPhotoError();
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return _buildPhotoLoading();
//         },
//       );
//     }
//   }

//   /// Widget d'erreur pour les photos
//   Widget _buildPhotoError() {
//     return Container(
//       color: Colors.grey.shade200,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.broken_image, size: 24, color: Colors.grey.shade400),
//           const SizedBox(height: 4),
//           Text(
//             'Erreur',
//             style: GoogleFonts.montserrat(
//               fontSize: 10,
//               color: Colors.grey.shade600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// Widget de chargement pour les photos
//   Widget _buildPhotoLoading() {
//     return Container(
//       color: Colors.grey.shade200,
//       child: const Center(
//         child: SizedBox(
//           width: 20,
//           height: 20,
//           child: CircularProgressIndicator(
//             strokeWidth: 2,
//             valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
//           ),
//         ),
//       ),
//     );
//   }

//   /// Afficher la photo en plein écran
//   void _showPhotoDialog(String photoPath) {
//     final fullUrl =
//         photoPath.startsWith('http')
//             ? photoPath
//             : '${ApiConstants.baseUrl}/storage/$photoPath';

//     showDialog(
//       context: context,
//       builder:
//           (context) => Dialog(
//             backgroundColor: Colors.transparent,
//             child: Stack(
//               children: [
//                 // Image en plein écran
//                 Center(
//                   child: InteractiveViewer(
//                     child: Image.network(
//                       fullUrl,
//                       fit: BoxFit.contain,
//                       errorBuilder: (context, error, stackTrace) {
//                         return Container(
//                           padding: const EdgeInsets.all(20),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.broken_image,
//                                 size: 48,
//                                 color: Colors.grey.shade400,
//                               ),
//                               const SizedBox(height: 16),
//                               Text(
//                                 'Impossible de charger l\'image',
//                                 style: GoogleFonts.montserrat(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//                 // Bouton de fermeture
//                 Positioned(
//                   top: 40,
//                   right: 20,
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: Colors.black.withOpacity(0.6),
//                       shape: BoxShape.circle,
//                     ),
//                     child: IconButton(
//                       icon: const Icon(
//                         Icons.close,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                       onPressed: () => Navigator.of(context).pop(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//     );
//   }
// }
