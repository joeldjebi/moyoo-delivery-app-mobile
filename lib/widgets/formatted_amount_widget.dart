import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class FormattedAmountWidget extends StatelessWidget {
  final String amount;
  final String? currency;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final bool showCurrency;

  const FormattedAmountWidget({
    super.key,
    required this.amount,
    this.currency,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.showCurrency = true,
  });

  @override
  Widget build(BuildContext context) {
    final formattedAmount = _formatAmount(amount);
    final displayText =
        showCurrency && currency != null
            ? '$formattedAmount $currency'
            : formattedAmount;

    return Text(
      displayText,
      style: GoogleFonts.montserrat(
        fontSize: fontSize ?? AppDimensions.fontSizeS,
        fontWeight: fontWeight ?? FontWeight.w600,
        color: textColor ?? AppColors.textPrimary,
      ),
      textAlign: textAlign,
    );
  }

  /// Formater le montant avec des séparateurs de milliers
  String _formatAmount(String amount) {
    try {
      // Nettoyer le montant (enlever les espaces, virgules, etc.)
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.]'), '');

      // Convertir en double
      double value = double.parse(cleanAmount);

      // Formater avec des séparateurs de milliers
      String formatted = value.toStringAsFixed(0);

      // Ajouter des espaces comme séparateurs de milliers
      String result = '';
      int count = 0;

      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ' ' + result;
          count = 0;
        }
        result = formatted[i] + result;
        count++;
      }

      return result;
    } catch (e) {
      // En cas d'erreur, retourner le montant original
      return amount;
    }
  }
}

/// Widget spécialisé pour les montants dans les cartes
class AmountCard extends StatelessWidget {
  final String amount;
  final String? currency;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AmountCard({
    super.key,
    required this.amount,
    this.currency,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedAmountWidget(
      amount: amount,
      currency: currency ?? 'F',
      textColor: textColor ?? AppColors.success,
      fontSize: fontSize ?? AppDimensions.fontSizeS,
      fontWeight: fontWeight ?? FontWeight.w700,
      showCurrency: true,
    );
  }
}

/// Widget pour les montants dans les listes
class AmountListItem extends StatelessWidget {
  final String amount;
  final String? currency;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AmountListItem({
    super.key,
    required this.amount,
    this.currency,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedAmountWidget(
      amount: amount,
      currency: currency ?? 'F',
      textColor: textColor ?? AppColors.textPrimary,
      fontSize: fontSize ?? AppDimensions.fontSizeXS,
      fontWeight: fontWeight ?? FontWeight.w600,
      showCurrency: true,
    );
  }
}

/// Widget pour les montants dans les statistiques
class AmountStat extends StatelessWidget {
  final String amount;
  final String? currency;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AmountStat({
    super.key,
    required this.amount,
    this.currency,
    this.textColor,
    this.fontSize,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    return FormattedAmountWidget(
      amount: amount,
      currency: currency ?? 'F',
      textColor: textColor ?? AppColors.success,
      fontSize: fontSize ?? AppDimensions.fontSizeM,
      fontWeight: fontWeight ?? FontWeight.w700,
      showCurrency: true,
    );
  }
}

/// Extension pour formater facilement les montants
extension AmountFormatter on String {
  String get formattedAmount {
    try {
      String cleanAmount = replaceAll(RegExp(r'[^\d.]'), '');
      double value = double.parse(cleanAmount);
      String formatted = value.toStringAsFixed(0);

      String result = '';
      int count = 0;

      for (int i = formatted.length - 1; i >= 0; i--) {
        if (count == 3) {
          result = ' ' + result;
          count = 0;
        }
        result = formatted[i] + result;
        count++;
      }

      return result;
    } catch (e) {
      return this;
    }
  }
}
