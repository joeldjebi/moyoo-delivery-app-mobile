import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../widgets/app_phone_field.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/dashboard_screen.dart';
import 'auth_controller.dart';

class LoginController extends GetxController {
  // Variables observables
  final _phoneNumber = ''.obs;
  final _password = ''.obs;
  final _isPasswordVisible = false.obs;
  final _rememberMe = false.obs;
  final _isLoading = false.obs;
  final _currentStep = 1.obs; // 1: Phone, 2: Password
  final _isPhoneFieldFocused = false.obs;
  final _errorMessage = ''.obs;

  // Référence au contrôleur d'authentification
  late AuthController _authController;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
  }

  // Getters
  String get phoneNumber => _phoneNumber.value;
  String get fullPhoneNumber {
    if (_phoneNumber.value.isEmpty) return '';
    // Ajouter l'indication au numéro sans le signe '+'
    return '225${_phoneNumber.value}';
  }

  String get password => _password.value;
  bool get isPasswordVisible => _isPasswordVisible.value;
  bool get rememberMe => _rememberMe.value;
  bool get isLoading => _isLoading.value;
  int get currentStep => _currentStep.value;
  bool get isPhoneFieldFocused => _isPhoneFieldFocused.value;
  String get errorMessage => _errorMessage.value;

  // Setters
  void setPhoneNumber(String value) => _phoneNumber.value = value;
  void setPassword(String value) {
    _password.value = value;
    // Effacer le message d'erreur quand l'utilisateur tape
    if (_errorMessage.value.isNotEmpty) {
      _errorMessage.value = '';
    }
  }

  void togglePasswordVisibility() =>
      _isPasswordVisible.value = !_isPasswordVisible.value;
  void setRememberMe(bool value) => _rememberMe.value = value;
  void nextStep() => _currentStep.value = 2;
  void previousStep() => _currentStep.value = 1;
  void setPhoneFieldFocus(bool isFocused) =>
      _isPhoneFieldFocused.value = isFocused;

  // Validation
  String? validatePhoneNumber(String? value) {
    return PhoneValidator.validateIvorianPhone(value);
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  // Actions
  Future<void> validatePhoneAndContinue() async {
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

    if (validatePhoneNumber(phoneNumber) != null) {
      Get.snackbar(
        'Erreur',
        validatePhoneNumber(phoneNumber)!,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
      return;
    }

    // Simuler la vérification du numéro
    _isLoading.value = true;
    try {
      await Future.delayed(const Duration(seconds: 1));

      // Passer à l'étape suivante (sans message de succès)
      nextStep();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur lors de la vérification: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> login() async {
    // Effacer le message d'erreur précédent
    _errorMessage.value = '';

    if (phoneNumber.isEmpty || password.isEmpty) {
      _errorMessage.value = 'Veuillez remplir tous les champs';
      return;
    }

    _isLoading.value = true;

    try {
      // Appel à l'API d'authentification
      final success = await _authController.login(
        mobile: fullPhoneNumber, // Envoyer le numéro avec l'indication 225
        password: password,
      );

      if (success) {
        // Succès de la connexion - redirection vers le tableau de bord
        Get.offAllNamed('/dashboard');
      } else {
        // Définir le message d'erreur retourné par l'API
        _errorMessage.value = _authController.errorMessage;
      }
    } catch (e) {
      _errorMessage.value = 'Erreur de connexion: ${e.toString()}';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> loginWithFaceID() async {
    _isLoading.value = true;

    try {
      // Simuler l'authentification Face ID
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Succès',
        'Connexion Face ID réussie !',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarSuccess,
        colorText: Colors.white,
      );

      // Redirection vers le tableau de bord
      Get.offAll(() => const DashboardScreen());
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Erreur Face ID: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.snackbarError,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void forgotPassword() {
    Get.to(() => const ForgotPasswordScreen());
  }
}
