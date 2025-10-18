// Modèles pour l'authentification
class LoginRequest {
  final String mobile;
  final String password;

  LoginRequest({required this.mobile, required this.password});

  Map<String, dynamic> toJson() {
    return {'mobile': mobile, 'password': password};
  }
}

class LoginResponse {
  final bool success;
  final String message;
  final AuthData data;

  LoginResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: AuthData.fromJson(json['data'] ?? {}),
    );
  }
}

class AuthData {
  final String token;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final int refreshExpiresIn;
  final Livreur livreur;

  AuthData({
    required this.token,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.refreshExpiresIn,
    required this.livreur,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'bearer',
      expiresIn: json['expires_in'] ?? 0,
      refreshExpiresIn: json['refresh_expires_in'] ?? 0,
      livreur: Livreur.fromJson(json['livreur'] ?? {}),
    );
  }
}

class ZoneActivite {
  final int id;
  final String libelle;

  ZoneActivite({required this.id, required this.libelle});

  factory ZoneActivite.fromJson(Map<String, dynamic> json) {
    return ZoneActivite(id: json['id'] ?? 0, libelle: json['libelle'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'libelle': libelle};
  }
}

class Livreur {
  final int id;
  final String nomComplet;
  final String? firstName;
  final String? lastName;
  final String mobile;
  final String? email;
  final String? adresse;
  final String? permis;
  final String status;
  final String? photo;
  final Engin? engin;
  final ZoneActivite? zoneActivite;
  final List<Commune>? communes;
  final String? createdAt;
  final String? updatedAt;

  Livreur({
    required this.id,
    required this.nomComplet,
    this.firstName,
    this.lastName,
    required this.mobile,
    this.email,
    this.adresse,
    this.permis,
    required this.status,
    this.photo,
    this.engin,
    this.zoneActivite,
    this.communes,
    this.createdAt,
    this.updatedAt,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'] ?? 0,
      nomComplet: json['nom_complet'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      mobile: json['mobile'] ?? '',
      email: json['email'],
      adresse: json['adresse'],
      permis: json['permis'],
      status: json['status'] ?? '',
      photo: json['photo'],
      engin: json['engin'] != null ? Engin.fromJson(json['engin']) : null,
      zoneActivite:
          json['zone_activite'] != null
              ? ZoneActivite.fromJson(json['zone_activite'])
              : null,
      communes:
          json['communes'] != null
              ? (json['communes'] as List)
                  .map((e) => Commune.fromJson(e))
                  .toList()
              : null,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom_complet': nomComplet,
      'first_name': firstName,
      'last_name': lastName,
      'mobile': mobile,
      'email': email,
      'adresse': adresse,
      'permis': permis,
      'status': status,
      'photo': photo,
      'engin': engin?.toJson(),
      'zone_activite': zoneActivite?.toJson(),
      'communes': communes?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}

class Engin {
  final int id;
  final String? nom;
  final String type;

  Engin({required this.id, this.nom, required this.type});

  factory Engin.fromJson(Map<String, dynamic> json) {
    return Engin(
      id: json['id'] ?? 0,
      nom: json['nom'],
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'nom': nom, 'type': type};
  }
}

class Commune {
  final int id;
  final String libelle;

  Commune({required this.id, required this.libelle});

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(id: json['id'] ?? 0, libelle: json['libelle'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'libelle': libelle};
  }
}

class ApiError {
  final String message;
  final int? statusCode;
  final String? error;

  ApiError({required this.message, this.statusCode, this.error});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      message: json['message'] ?? 'Une erreur est survenue',
      statusCode: json['status_code'],
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'ApiError(message: $message, statusCode: $statusCode, error: $error)';
  }
}
