class CompleteRamassageRequest {
  final int nombreColisReel;
  final String? notesRamassage;
  final String? raisonDifference;
  final List<String> photosColis; // Chemins des fichiers

  CompleteRamassageRequest({
    required this.nombreColisReel,
    this.notesRamassage,
    this.raisonDifference,
    required this.photosColis,
  });

  Map<String, dynamic> toJson() {
    return {
      'nombre_colis_reel': nombreColisReel,
      if (notesRamassage != null && notesRamassage!.isNotEmpty)
        'notes_ramassage': notesRamassage,
      if (raisonDifference != null && raisonDifference!.isNotEmpty)
        'raison_difference': raisonDifference,
    };
  }
}

class CompleteRamassageResponse {
  final bool success;
  final String message;

  CompleteRamassageResponse({required this.success, required this.message});

  factory CompleteRamassageResponse.fromJson(Map<String, dynamic> json) {
    return CompleteRamassageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class CompleteRamassageData {
  final int id;
  final String statut;
  final String dateEffectuee;
  final int nombreColisEstime;
  final int nombreColisReel;
  final List<PhotoColis> photosColis;
  final DifferenceInfo differenceInfo;

  CompleteRamassageData({
    required this.id,
    required this.statut,
    required this.dateEffectuee,
    required this.nombreColisEstime,
    required this.nombreColisReel,
    required this.photosColis,
    required this.differenceInfo,
  });

  factory CompleteRamassageData.fromJson(Map<String, dynamic> json) {
    return CompleteRamassageData(
      id: json['id'] ?? 0,
      statut: json['statut'] ?? '',
      dateEffectuee: json['date_effectuee'] ?? '',
      nombreColisEstime: json['nombre_colis_estime'] ?? 0,
      nombreColisReel: json['nombre_colis_reel'] ?? 0,
      photosColis:
          (json['photos_colis'] as List?)
              ?.map((e) => PhotoColis.fromJson(e))
              .toList() ??
          [],
      differenceInfo: DifferenceInfo.fromJson(json['difference_info'] ?? {}),
    );
  }
}

class PhotoColis {
  final String filename;
  final String url;
  final String path;

  PhotoColis({required this.filename, required this.url, required this.path});

  factory PhotoColis.fromJson(Map<String, dynamic> json) {
    return PhotoColis(
      filename: json['filename'] ?? '',
      url: json['url'] ?? '',
      path: json['path'] ?? '',
    );
  }
}

class DifferenceInfo {
  final int colisEstimes;
  final int colisReels;
  final int difference;
  final String typeDifference;
  final String raison;

  DifferenceInfo({
    required this.colisEstimes,
    required this.colisReels,
    required this.difference,
    required this.typeDifference,
    required this.raison,
  });

  factory DifferenceInfo.fromJson(Map<String, dynamic> json) {
    return DifferenceInfo(
      colisEstimes: json['colis_estimes'] ?? 0,
      colisReels: json['colis_reels'] ?? 0,
      difference: json['difference'] ?? 0,
      typeDifference: json['type_difference'] ?? '',
      raison: json['raison'] ?? '',
    );
  }
}
