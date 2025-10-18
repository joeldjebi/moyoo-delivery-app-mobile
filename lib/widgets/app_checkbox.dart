import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppCheckbox extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool?>? onChanged;
  final bool enabled;

  const AppCheckbox({
    super.key,
    required this.text,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: enabled ? onChanged : null,
          activeColor: AppColors.primary,
        ),
        Flexible(
          child: Text(
            text,
            style: GoogleFonts.montserrat(
              fontSize: AppDimensions.fontSizeS,
              color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
