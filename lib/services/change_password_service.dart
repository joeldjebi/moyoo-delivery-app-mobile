import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../constants/api_constants.dart';
import '../models/change_password_models.dart';
import '../controllers/auth_controller.dart';

class ChangePasswordService {
  static final ChangePasswordService _instance =
      ChangePasswordService._internal();
  factory ChangePasswordService() => _instance;
  ChangePasswordService._internal();

  /// Changer le mot de passe du livreur
  Future<ChangePasswordResponse> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      print('🔐 Changement de mot de passe...');

      // Vérifier l'authentification
      final authController = Get.find<AuthController>();
      final token = authController.authToken;
      if (token.isEmpty) {
        return ChangePasswordResponse(
          success: false,
          message: 'Token d\'authentification non trouvé',
        );
      }

      // Préparer la requête
      final request = ChangePasswordRequest(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );

      print('🔐 Envoi de la requête de changement de mot de passe...');
      print('🔐 URL: ${ApiConstants.baseUrl}/api/livreur/change-password');

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}/api/livreur/change-password'),
            headers: {
              'accept': 'application/json',
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
              'X-CSRF-TOKEN': '',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Timeout: La requête a pris trop de temps');
            },
          );

      print('🔐 Réponse reçue: ${response.statusCode}');
      print('🔐 Corps de la réponse: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final changePasswordResponse = ChangePasswordResponse.fromJson(
          responseData,
        );

        if (changePasswordResponse.success) {
          print('✅ Mot de passe changé avec succès');
        } else {
          print(
            '❌ Échec du changement de mot de passe: ${changePasswordResponse.message}',
          );
        }

        return changePasswordResponse;
      } else if (response.statusCode == 401) {
        print('❌ Token d\'authentification invalide');
        return ChangePasswordResponse(
          success: false,
          message: 'Session expirée. Veuillez vous reconnecter.',
        );
      } else if (response.statusCode == 422) {
        // Erreurs de validation
        final responseData = jsonDecode(response.body);
        final errors = responseData['errors'] ?? {};
        String errorMessage = 'Erreur de validation';

        if (errors['current_password'] != null) {
          errorMessage = errors['current_password'][0];
        } else if (errors['new_password'] != null) {
          errorMessage = errors['new_password'][0];
        } else if (errors['new_password_confirmation'] != null) {
          errorMessage = errors['new_password_confirmation'][0];
        }

        print('❌ Erreur de validation: $errorMessage');
        return ChangePasswordResponse(success: false, message: errorMessage);
      } else {
        print('❌ Erreur serveur: ${response.statusCode}');
        return ChangePasswordResponse(
          success: false,
          message: 'Erreur serveur. Veuillez réessayer.',
        );
      }
    } catch (e) {
      print('❌ Erreur lors du changement de mot de passe: $e');
      return ChangePasswordResponse(
        success: false,
        message: 'Erreur de connexion. Vérifiez votre connexion internet.',
      );
    }
  }
}
