class DeliveryResponse {
  final bool success;
  final String message;
  final List<Colis> data;
  final DeliveryStatistiques statistiques;

  DeliveryResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.statistiques,
  });

  factory DeliveryResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => Colis.fromJson(item))
              .toList() ??
          [],
      statistiques: DeliveryStatistiques.fromJson(json['statistiques'] ?? {}),
    );
  }
}

class Colis {
  final int id;
  final int entrepriseId;
  final int packageColisId;
  final String uuid;
  final String code;
  final int status;
  final String nomClient;
  final String telephoneClient;
  final String adresseClient;
  final int montantAEncaisse;
  final int prixDeVente;
  final String numeroFacture;
  final String noteClient;
  final String? instructionsLivraison;
  final int zoneId;
  final int communeId;
  final int? ordreLivraison;
  final String? dateLivraisonPrevue;
  final int livreurId;
  final int enginId;
  final int poidsId;
  final int modeLivraisonId;
  final int tempId;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final Commune commune;
  final Livraison livraison;
  final PackageColis packageColis;
  final Livreur livreur;
  final Engin engin;
  final Poids poids;
  final ModeLivraison modeLivraison;
  final Temp temp;

  Colis({
    required this.id,
    required this.entrepriseId,
    required this.packageColisId,
    required this.uuid,
    required this.code,
    required this.status,
    required this.nomClient,
    required this.telephoneClient,
    required this.adresseClient,
    required this.montantAEncaisse,
    required this.prixDeVente,
    required this.numeroFacture,
    required this.noteClient,
    this.instructionsLivraison,
    required this.zoneId,
    required this.communeId,
    this.ordreLivraison,
    this.dateLivraisonPrevue,
    required this.livreurId,
    required this.enginId,
    required this.poidsId,
    required this.modeLivraisonId,
    required this.tempId,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.commune,
    required this.livraison,
    required this.packageColis,
    required this.livreur,
    required this.engin,
    required this.poids,
    required this.modeLivraison,
    required this.temp,
  });

  factory Colis.fromJson(Map<String, dynamic> json) {
    return Colis(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      packageColisId: json['package_colis_id'] ?? 0,
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      status: json['status'] ?? 0,
      nomClient: json['nom_client'] ?? '',
      telephoneClient: json['telephone_client'] ?? '',
      adresseClient: json['adresse_client'] ?? '',
      montantAEncaisse: json['montant_a_encaisse'] ?? 0,
      prixDeVente: json['prix_de_vente'] ?? 0,
      numeroFacture: json['numero_facture'] ?? '',
      noteClient: json['note_client'] ?? '',
      instructionsLivraison: json['instructions_livraison'],
      zoneId: json['zone_id'] ?? 0,
      communeId: json['commune_id'] ?? 0,
      ordreLivraison: json['ordre_livraison'],
      dateLivraisonPrevue: json['date_livraison_prevue'],
      livreurId: json['livreur_id'] ?? 0,
      enginId: json['engin_id'] ?? 0,
      poidsId: json['poids_id'] ?? 0,
      modeLivraisonId: json['mode_livraison_id'] ?? 0,
      tempId: json['temp_id'] ?? 0,
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      commune: Commune.fromJson(json['commune'] ?? {}),
      livraison: Livraison.fromJson(json['livraison'] ?? {}),
      packageColis: PackageColis.fromJson(json['package_colis'] ?? {}),
      livreur: Livreur.fromJson(json['livreur'] ?? {}),
      engin: Engin.fromJson(json['engin'] ?? {}),
      poids: Poids.fromJson(json['poids'] ?? {}),
      modeLivraison: ModeLivraison.fromJson(json['mode_livraison'] ?? {}),
      temp: Temp.fromJson(json['temp'] ?? {}),
    );
  }

