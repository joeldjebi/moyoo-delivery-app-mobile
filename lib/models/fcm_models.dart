class FcmTokenResponse {
  final bool success;
  final String message;
  final FcmTokenData? data;

  FcmTokenResponse({required this.success, required this.message, this.data});

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? FcmTokenData.fromJson(json['data']) : null,
    );
  }
}

class FcmTokenData {
  final int livreurId;
  final String fcmToken;
  final String updatedAt;

  FcmTokenData({
    required this.livreurId,
    required this.fcmToken,
    required this.updatedAt,
  });

  factory FcmTokenData.fromJson(Map<String, dynamic> json) {
    return FcmTokenData(
      livreurId: json['livreur_id'] ?? 0,
      fcmToken: json['fcm_token'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class FcmTokenRequest {
  final String fcmToken;
  final String deviceType;

  FcmTokenRequest({required this.fcmToken, required this.deviceType});

  Map<String, dynamic> toJson() {
    return {'fcm_token': fcmToken, 'device_type': deviceType};
  }
}
