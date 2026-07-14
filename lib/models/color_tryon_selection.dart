import 'package:flutter/material.dart';

import '../models/catalogue_color_model.dart';

/// Représente la couleur choisie par l'utilisateur pour l'essai (try-on),
/// transportée telle quelle depuis la carte couleur jusqu'à l'éditeur.
///
/// Construite uniquement à partir de données Firebase — jamais inventée.
class ColorTryOnSelection {
  final String catalogueId;
  final String catalogueName;
  final String colorId;
  final String colorCode;
  final String? colorName;
  final Color hexColor;

  const ColorTryOnSelection({
    required this.catalogueId,
    required this.catalogueName,
    required this.colorId,
    required this.colorCode,
    required this.colorName,
    required this.hexColor,
  });

  /// Retourne `null` si la couleur Firebase n'a pas de hexColor exploitable
  /// — on ne propose jamais un essai avec une couleur devinée.
  static ColorTryOnSelection? fromCatalogueColor({
    required String catalogueId,
    required String catalogueName,
    required CatalogueColorModel color,
  }) {
    final resolved = color.color;
    if (resolved == null) return null;
    return ColorTryOnSelection(
      catalogueId: catalogueId,
      catalogueName: catalogueName,
      colorId: color.id,
      colorCode: color.code,
      colorName: color.name,
      hexColor: resolved,
    );
  }

  /// Étiquette d'affichage, ex. "Omega Jawaher • OMG 60".
  String get subtitle => '$catalogueName • $colorCode';
}
