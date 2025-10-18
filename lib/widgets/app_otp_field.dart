import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class AppOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool autoFocus;

  const AppOtpField({
    super.key,
    this.length = 4,
    this.onChanged,
    this.validator,
    this.autoFocus = true,
  });

  @override
  State<AppOtpField> createState() => AppOtpFieldState();
}

class AppOtpFieldState extends State<AppOtpField> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  String _otpCode = '';

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged() {
    _otpCode = _controllers.map((controller) => controller.text).join();
    widget.onChanged?.call(_otpCode);
  }

  void _onDigitChanged(String value, int index) {
    if (value.length == 1) {
      // Passer au champ suivant
      if (index < widget.length - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Dernier champ, perdre le focus
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty) {
      // Retourner au champ précédent
      if (index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
    _onChanged();
  }

  void _onKeyEvent(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace) {
        if (_controllers[index].text.isEmpty && index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.length,
        (index) => _buildDigitField(index),
      ),
    );
  }

  Widget _buildDigitField(int index) {
    return Container(
      width: 60,
      height: 60,
      child: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: (event) => _onKeyEvent(event, index),
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: 1,
          autofocus: widget.autoFocus && index == 0,
          style: GoogleFonts.montserrat(
            fontSize: AppDimensions.fontSizeXL,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusM),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingS,
              vertical: AppDimensions.spacingM,
            ),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onDigitChanged(value, index),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // Pas d'erreur individuelle, validation globale
            }
            return null;
          },
        ),
      ),
    );
  }

  String get otpCode => _otpCode;

  void clear() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _otpCode = '';
    _focusNodes[0].requestFocus();
  }

  bool validate() {
    return _otpCode.length == widget.length;
  }
}
