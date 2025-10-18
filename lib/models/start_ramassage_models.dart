class StartRamassageResponse {
  final bool success;
  final String message;
  final StartRamassageData data;

  StartRamassageResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StartRamassageResponse.fromJson(Map<String, dynamic> json) {
    return StartRamassageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Erreur inconnue',
      data: StartRamassageData.fromJson(json['data']),
    );
  }
}

class StartRamassageData {
  final int id;
  final String statut;

  StartRamassageData({required this.id, required this.statut});

  factory StartRamassageData.fromJson(Map<String, dynamic> json) {
    return StartRamassageData(
      id: json['id'] ?? 0,
      statut: json['statut'] ?? '',
    );
  }
}
