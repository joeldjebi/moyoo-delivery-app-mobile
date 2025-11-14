import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class CancelRamassageService {
  static const String _cancelRamassageEndpoint = '/api/livreur/ramassages';

  /// Annuler un ramassage
  static Future<CancelRamassageResponse> cancelRamassage({
    required int ramassageId,
    required String raison,
    required String commentaire,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '${ApiConstants.baseUrl}$_cancelRamassageEndpoint/$ramassageId/cancel',
      );

      final response = await http.post(
        url,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'raison': raison, 'commentaire': commentaire}),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CancelRamassageResponse.fromJson(responseData);
      } else {
        return CancelRamassageResponse(
          success: false,
          message:
              responseData['message'] ??
              'Erreur lors de l\'annulation du ramassage',
        );
      }
    } catch (e) {
      return CancelRamassageResponse(
        success: false,
        message: 'Erreur de connexion: $e',
      );
    }
  }
}

class CancelRamassageResponse {
  final bool success;
  final String message;
  final CancelRamassageData? data;

  CancelRamassageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CancelRamassageResponse.fromJson(Map<String, dynamic> json) {
    return CancelRamassageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? CancelRamassageData.fromJson(json['data'])
              : null,
    );
  }
}

class CancelRamassageData {
  final int id;
  final String statut;
  final String raisonAnnulation;
  final String dateAnnulation;

  CancelRamassageData({
    required this.id,
    required this.statut,
    required this.raisonAnnulation,
    required this.dateAnnulation,
  });

  factory CancelRamassageData.fromJson(Map<String, dynamic> json) {
    return CancelRamassageData(
      id: json['id'] ?? 0,
      statut: json['statut'] ?? '',
      raisonAnnulation: json['raison_annulation'] ?? '',
      dateAnnulation: json['date_annulation'] ?? '',
    );
  }
}
