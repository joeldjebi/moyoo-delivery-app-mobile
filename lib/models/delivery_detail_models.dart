import 'delivery_models.dart';

class DeliveryDetailResponse {
  final bool success;
  final String message;
  final ColisDetail data;

  DeliveryDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory DeliveryDetailResponse.fromJson(Map<String, dynamic> json) {
    return DeliveryDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ColisDetail.fromJson(json['data'] ?? {}),
    );
  }
}

class ColisDetail {
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
  final HistoriqueLivraison historiqueLivraison;
  final Commune commune;
  final LivraisonDetail livraison;
  final PackageColis packageColis;
  final Temp temp;
  final ModeLivraison modeLivraison;
  final Poids poids;
  final TypeColis typeColis;
  final ConditionnementColis conditionnementColis;
  final Delai delai;
  final Livreur livreur;
  final Engin engin;
  final Marchand marchand;
  final Boutique boutique;

  ColisDetail({
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
    required this.historiqueLivraison,
    required this.commune,
    required this.livraison,
    required this.packageColis,
    required this.temp,
    required this.modeLivraison,
    required this.poids,
    required this.typeColis,
    required this.conditionnementColis,
    required this.delai,
    required this.livreur,
    required this.engin,
    required this.marchand,
    required this.boutique,
  });

  factory ColisDetail.fromJson(Map<String, dynamic> json) {
    return ColisDetail(
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
      historiqueLivraison: HistoriqueLivraison.fromJson(
        json['historique_livraison'] ?? {},
      ),
      commune: Commune.fromJson(json['commune'] ?? {}),
      livraison: LivraisonDetail.fromJson(json['livraison'] ?? {}),
      packageColis: PackageColis.fromJson(json['package_colis'] ?? {}),
      temp: Temp.fromJson(json['temp'] ?? {}),
      modeLivraison: ModeLivraison.fromJson(json['mode_livraison'] ?? {}),
      poids: Poids.fromJson(json['poids'] ?? {}),
      typeColis: TypeColis.fromJson(json['type_colis'] ?? {}),
      conditionnementColis: ConditionnementColis.fromJson(
        json['conditionnement_colis'] ?? {},
      ),
      delai: Delai.fromJson(json['delai'] ?? {}),
      livreur: Livreur.fromJson(json['livreur'] ?? {}),
      engin: Engin.fromJson(json['engin'] ?? {}),
      marchand: Marchand.fromJson(json['marchand'] ?? {}),
      boutique: Boutique.fromJson(json['boutique'] ?? {}),
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
      default:
        return 'Inconnu';
    }
  }

  bool get isEnAttente => status == 0;
  bool get isEnCours => status == 1;
  bool get isLivre => status == 2;
  bool get isAnnule => status == 3;
}

class HistoriqueLivraison {
  final int id;
  final int entrepriseId;
  final int packageColisId;
  final int livraisonId;
  final String status;
  final String? codeValidationUtilise;
  final String? photoProofPath;
  final String? signatureData;
  final String? noteLivraison;
  final String? motifAnnulation;
  final String? dateLivraisonEffective;
  final double? latitude;
  final double? longitude;
  final int colisId;
  final int livreurId;
  final int montantAEncaisse;
  final int prixDeVente;
  final int montantDeLaLivraison;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;

  HistoriqueLivraison({
    required this.id,
    required this.entrepriseId,
    required this.packageColisId,
    required this.livraisonId,
    required this.status,
    this.codeValidationUtilise,
    this.photoProofPath,
    this.signatureData,
    this.noteLivraison,
    this.motifAnnulation,
    this.dateLivraisonEffective,
    this.latitude,
    this.longitude,
    required this.colisId,
    required this.livreurId,
    required this.montantAEncaisse,
    required this.prixDeVente,
    required this.montantDeLaLivraison,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HistoriqueLivraison.fromJson(Map<String, dynamic> json) {
    return HistoriqueLivraison(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      packageColisId: json['package_colis_id'] ?? 0,
      livraisonId: json['livraison_id'] ?? 0,
      status: json['status'] ?? '',
      codeValidationUtilise: json['code_validation_utilise'],
      photoProofPath: json['photo_proof_path'],
      signatureData: json['signature_data'],
      noteLivraison: json['note_livraison'],
      motifAnnulation: json['motif_annulation'],
      dateLivraisonEffective: json['date_livraison_effective'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      colisId: json['colis_id'] ?? 0,
      livreurId: json['livreur_id'] ?? 0,
      montantAEncaisse: json['montant_a_encaisse'] ?? 0,
      prixDeVente: json['prix_de_vente'] ?? 0,
      montantDeLaLivraison: json['montant_de_la_livraison'] ?? 0,
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class LivraisonDetail {
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

  LivraisonDetail({
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

  factory LivraisonDetail.fromJson(Map<String, dynamic> json) {
    return LivraisonDetail(
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

// Nouvelles classes de modèles pour les détails étendus

class TypeColis {
  final int id;
  final String libelle;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final int laravelThroughKey;

  TypeColis({
    required this.id,
    required this.libelle,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.laravelThroughKey,
  });

  factory TypeColis.fromJson(Map<String, dynamic> json) {
    return TypeColis(
      id: json['id'] ?? 0,
      libelle: json['libelle'] ?? '',
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      laravelThroughKey: json['laravel_through_key'] ?? 0,
    );
  }
}

class ConditionnementColis {
  final int id;
  final int entrepriseId;
  final String libelle;
  final int createdBy;
  final String createdAt;
  final String updatedAt;

  ConditionnementColis({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ConditionnementColis.fromJson(Map<String, dynamic> json) {
    return ConditionnementColis(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class Delai {
  final int id;
  final int entrepriseId;
  final String libelle;
  final String createdBy;
  final String? deletedAt;
  final String createdAt;
  final String updatedAt;
  final int laravelThroughKey;

  Delai({
    required this.id,
    required this.entrepriseId,
    required this.libelle,
    required this.createdBy,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.laravelThroughKey,
  });

  factory Delai.fromJson(Map<String, dynamic> json) {
    return Delai(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      laravelThroughKey: json['laravel_through_key'] ?? 0,
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
  final int laravelThroughKey;

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
    required this.laravelThroughKey,
  });

  factory Marchand.fromJson(Map<String, dynamic> json) {
    return Marchand(
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      adresse: json['adresse'] ?? '',
      status: json['status'] ?? '',
      communeId: json['commune_id'] ?? 0,
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      laravelThroughKey: json['laravel_through_key'] ?? 0,
    );
  }

  String get fullName => '$firstName $lastName';
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
      id: json['id'] ?? 0,
      entrepriseId: json['entreprise_id'] ?? 0,
      libelle: json['libelle'] ?? '',
      mobile: json['mobile'] ?? '',
      adresse: json['adresse'] ?? '',
      adresseGps: json['adresse_gps'] ?? '',
      coverImage: json['cover_image'] ?? '',
      marchandId: json['marchand_id'] ?? 0,
      status: json['status'] ?? '',
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
