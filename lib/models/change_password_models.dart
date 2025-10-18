class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;
  final String newPasswordConfirmation;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
    required this.newPasswordConfirmation,
  });

  Map<String, dynamic> toJson() {
    return {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': newPasswordConfirmation,
    };
  }
}

class ChangePasswordResponse {
  final bool success;
  final String message;
  final ChangePasswordData? data;

  ChangePasswordResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChangePasswordResponse.fromJson(Map<String, dynamic> json) {
    return ChangePasswordResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? ChangePasswordData.fromJson(json['data'])
              : null,
    );
  }
}

class ChangePasswordData {
  final String? message;

  ChangePasswordData({this.message});

  factory ChangePasswordData.fromJson(Map<String, dynamic> json) {
    return ChangePasswordData(message: json['message']);
  }
}
