import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/showroom_model.dart';

/// Service unique pour les actions "Appeler" et "Itinéraire" d'un showroom.
/// Utilisé par la carte de la liste ET par la page de détails — aucune
/// logique dupliquée. Toutes les données (téléphone, coordonnées, adresse)
/// proviennent de Firebase.
class ShowroomActionsService {
  ShowroomActionsService._();

  static final ShowroomActionsService instance = ShowroomActionsService._();

  Future<void> call(BuildContext context, ShowroomModel showroom) async {
    if (!showroom.hasPhone) return;
    final uri = Uri(scheme: 'tel', path: showroom.phone);
    if (!await _tryLaunch(uri)) {
      if (!context.mounted) return;
      _showMessage(context, "Impossible d'ouvrir le composeur téléphonique.");
    }
  }

  Future<void> openItinerary(BuildContext context, ShowroomModel showroom) async {
    Uri? uri;

    if (showroom.latitude != null && showroom.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${showroom.latitude},${showroom.longitude}',
      );
    } else if (showroom.mapsUrl != null && showroom.mapsUrl!.isNotEmpty) {
      uri = Uri.tryParse(showroom.mapsUrl!);
    } else if (showroom.address.isNotEmpty) {
      uri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(showroom.address)}',
      );
    }

    if (uri == null || !await _tryLaunch(uri, external: true)) {
      if (!context.mounted) return;
      _showMessage(context, "Impossible d'ouvrir l'itinéraire.");
    }
  }

  Future<bool> _tryLaunch(Uri uri, {bool external = false}) async {
    try {
      if (!await canLaunchUrl(uri)) return false;
      return launchUrl(uri, mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault);
    } catch (_) {
      return false;
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
