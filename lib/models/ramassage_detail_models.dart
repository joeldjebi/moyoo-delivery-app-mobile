import 'dart:convert';
import 'ramassage_models.dart';

// Fonction utilitaire pour parser les montants (peuvent être des strings avec décimales)
int _parseAmount(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  final str = value.toString();
  // Gérer les strings avec décimales comme "0.00"
  final doubleValue = double.tryParse(str);
  return doubleValue?.toInt() ?? 0;
}

class RamassageDetailResponse {
  final bool success;
  final String message;
  final RamassageDetail data;

  RamassageDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RamassageDetailResponse.fromJson(Map<String, dynamic> json) {
    return RamassageDetailResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: RamassageDetail.fromJson(json['data']),
    );
  }
}

class RamassageDetail {
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
  final List<ColisLie> colisLies;

  RamassageDetail({
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
    required this.colisLies,
  });

  factory RamassageDetail.fromJson(Map<String, dynamic> json) {
    // Parser les colis depuis colis_data si colis_lies est vide
    List<ColisLie> colisLies = [];
    String colisDataString = '';

    // D'abord essayer colis_lies
    final colisLiesList = json['colis_lies'] as List?;
    if (colisLiesList != null && colisLiesList.isNotEmpty) {
      colisLies = colisLiesList.map((e) => ColisLie.fromJson(e)).toList();
    } else {
      // Sinon parser colis_data
      final colisDataValue = json['colis_data'];
      List<dynamic> colisDataList = [];

      // Gérer le cas où colis_data est une liste ou une string
      if (colisDataValue is List) {
        // colis_data est déjà une liste
        colisDataList = colisDataValue;
        colisDataString = jsonEncode(colisDataValue);
      } else if (colisDataValue is String && colisDataValue.isNotEmpty) {
        // colis_data est une string JSON
        colisDataString = colisDataValue;
        try {
          colisDataList = jsonDecode(colisDataString);
        } catch (e) {
          colisDataList = [];
        }
      }

      if (colisDataList.isNotEmpty) {
        try {
          colisLies =
              colisDataList.asMap().entries.map((entry) {
                final colisData = ColisData.fromJson(entry.value);
                final colisLie = colisData.toColisLie(entry.key);
                return colisLie;
              }).toList();
        } catch (e) {
          colisLies = [];
        }
      } else {}
    }

    return RamassageDetail(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      codeRamassage: json['code_ramassage'] ?? '',
      entrepriseId: int.tryParse(json['entreprise_id']?.toString() ?? '0') ?? 0,
      marchandId: int.tryParse(json['marchand_id']?.toString() ?? '0') ?? 0,
      boutiqueId: int.tryParse(json['boutique_id']?.toString() ?? '0') ?? 0,
      dateDemande: json['date_demande'] ?? '',
      datePlanifiee: json['date_planifiee'] ?? '',
      dateEffectuee: json['date_effectuee'],
      statut: json['statut'] ?? '',
      adresseRamassage: json['adresse_ramassage'] ?? '',
      contactRamassage: json['contact_ramassage'] ?? '',
      nombreColisEstime:
          int.tryParse(json['nombre_colis_estime']?.toString() ?? '0') ?? 0,
      nombreColisReel:
          int.tryParse(json['nombre_colis_reel']?.toString() ?? '0') ?? 0,
      differenceColis:
          json['difference_colis'] != null
              ? int.tryParse(json['difference_colis']?.toString() ?? '0')
              : null,
      typeDifference: json['type_difference'],
      raisonDifference: json['raison_difference'],
      livreurId:
          json['livreur_id'] != null
              ? int.tryParse(json['livreur_id']?.toString() ?? '0')
              : null,
      dateDebutRamassage: json['date_debut_ramassage'],
      dateFinRamassage: json['date_fin_ramassage'],
      photoRamassage: json['photo_ramassage'],
      notesLivreur: json['notes_livreur'],
      notesRamassage: json['notes_ramassage'],
      notes: json['notes'],
      colisData: colisDataString,
      montantTotal: json['montant_total'] ?? '0',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      marchand: Marchand.fromJson(json['marchand'] ?? {}),
      boutique: Boutique.fromJson(json['boutique'] ?? {}),
      livreur: json['livreur'],
      colisLies: colisLies,
    );
  }
}

class ColisLie {
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
  final String? noteClient;
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
  final Pivot pivot;

  ColisLie({
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
    this.noteClient,
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
    required this.pivot,
  });

