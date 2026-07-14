import 'dart:typed_data';

import 'package:gal/gal.dart';

/// Résultat d'une tentative d'enregistrement d'image.
enum SaveImageResult { success, permissionDenied, failure }

/// Enregistre l'image éditée (Color Try-On) dans la galerie de l'appareil.
///
/// Utilise le package `gal`, qui gère lui-même la demande d'autorisation
/// d'accès aux photos/au stockage selon la plateforme (Android/iOS) — la
/// permission n'est donc demandée qu'au moment de l'enregistrement.
class ImageSaveService {
  static Future<SaveImageResult> saveImageBytes(Uint8List bytes, {String? name}) async {
    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        final granted = await Gal.requestAccess();
        if (!granted) return SaveImageResult.permissionDenied;
      }
      await Gal.putImageBytes(bytes, name: name ?? 'master_sud_essai_couleur');
      return SaveImageResult.success;
    } on GalException catch (e) {
      if (e.type == GalExceptionType.accessDenied) {
        return SaveImageResult.permissionDenied;
      }
      return SaveImageResult.failure;
    } catch (_) {
      return SaveImageResult.failure;
    }
  }
}
