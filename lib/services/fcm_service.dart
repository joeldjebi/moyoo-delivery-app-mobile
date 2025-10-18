import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../models/fcm_models.dart';

class FcmService {
  static const String _fcmTokenEndpoint = '/api/livreur/fcm-token';

  /// Enregistrer le token FCM et le type de device
  static Future<FcmTokenResponse> registerFcmToken({
    required String fcmToken,
    required String authToken,
  }) async {
    try {
      // Détecter le type de device
      final deviceType = Platform.isIOS ? 'ios' : 'android';

      final request = FcmTokenRequest(
        fcmToken: fcmToken,
        deviceType: deviceType,
      );

      final response = await http
          .post(
            Uri.parse('${ApiConstants.baseUrl}$_fcmTokenEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
            },
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 30));

      print('🔍 FCM Service - Status: ${response.statusCode}');
      print('🔍 FCM Service - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return FcmTokenResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        return FcmTokenResponse(
          success: false,
          message:
              errorData['message'] ??
              'Erreur lors de l\'enregistrement du token FCM',
        );
      }
    } catch (e) {
      print('❌ Erreur FCM Service: $e');
      return FcmTokenResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }

  /// Supprimer le token FCM du serveur
  static Future<FcmTokenResponse> deleteFcmToken({
    required String authToken,
  }) async {
    try {
      final response = await http
          .delete(
            Uri.parse('${ApiConstants.baseUrl}$_fcmTokenEndpoint'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $authToken',
              'Accept': 'application/json',
              'X-CSRF-TOKEN': '',
            },
          )
          .timeout(const Duration(seconds: 30));

      print('🔍 FCM Service DELETE - Status: ${response.statusCode}');
      print('🔍 FCM Service DELETE - Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return FcmTokenResponse.fromJson(responseData);
      } else {
        final errorData = jsonDecode(response.body);
        return FcmTokenResponse(
          success: false,
          message:
              errorData['message'] ??
              'Erreur lors de la suppression du token FCM',
        );
      }
    } catch (e) {
      print('❌ Erreur FCM Service DELETE: $e');
      return FcmTokenResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}
