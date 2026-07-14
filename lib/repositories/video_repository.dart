import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/video_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات الفيديوهات التكوينية من Firestore (قسم VIDÉOS DE FORMATION).
///
/// Le Dashboard/Firebase reste la seule source de vérité pour la page
/// Formation (grille complète, temps réel) comme pour l'aperçu de la page
/// d'accueil (liste limitée, chargement ponctuel — comportement inchangé).
abstract class VideoRepository {
  Future<List<VideoModel>> getTrainingVideos({int limit = 10});

  /// Flux temps réel de toutes les vidéos actives, triées selon le champ
  /// `order` du Dashboard (puis par date de création à défaut), utilisé par
  /// la page Formation complète.
  Stream<List<VideoModel>> streamActiveVideos();
}

class FirebaseVideoRepository implements VideoRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> get _videos =>
      _db.collection(AppConfig.collectionVideos);

  @override
  Future<List<VideoModel>> getTrainingVideos({int limit = 10}) async {
    final snapshot = await _videos
        .where('active', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map(VideoModel.fromDoc).toList();
  }

  @override
  Stream<List<VideoModel>> streamActiveVideos() {
    // On ne filtre/trie pas directement via `.where('active', ...)` combiné à
    // un `orderBy('order', ...)` côté Firestore : certains documents existants
    // peuvent ne pas encore avoir de champ `order` (ou utiliser `isActive`),
    // ce qui les exclurait injustement d'une requête composite stricte. Le
    // filtrage/tri est donc appliqué côté client, en restant fidèle au champ
    // `order` du Dashboard dès qu'il est présent.
    return _videos.snapshots().map((snapshot) {
      final videos = snapshot.docs.map(VideoModel.fromDoc).where((v) => v.active).toList();
      videos.sort((a, b) {
        final orderCompare = a.order.compareTo(b.order);
        if (orderCompare != 0) return orderCompare;
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
      return videos;
    });
  }
}