  factory ColisLie.fromJson(Map<String, dynamic> json) {
    return ColisLie(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      entrepriseId: int.tryParse(json['entreprise_id']?.toString() ?? '0') ?? 0,
      packageColisId:
          int.tryParse(json['package_colis_id']?.toString() ?? '0') ?? 0,
      uuid: json['uuid'] ?? '',
      code: json['code'] ?? '',
      status: int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      nomClient: json['nom_client'] ?? '',
      telephoneClient: json['telephone_client'] ?? '',
      adresseClient: json['adresse_client'] ?? '',
      montantAEncaisse: _parseAmount(json['montant_a_encaisse']),
      prixDeVente: _parseAmount(json['prix_de_vente']),
      numeroFacture: json['numero_facture'] ?? '',
      noteClient: json['note_client'],
      instructionsLivraison: json['instructions_livraison'],
      zoneId: int.tryParse(json['zone_id']?.toString() ?? '0') ?? 0,
      communeId: int.tryParse(json['commune_id']?.toString() ?? '0') ?? 0,
      ordreLivraison:
          json['ordre_livraison'] != null
              ? int.tryParse(json['ordre_livraison']?.toString() ?? '0')
              : null,
      dateLivraisonPrevue: json['date_livraison_prevue'],
      livreurId: int.tryParse(json['livreur_id']?.toString() ?? '0') ?? 0,
      enginId: int.tryParse(json['engin_id']?.toString() ?? '0') ?? 0,
      poidsId: int.tryParse(json['poids_id']?.toString() ?? '0') ?? 0,
      modeLivraisonId:
          int.tryParse(json['mode_livraison_id']?.toString() ?? '0') ?? 0,
      tempId: int.tryParse(json['temp_id']?.toString() ?? '0') ?? 0,
      createdBy: json['created_by'] ?? '',
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      pivot: Pivot.fromJson(json['pivot'] ?? {}),
    );
  }

  String get statutFormatted {
    switch (status) {
      case 0:
        return 'En attente';
      case 1:
        return 'En cours';
      case 2:
        return 'Terminé';
      case 3:
        return 'Annulé';
      default:
        return 'Inconnu';
    }
  }
}

class Pivot {
  final int ramassageId;
  final int colisId;
  final String createdAt;
  final String updatedAt;

  Pivot({
    required this.ramassageId,
    required this.colisId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Pivot.fromJson(Map<String, dynamic> json) {
    return Pivot(
      ramassageId: int.tryParse(json['ramassage_id']?.toString() ?? '0') ?? 0,
      colisId: int.tryParse(json['colis_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// Nouveau modèle pour les colis du colis_data
class ColisData {
  final String? id;
  final String code;
  final String nomClient;
  final String telephoneClient;
  final String adresseClient;
  final int montantAEncaisse;
  final int prixDeVente;
  final String? noteClient;
  final String? instructionsLivraison;
  final int communeId;
  final int livreurId;
  final int enginId;
  final int poidsId;
  final int modeLivraisonId;
  final int tempId;
  final String createdAt;
  final String updatedAt;

  ColisData({
    this.id,
    required this.code,
    required this.nomClient,
    required this.telephoneClient,
    required this.adresseClient,
    required this.montantAEncaisse,
    required this.prixDeVente,
    this.noteClient,
    this.instructionsLivraison,
    required this.communeId,
    required this.livreurId,
    required this.enginId,
    required this.poidsId,
    required this.modeLivraisonId,
    required this.tempId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ColisData.fromJson(Map<String, dynamic> json) {
    // Gérer les deux formats possibles : "client" ou "nom_client"
    final nomClient = json['client'] ?? json['nom_client'] ?? '';
    // Gérer "valeur" ou "montant_a_encaisse"
    final montantAEncaisseStr =
        json['valeur']?.toString() ??
        json['montant_a_encaisse']?.toString() ??
        '0';

    return ColisData(
      id: json['id']?.toString(),
      code: json['code'] ?? '',
      nomClient: nomClient,
      telephoneClient: json['telephone_client'] ?? '',
      adresseClient: json['adresse_client'] ?? '',
      montantAEncaisse: int.tryParse(montantAEncaisseStr) ?? 0,
      prixDeVente: int.tryParse(json['prix_de_vente']?.toString() ?? '0') ?? 0,
      noteClient: json['notes'] ?? json['note_client'],
      instructionsLivraison: json['instructions_livraison'],
      communeId: int.tryParse(json['commune_id']?.toString() ?? '0') ?? 0,
      livreurId: int.tryParse(json['livreur_id']?.toString() ?? '0') ?? 0,
      enginId: int.tryParse(json['engin_id']?.toString() ?? '0') ?? 0,
      poidsId: int.tryParse(json['poids_id']?.toString() ?? '0') ?? 0,
      modeLivraisonId:
          int.tryParse(json['mode_livraison_id']?.toString() ?? '0') ?? 0,
      tempId: int.tryParse(json['temp_id']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  // Convertir en ColisLie pour l'affichage
  ColisLie toColisLie(int index) {
    return ColisLie(
      id: int.tryParse(id ?? '${index + 1}') ?? (index + 1),
      entrepriseId: 1,
      packageColisId: 0,
      uuid: 'temp-${index}',
      code: code,
      status: 0, // En attente par défaut
      nomClient: nomClient,
      telephoneClient: telephoneClient,
      adresseClient: adresseClient,
      montantAEncaisse: montantAEncaisse,
      prixDeVente: prixDeVente,
      numeroFacture: 'FAC-${index + 1}',
      noteClient: noteClient,
      instructionsLivraison: instructionsLivraison,
      zoneId: 0,
      communeId: communeId,
      ordreLivraison: index + 1,
      dateLivraisonPrevue: null,
      livreurId: livreurId,
      enginId: enginId,
      poidsId: poidsId,
      modeLivraisonId: modeLivraisonId,
      tempId: tempId,
      createdBy: '1',
      deletedAt: null,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pivot: Pivot(
        ramassageId: 0,
        colisId: int.tryParse(id ?? '${index + 1}') ?? (index + 1),
        createdAt: createdAt,
        updatedAt: updatedAt,
      ),
    );
  }
}