  // Méthodes utilitaires
  String get statutFormatted {
    switch (status) {
      case 0:
        return 'En attente';
      case 1:
        return 'En cours';
      case 2:
        return 'Livré';
      case 3:
        return 'Annulé';
      case 4:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }

  bool get isEnAttente => status == 0;
  bool get isEnCours => status == 1;
  bool get isLivre => status == 2;
  bool get isAnnule => status == 3;
}

class Commune {
  final int id;
  final int entrepriseId;
  final String libelle;
  final int villeId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Commune({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.villeId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      villeId: json['ville_id'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Livraison {
  final int id;
  final int entrepriseId;
  final String uuid;
  final String numeroDeLivraison;
  final int colisId;
  final int packageColisId;
  final int marchandId;
  final int boutiqueId;
  final String adresseDeLivraison;
  final int status;
  final String? noteLivraison;
  final String codeValidation;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Livraison({
    required this.id,
    required this.entrepriseId,
    required this.uuid,
    required this.numeroDeLivraison,
    required this.colisId,
    required this.packageColisId,
    required this.marchandId,
    required this.boutiqueId,
    required this.adresseDeLivraison,
    required this.status,
    this.noteLivraison,
    required this.codeValidation,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Livraison.fromJson(Map<String, dynamic> json) {
    return Livraison(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      uuid: json['uuid'] ?? '',
      numeroDeLivraison: json['numero_de_livraison'] ?? '',
      colisId: json['colis_id'] ?? 0,
      packageColisId: json['package_colis_id'] ?? 0,
      marchandId: json['marchand_id'] ?? 0,
      boutiqueId: json['boutique_id'] ?? 0,
      adresseDeLivraison: json['adresse_de_livraison'] ?? '',
      status: json['status'] ?? 0,
      noteLivraison: json['note_livraison'],
      codeValidation: json['code_validation'] ?? '',
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class PackageColis {
  final int id;
  final int entrepriseId;
  final String numeroPackage;
  final int marchandId;
  final int boutiqueId;
  final int nombreColis;
  final List<String> communesSelected;
  final List<int> colisIds;
  final int livreurId;
  final int enginId;
  final String statut;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  PackageColis({
    required this.id,
    required this.entrepriseId,
    required this.numeroPackage,
    required this.marchandId,
    required this.boutiqueId,
    required this.nombreColis,
    required this.communesSelected,
    required this.colisIds,
    required this.livreurId,
    required this.enginId,
    required this.statut,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PackageColis.fromJson(Map<String, dynamic> json) {
    return PackageColis(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      numeroPackage: json['numero_package'] ?? '',
      marchandId: json['marchand_id'] ?? 0,
      boutiqueId: json['boutique_id'] ?? 0,
      nombreColis: json['nombre_colis'] ?? 0,
      communesSelected:
          (json['communes_selected'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      colisIds:
          (json['colis_ids'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      livreurId: json['livreur_id'] ?? 0,
      enginId: json['engin_id'] ?? 0,
      statut: json['statut'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Livreur {
  final int id;
  final int entrepriseId;
  final String firstName;
  final String lastName;
  final String mobile;
  final String email;
  final String status;
  final String? emailVerifiedAt;
  final int enginId;
  final String photo;
  final String permis;
  final String adresse;
  final int? zoneActiviteId;
  final String password;
  final String createdBy;
  final String updatedBy;
  final String? deletedBy;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Livreur({
    required this.id,
    required this.entrepriseId,
    required this.firstName,
    required this.lastName,
    required this.mobile,
    required this.email,
    required this.status,
    this.emailVerifiedAt,
    required this.enginId,
    required this.photo,
    required this.permis,
    required this.adresse,
    this.zoneActiviteId,
    required this.password,
    required this.createdBy,
    required this.updatedBy,
    this.deletedBy,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      emailVerifiedAt: json['email_verified_at'],
      enginId: json['engin_id'] ?? 0,
      photo: json['photo'] ?? '',
      permis: json['permis'] ?? '',
      adresse: json['adresse'] ?? '',
      zoneActiviteId: json['zone_activite_id'],
      password: json['password'] ?? '',
      createdBy: json['created_by'] ?? '',
      updatedBy: json['updated_by'] ?? '',
      deletedBy: json['deleted_by'],
      rememberToken: json['remember_token'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }

  String get fullName => '$firstName $lastName';
}

class Engin {
  final int id;
  final int entrepriseId;
  final String libelle;
  final String matricule;
  final String marque;
  final String modele;
  final String couleur;
  final String immatriculation;
  final String etat;
  final String status;
  final int typeEnginId;
  final String createdBy;
  final String createdAt;
  final String updatedAt;
  final String? deletedAt;

  Engin({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.matricule,
    required this.marque,
    required this.modele,
    required this.couleur,
    required this.immatriculation,
    required this.etat,
    required this.status,
    required this.typeEnginId,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  factory Engin.fromJson(Map<String, dynamic> json) {
    return Engin(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      matricule: json['matricule'] ?? '',
      marque: json['marque'] ?? '',
      modele: json['modele'] ?? '',
      couleur: json['couleur'] ?? '',
      immatriculation: json['immatriculation'] ?? '',
      etat: json['etat'] ?? '',
      status: json['status'] ?? '',
      typeEnginId: json['type_engin_id'] ?? 0,
      createdBy: json['created_by'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      deletedAt: json['deleted_at'],
    );
  }
}

class Poids {
  final int id;
  final String libelle;
  final String createdBy;
  final int entrepriseId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Poids({
    required this.id,
    required this.libelle,
    required this.createdBy,
    required this.entrepriseId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Poids.fromJson(Map<String, dynamic> json) {
    return Poids(
      id: json['id'] ?? 0,
      libelle: json['libelle'] ?? '',
      createdBy: json['created_by'] ?? '',
      entrepriseId: json['entreprise_id'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ModeLivraison {
  final int id;
  final String libelle;
  final String description;
  final String createdBy;
  final int entrepriseId;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  ModeLivraison({
    required this.id,
    required this.libelle,
    required this.description,
    required this.createdBy,
    required this.entrepriseId,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ModeLivraison.fromJson(Map<String, dynamic> json) {
    return ModeLivraison(
      id: json['id'] ?? 0,
      libelle: json['libelle'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['created_by'] ?? '',
      entrepriseId: json['entreprise_id'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Temp {
  final int id;
  final int entrepriseId;
  final String libelle;
  final String description;
  final String heureDebut;
  final String heureFin;
  final bool isWeekend;
  final bool isHoliday;
  final bool isActive;
  final int createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  Temp({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.description,
    required this.heureDebut,
    required this.heureFin,
    required this.isWeekend,
    required this.isHoliday,
    required this.isActive,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Temp.fromJson(Map<String, dynamic> json) {
    return Temp(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      description: json['description'] ?? '',
      heureDebut: json['heure_debut'] ?? '',
      heureFin: json['heure_fin'] ?? '',
      isWeekend: json['is_weekend'] ?? false,
      isHoliday: json['is_holiday'] ?? false,
      isActive: json['is_active'] ?? true,
      createdBy: json['created_by'] ?? 0,
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class DeliveryStatistiques {
  final int colisEnAttente;
  final int colisEnCours;
  final int colisLivres;
  final int colisAnnules;
  final int total;
  final int montantTotalEncaisse;

  DeliveryStatistiques({
    required this.colisEnAttente,
    required this.colisEnCours,
    required this.colisLivres,
    required this.colisAnnules,
    required this.total,
    required this.montantTotalEncaisse,
  });

  factory DeliveryStatistiques.fromJson(Map<String, dynamic> json) {
    return DeliveryStatistiques(
      colisEnAttente: json['colis_en_attente'] ?? 0,
      colisEnCours: json['colis_en_cours'] ?? 0,
      colisLivres: json['colis_livres'] ?? 0,
      colisAnnules: json['colis_annules'] ?? 0,
      total: json['total'] ?? 0,
      montantTotalEncaisse: json['montant_total_encaisse'] ?? 0,
    );
  }
}
