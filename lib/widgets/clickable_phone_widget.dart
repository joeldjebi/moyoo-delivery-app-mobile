import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class ClickablePhoneWidget extends StatelessWidget {
  final String phoneNumber;
  final String? label;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool showIcon;
  final EdgeInsets? padding;
  final bool enableCopy;

  const ClickablePhoneWidget({
    super.key,
    required this.phoneNumber,
    this.label,
    this.icon,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.fontWeight,
    this.showIcon = true,
    this.padding,
    this.enableCopy = true,
  });

  @override
  Widget build(BuildContext context) {
    final formattedNumber = _formatPhoneNumber(phoneNumber);
    final displayText =
        label != null ? '$label: $formattedNumber' : formattedNumber;

    return GestureDetector(
      onTap: () => _handlePhoneTap(context),
      onLongPress: enableCopy ? () => _copyToClipboard(context) : null,
      child: Text(
        displayText,
        style: GoogleFonts.montserrat(
          fontSize: fontSize ?? AppDimensions.fontSizeXS,
          fontWeight: fontWeight ?? FontWeight.w600,
          color: textColor ?? AppColors.textPrimary,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  /// Formater le numéro de téléphone avec des séparateurs
  String _formatPhoneNumber(String number) {
    // Nettoyer le numéro (enlever les espaces, tirets, etc.)
    String cleanNumber = number.replaceAll(RegExp(r'[^\d+]'), '');

    // Si le numéro commence par +225, formater comme un numéro ivoirien
    if (cleanNumber.startsWith('+225')) {
      final localNumber = cleanNumber.substring(4);
      if (localNumber.length == 8) {
        // Format: +225 XX XX XX XX
        return '+225 ${localNumber.substring(0, 2)} ${localNumber.substring(2, 4)} ${localNumber.substring(4, 6)} ${localNumber.substring(6, 8)}';
      }
    }

    // Si le numéro commence par 225, ajouter le +
    if (cleanNumber.startsWith('225')) {
      final localNumber = cleanNumber.substring(3);
      if (localNumber.length == 8) {
        // Format: +225 XX XX XX XX
        return '+225 ${localNumber.substring(0, 2)} ${localNumber.substring(2, 4)} ${localNumber.substring(4, 6)} ${localNumber.substring(6, 8)}';
      }
    }

    // Si c'est un numéro local de 8 chiffres, ajouter +225
    if (cleanNumber.length == 8 && !cleanNumber.startsWith('+')) {
      // Format: +225 XX XX XX XX
      return '+225 ${cleanNumber.substring(0, 2)} ${cleanNumber.substring(2, 4)} ${cleanNumber.substring(4, 6)} ${cleanNumber.substring(6, 8)}';
    }

    // Pour les autres formats, retourner tel quel
    return number;
  }

  /// Gérer le tap sur le numéro
  Future<void> _handlePhoneTap(BuildContext context) async {
    try {
      // Nettoyer le numéro pour l'URL
      String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

      // S'assurer que le numéro commence par +
      if (!cleanNumber.startsWith('+')) {
        if (cleanNumber.startsWith('225')) {
          cleanNumber = '+$cleanNumber';
        } else if (cleanNumber.length == 8) {
          cleanNumber = '+225$cleanNumber';
        } else {
          cleanNumber = '+$cleanNumber';
        }
      }

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _showErrorSnackbar('Impossible d\'ouvrir l\'application téléphone');
      }
    } catch (e) {
      _showErrorSnackbar('Erreur lors de l\'appel: $e');
    }
  }

  /// Copier le numéro dans le presse-papiers
  void _copyToClipboard(BuildContext context) {
    Clipboard.setData(ClipboardData(text: phoneNumber));
    Get.snackbar(
      '📋 Numéro copié',
      'Le numéro $phoneNumber a été copié dans le presse-papiers',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      icon: const Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 2),
    );
  }

  /// Afficher un message d'erreur
  void _showErrorSnackbar(String message) {
    Get.snackbar(
      '❌ Erreur',
      message,
      backgroundColor: AppColors.error,
      colorText: Colors.white,
      icon: const Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }
}

/// Widget spécialisé pour les numéros de téléphone dans les cartes
class PhoneNumberCard extends StatelessWidget {
  final String phoneNumber;
  final String? label;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const PhoneNumberCard({
    super.key,
    required this.phoneNumber,
    this.label,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClickablePhoneWidget(
      phoneNumber: phoneNumber,
      label: label,
      icon: icon,
      textColor: textColor ?? AppColors.textPrimary,
      iconColor: iconColor ?? AppColors.textSecondary,
      fontSize: AppDimensions.fontSizeXS,
      fontWeight: FontWeight.w600,
      showIcon: false,
      enableCopy: true,
    );
  }
}

/// Widget pour les numéros de téléphone dans les listes
class PhoneNumberListItem extends StatelessWidget {
  final String phoneNumber;
  final String? label;
  final IconData? icon;
  final Color? textColor;
  final Color? iconColor;

  const PhoneNumberListItem({
    super.key,
    required this.phoneNumber,
    this.label,
    this.icon,
    this.textColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClickablePhoneWidget(
      phoneNumber: phoneNumber,
      label: label,
      icon: icon,
      textColor: textColor ?? AppColors.textPrimary,
      iconColor: iconColor ?? AppColors.textSecondary,
      fontSize: AppDimensions.fontSizeXS,
      fontWeight: FontWeight.w600,
      showIcon: false,
      enableCopy: true,
    );
  }
}
