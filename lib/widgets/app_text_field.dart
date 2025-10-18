import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppTextField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool enabled;
  final int? maxLines;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  final bool readOnly;
  final VoidCallback? onTap;

  const AppTextField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeM,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingS),
        ],
        Container(
          height: maxLines == 1 ? AppDimensions.fieldHeight + 20 : null,
          child: TextFormField(
            controller: controller,
            validator: validator,
            onChanged: onChanged,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            maxLines: maxLines,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            readOnly: readOnly,
            onTap: onTap,
            decoration: InputDecoration(
              hintText: hintText,
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
              suffixIcon: suffixIcon,
              prefixIcon: prefixIcon,
            ),
          ),
        ),
      ],
    );
  }
}

// Widget spécialisé pour les champs de mot de passe
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppPasswordField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField> {
  bool _isPasswordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      validator: widget.validator,
      onChanged: widget.onChanged,
      obscureText: !_isPasswordVisible,
      enabled: widget.enabled,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          color: AppColors.iconSecondary,
          size: AppDimensions.iconSizeM,
        ),
        onPressed: _togglePasswordVisibility,
      ),
    );
  }
}

// Widget spécialisé pour les champs email
class AppEmailField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const AppEmailField({
    super.key,
    this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: TextInputType.emailAddress,
      enabled: enabled,
      prefixIcon: const Icon(
        Icons.email_outlined,
        color: AppColors.iconSecondary,
        size: AppDimensions.iconSizeM,
      ),
    );
  }
}
