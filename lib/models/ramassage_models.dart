class RamassageResponse {
  final bool success;
  final String message;
  final List<Ramassage> data;
  final RamassageStatistiques? statistiques;

  RamassageResponse({
    required this.success,
    required this.message,
    required this.data,
    this.statistiques,
  });

  factory RamassageResponse.fromJson(Map<String, dynamic> json) {
    return RamassageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List?)?.map((e) => Ramassage.fromJson(e)).toList() ??
          [],
      statistiques:
          json['statistiques'] != null
              ? RamassageStatistiques.fromJson(json['statistiques'])
              : null,
    );
  }
}

class RamassageStatistiques {
  final int colisTermines;
  final int colisEnAttente;
  final int colisEnCours;
  final int colisAnnules;
  final int total;
  final int montantTotalEncaisse;

  RamassageStatistiques({
    required this.colisTermines,
    required this.colisEnAttente,
    required this.colisEnCours,
    required this.colisAnnules,
    required this.total,
    required this.montantTotalEncaisse,
  });

  factory RamassageStatistiques.fromJson(Map<String, dynamic> json) {
    return RamassageStatistiques(
      colisTermines: json['colis_termines'] ?? 0,
      colisEnAttente: json['colis_en_attente'] ?? 0,
      colisEnCours: json['colis_en_cours'] ?? 0,
      colisAnnules: json['colis_annules'] ?? 0,
      total: json['total'] ?? 0,
      montantTotalEncaisse: json['montant_total_encaisse'] ?? 0,
    );
  }
}

class Ramassage {
  final int id;
  final String codeRamassage;
  final int entrepriseId;
  final int marchandId;
  final int boutiqueId;
  final String dateDemande;
  final String datePlanifiee;
  final String? dateEffectuee;
  final String statut;
  final String adresseRamassage;
  final String contactRamassage;
  final int nombreColisEstime;
  final int nombreColisReel;
  final int? differenceColis;
  final String? typeDifference;
  final String? raisonDifference;
  final int? livreurId;
  final String? dateDebutRamassage;
  final String? dateFinRamassage;
  final String? photoRamassage;
  final String? notesLivreur;
  final String? notesRamassage;
  final String? notes;
  final String colisData;
  final String montantTotal;
  final String createdAt;
  final String updatedAt;
  final Marchand marchand;
  final Boutique boutique;
  final dynamic livreur;

  Ramassage({
    required this.id,
    required this.codeRamassage,
    required this.entrepriseId,
    required this.marchandId,
    required this.boutiqueId,
    required this.dateDemande,
    required this.datePlanifiee,
    this.dateEffectuee,
    required this.statut,
    required this.adresseRamassage,
    required this.contactRamassage,
    required this.nombreColisEstime,
    required this.nombreColisReel,
    this.differenceColis,
    this.typeDifference,
    this.raisonDifference,
    this.livreurId,
    this.dateDebutRamassage,
    this.dateFinRamassage,
    this.photoRamassage,
    this.notesLivreur,
    this.notesRamassage,
    this.notes,
    required this.colisData,
    required this.montantTotal,
    required this.createdAt,
    required this.updatedAt,
    required this.marchand,
    required this.boutique,
    this.livreur,
  });

  factory Ramassage.fromJson(Map<String, dynamic> json) {
    return Ramassage(
      id: json['id'] ?? 0,
      codeRamassage: json['code_ramassage'] ?? '',
      entrepriseId: json['entreprise_id'] ?? 0,
      marchandId: json['marchand_id'] ?? 0,
      boutiqueId: json['boutique_id'] ?? 0,
      dateDemande: json['date_demande'] ?? '',
      datePlanifiee: json['date_planifiee'] ?? '',
      dateEffectuee: json['date_effectuee'],
      statut: json['statut'] ?? '',
      adresseRamassage: json['adresse_ramassage'] ?? '',
      contactRamassage: json['contact_ramassage'] ?? '',
      nombreColisEstime: json['nombre_colis_estime'] ?? 0,
      nombreColisReel: json['nombre_colis_reel'] ?? 0,
      differenceColis: json['difference_colis'],
      typeDifference: json['type_difference'],
      raisonDifference: json['raison_difference'],
      livreurId: json['livreur_id'],
      dateDebutRamassage: json['date_debut_ramassage'],
      dateFinRamassage: json['date_fin_ramassage'],
      photoRamassage: json['photo_ramassage'],
      notesLivreur: json['notes_livreur'],
      notesRamassage: json['notes_ramassage'],
      notes: json['notes'],
      colisData: json['colis_data'] ?? '',
      montantTotal: json['montant_total'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      marchand: Marchand.fromJson(json['marchand'] ?? {}),
      boutique: Boutique.fromJson(json['boutique'] ?? {}),
      livreur: json['livreur'],
    );
  }
}

class Marchand {
  final int id;
  final int entrepriseId;
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final String adresse;
  final String status;
  final int communeId;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Marchand({
    required this.id,
    required this.entrepriseId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.adresse,
    required this.status,
    required this.communeId,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Marchand.fromJson(Map<String, dynamic> json) {
    return Marchand(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entrepriseId: int.tryParse(json['entreprise_id']?.toString() ?? '0') ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] ?? '',
      status: json['status'] ?? '',
      communeId: int.tryParse(json['commune_id']?.toString() ?? '0') ?? 0,
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  String get nomComplet => '$firstName $lastName';
}

class Boutique {
  final int id;
  final int entrepriseId;
  final String libelle;
  final String mobile;
  final String adresse;
  final String adresseGps;
  final String coverImage;
  final int marchandId;
  final String status;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Boutique({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.mobile,
    required this.adresse,
    required this.adresseGps,
    required this.coverImage,
    required this.marchandId,
    required this.status,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Boutique.fromJson(Map<String, dynamic> json) {
    return Boutique(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entrepriseId: int.tryParse(json['entreprise_id']?.toString() ?? '0') ?? 0,
      libelle: json['libelle'] ?? '',
      mobile: json['mobile'] ?? '',
      adresse: json['adresse'] ?? '',
      adresseGps: json['adresse_gps'] ?? '',
      coverImage: json['cover_image'] ?? '',
      marchandId: int.tryParse(json['marchand_id']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
