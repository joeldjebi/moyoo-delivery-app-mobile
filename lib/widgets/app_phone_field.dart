import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppPhoneField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;
  final void Function(bool)? onFocusChanged;
  final String countryCode;
  final String countryFlag;

  const AppPhoneField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.onFocusChanged,
    this.countryCode = '+225',
    this.countryFlag = '🇨🇮',
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      widget.onFocusChanged?.call(_focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
        ],
        Container(
          height: AppDimensions.fieldHeight + 20,
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: widget.onChanged,
            keyboardType: TextInputType.phone,
            enabled: widget.enabled,
            decoration: InputDecoration(
              hintText: widget.hintText ?? 'Entrez votre numéro de téléphone',
              hintStyle: GoogleFonts.montserrat(
                color: AppColors.textHint,
                fontSize: AppDimensions.fontSizeM,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(
                  color: AppColors.borderFocused,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.border, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                borderSide: const BorderSide(color: AppColors.error, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.fieldPaddingHorizontal,
                vertical: AppDimensions.fieldPaddingVertical,
              ),
              prefixIcon: Container(
                width: 75,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingS,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.countryFlag,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: AppDimensions.spacingXS),
                    Flexible(
                      child: Text(
                        widget.countryCode,
                        style: GoogleFonts.montserrat(
                          fontSize: AppDimensions.fontSizeS,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Widget pour valider les numéros de téléphone ivoiriens
class PhoneValidator {
  static String? validateIvorianPhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre numéro de téléphone';
    }

    // Supprimer les espaces et caractères spéciaux
    String cleanNumber = value.replaceAll(RegExp(r'[^\d]'), '');

    // Vérifier si le numéro nettoyé est vide
    if (cleanNumber.isEmpty) {
      return 'Veuillez entrer un numéro valide';
    }

    // Vérifier la longueur (numéros ivoiriens: 8 ou 10 chiffres après +225)
    if (cleanNumber.length < 8 || cleanNumber.length > 10) {
      return 'Le numéro doit contenir entre 8 et 10 chiffres';
    }

    // Vérifier que c'est bien un numéro ivoirien valide
    if (!RegExp(r'^(0[0-9]|[1-9][0-9])[0-9]{6,8}$').hasMatch(cleanNumber)) {
      return 'Format de numéro invalide';
    }

    return null;
  }

  // Formater le numéro complet avec l'indicatif
  static String formatFullNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) return '';
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    return '+225$cleanNumber';
  }
}
