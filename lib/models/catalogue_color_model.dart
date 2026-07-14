import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Une couleur appartenant à un catalogue de peinture.
///
/// Firestore : paintCatalogues/{catalogueId}/colors/{colorId}
///
/// Le rendu visuel (hexColor) provient exclusivement du Dashboard —
/// aucune couleur n'est générée ou devinée côté Flutter.
class CatalogueColorModel {
  final String id;
  final String? name;
  final String code;
  final String hexColor;
  final bool isActive;
  final int order;

  const CatalogueColorModel({
    required this.id,
    this.name,
    required this.code,
    required this.hexColor,
    required this.isActive,
    required this.order,
  });

  /// Convertit la valeur hexColor stockée dans Firebase (ex. "#E4B63F" ou
  /// "E4B63F") en [Color]. Retourne `null` si la valeur est absente ou
  /// invalide, afin de ne jamais afficher une couleur inventée.
  Color? get color {
    var hex = hexColor.trim().replaceFirst('#', '');
    if (hex.isEmpty) return null;
    if (hex.length == 6) hex = 'FF$hex';
    if (hex.length != 8) return null;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  factory CatalogueColorModel.fromMap(String id, Map<String, dynamic> map) {
    final rawName = map['name'] as String?;
    return CatalogueColorModel(
      id: id,
      name: (rawName == null || rawName.trim().isEmpty) ? null : rawName,
      code: (map['code'] ?? '') as String,
      hexColor: (map['hexColor'] ?? '') as String,
      isActive: (map['isActive'] ?? true) as bool,
      order: ((map['order'] ?? 0) as num).toInt(),
    );
  }

  factory CatalogueColorModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return CatalogueColorModel.fromMap(doc.id, doc.data() ?? {});
  }
}
