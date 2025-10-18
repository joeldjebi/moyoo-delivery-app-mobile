import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_colors.dart';
import '../widgets/app_phone_field.dart';
import '../screens/login_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/reset_password_screen.dart';
import '../constants/api_constants.dart';
import 'auth_controller.dart';

class ForgotPasswordController extends GetxController {
  // Variables observables
  final _phoneNumber = ''.obs;
  final _otpCode = ''.obs;
  final _currentPassword = ''.obs;
  final _newPassword = ''.obs;
  final _confirmPassword = ''.obs;
  final _isLoading = false.obs;
  final _currentStep = 1.obs; // 1: Phone, 2: OTP, 3: New Password

  final baseUrl = ApiConstants.baseUrl;
  final changePasswordEndpoint = '/api/livreur/change-password';

  // Getters
  String get phoneNumber => _phoneNumber.value;
  String get fullPhoneNumber {
    if (_phoneNumber.value.isEmpty) return '';
    // Ajouter l'indication au numéro sans le signe '+'
    return '225${_phoneNumber.value}';
  }

  String get otpCode => _otpCode.value;
  String get currentPassword => _currentPassword.value;
  String get newPassword => _newPassword.value;
  String get confirmPassword => _confirmPassword.value;
  bool get isLoading => _isLoading.value;
  int get currentStep => _currentStep.value;

  // Setters
  void setPhoneNumber(String value) => _phoneNumber.value = value;
  void setOtpCode(String value) => _otpCode.value = value;
  void setCurrentPassword(String value) => _currentPassword.value = value;
  void setNewPassword(String value) => _newPassword.value = value;
  void setConfirmPassword(String value) => _confirmPassword.value = value;

  // Navigation entre les étapes
  void nextStep() {
    if (_currentStep.value < 3) {
      _currentStep.value++;
    }
  }

  void previousStep() {
    if (_currentStep.value > 1) {
      _currentStep.value--;
    }
  }

  void resetProcess() {
    _phoneNumber.value = '';
    _otpCode.value = '';
    _newPassword.value = '';
    _confirmPassword.value = '';
    _currentStep.value = 1;
  }

  // Validation
  String? validatePhoneNumber(String? value) {
    return PhoneValidator.validateIvorianPhone(value);
  }

  String? validateOtpCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer le code de vérification';
    }
    if (value.length != 4) {
      return 'Le code doit contenir 4 chiffres';
    }
    if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
      return 'Le code ne doit contenir que des chiffres';
    }
    return null;
  }

  String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre nouveau mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez confirmer votre mot de passe';
    }
    if (value != _newPassword.value) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  // Actions
  Future<void> sendOtpCode() async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre numéro de téléphone',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('🔍 Envoi du code OTP vers: $fullPhoneNumber');

      // Appel à l'API pour vérifier le numéro et envoyer l'OTP
      final response = await http.post(
        Uri.parse('$baseUrl/api/livreur/check-phone'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mobile': fullPhoneNumber}),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('✅ Code OTP envoyé avec succès');

        Get.snackbar(
          'Code envoyé',
          responseData['message'] ??
              'Un code de vérification a été envoyé à votre numéro',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarSuccess,
          colorText: Colors.white,
        );

        // Passer à l'étape suivante
        Get.to(() => const OtpVerificationScreen());
      } else {
        print('❌ Erreur lors de l\'envoi du code OTP');
        Get.snackbar(
          'Erreur',
          responseData['message'] ?? 'Erreur lors de l\'envoi du code',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de l\'envoi du code OTP: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de connexion. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> verifyOtpCode() async {
    if (otpCode.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer le code de vérification',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('🔍 Vérification du code OTP: $otpCode pour: $fullPhoneNumber');

      // Appel à l'API pour vérifier le code OTP
      final response = await http.post(
        Uri.parse('$baseUrl/api/livreur/verify-otp'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mobile': fullPhoneNumber, 'otp_code': otpCode}),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('✅ Code OTP vérifié avec succès');

        Get.snackbar(
          'Code vérifié',
          responseData['message'] ?? 'Code de vérification correct',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarSuccess,
          colorText: Colors.white,
        );

        // Passer à l'étape suivante
        Get.to(() => const ResetPasswordScreen());
      } else {
        print('❌ Code OTP incorrect');
        Get.snackbar(
          'Code incorrect',
          responseData['message'] ?? 'Le code de vérification est incorrect',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification du code OTP: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de connexion. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Erreur',
        'Les mots de passe ne correspondent pas',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('🔍 Mise à jour du mot de passe pour: $fullPhoneNumber');

      // Appel à l'API pour mettre à jour le mot de passe
      final response = await http.post(
        Uri.parse('$baseUrl/api/livreur/update-password'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'mobile': fullPhoneNumber,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('✅ Mot de passe mis à jour avec succès');

        Get.snackbar(
          'Succès',
          responseData['message'] ??
              'Votre mot de passe a été mis à jour avec succès',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarSuccess,
          colorText: Colors.white,
        );

        // Retourner à la page de connexion
        Get.offAll(() => const LoginScreen());
      } else {
        print('❌ Erreur lors de la mise à jour du mot de passe');
        Get.snackbar(
          'Erreur',
          responseData['message'] ??
              'Erreur lors de la mise à jour du mot de passe',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du mot de passe: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de connexion. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> changePassword() async {
    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez remplir tous les champs',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    if (newPassword != confirmPassword) {
      Get.snackbar(
        'Erreur',
        'Les mots de passe ne correspondent pas',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    try {
      print('🔍 Changement de mot de passe...');

      // Appel à l'API pour changer le mot de passe (avec token d'authentification)
      final response = await http.post(
        Uri.parse('$baseUrl/api/livreur/change-password'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${Get.find<AuthController>().authToken}',
          'X-CSRF-TOKEN': '',
        },
        body: jsonEncode({
          'current_password': currentPassword,
          'new_password': newPassword,
          'new_password_confirmation': confirmPassword,
        }),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('✅ Mot de passe changé avec succès');

        Get.snackbar(
          'Succès',
          responseData['message'] ??
              'Votre mot de passe a été changé avec succès',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarSuccess,
          colorText: Colors.white,
        );

        // Retourner au profil
        Get.back();
      } else {
        print('❌ Erreur lors du changement de mot de passe');
        Get.snackbar(
          'Erreur',
          responseData['message'] ??
              'Erreur lors du changement de mot de passe',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors du changement de mot de passe: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de connexion. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> resendOtpCode() async {
    _isLoading.value = true;

    try {
      print('🔍 Renvoi du code OTP vers: $fullPhoneNumber');

      // Appel à l'API pour renvoyer le code OTP
      final response = await http.post(
        Uri.parse('$baseUrl/api/livreur/resend-otp'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'mobile': fullPhoneNumber}),
      );

      print('🔍 Status Code: ${response.statusCode}');
      print('🔍 Response Body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        print('✅ Code OTP renvoyé avec succès');

        Get.snackbar(
          'Code renvoyé',
          responseData['message'] ??
              'Un nouveau code a été envoyé à votre numéro',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarInfo,
          colorText: Colors.white,
        );
      } else {
        print('❌ Erreur lors du renvoi du code OTP');
        Get.snackbar(
          'Erreur',
          responseData['message'] ?? 'Erreur lors du renvoi du code',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppColors.snackbarError,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('❌ Erreur lors du renvoi du code OTP: $e');
      Get.snackbar(
        'Erreur',
        'Erreur de connexion. Vérifiez votre connexion internet.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }
}
