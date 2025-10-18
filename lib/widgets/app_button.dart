import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

enum AppButtonType { primary, secondary, outline, success }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.width,
    this.height,
    this.icon,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppDimensions.buttonHeight;
    final buttonWidth = isFullWidth ? double.infinity : width;

    Widget buttonContent =
        isLoading
            ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
              ),
            )
            : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: AppDimensions.iconSizeM,
                    color: _getTextColor(),
                  ),
                  const SizedBox(width: AppDimensions.spacingS),
                ],
                Text(
                  text,
                  style: GoogleFonts.montserrat(
                    fontSize: AppDimensions.fontSizeS,
                    fontWeight: FontWeight.w500,
                    color: _getTextColor(),
                  ),
                ),
              ],
            );

    return SizedBox(
      height: buttonHeight,
      width: buttonWidth,
      child: _buildButton(buttonContent),
    );
  }

  Widget _buildButton(Widget child) {
    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.buttonPrimary,
            foregroundColor: AppColors.buttonSecondary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingHorizontal,
              vertical: AppDimensions.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            elevation: 0,
          ),
          child: child,
        );

      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingHorizontal,
              vertical: AppDimensions.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            elevation: 0,
          ),
          child: child,
        );

      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.textPrimary,
            side: const BorderSide(color: AppColors.border),
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingHorizontal,
              vertical: AppDimensions.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
          ),
          child: child,
        );

      case AppButtonType.success:
        return ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.buttonPaddingHorizontal,
              vertical: AppDimensions.buttonPaddingVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            ),
            elevation: 0,
          ),
          child: child,
        );
    }
  }

  Color _getTextColor() {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.buttonSecondary;
      case AppButtonType.secondary:
      case AppButtonType.outline:
        return AppColors.textPrimary;
      case AppButtonType.success:
        return Colors.white;
    }
  }
}

// Widget spécialisé pour les petits boutons
class AppSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;

  const AppSmallButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: text,
      onPressed: onPressed,
      type: type,
      isLoading: isLoading,
      height: AppDimensions.buttonHeightSmall,
      icon: icon,
      isFullWidth: false,
    );
  }
}
