import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج فيديو تكويني — قسم VIDÉOS DE FORMATION (صفحة Formation + الصفحة الرئيسية).
///
/// Firestore collection: videos
/// الحقول: id, title, description, thumbnail, videoUrl, duration, category,
/// active/isActive, order, createdAt, updatedAt
///
/// Le Dashboard reste la seule source de vérité : `active` et `isActive` sont
/// tous deux acceptés en lecture pour rester compatible avec les documents
/// existants, sans dupliquer le modèle de données.
class VideoModel {
  final String id;
  final String title;
  final String? description;
  final String thumbnail;
  final String videoUrl;
  final String duration; // مثال: "05:24"
  final String? category;
  final bool active;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VideoModel({
    required this.id,
    required this.title,
    this.description,
    required this.thumbnail,
    required this.videoUrl,
    required this.duration,
    this.category,
    this.active = true,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory VideoModel.fromMap(String id, Map<String, dynamic> map) {
    final createdTs = map['createdAt'];
    final updatedTs = map['updatedAt'];
    final orderValue = map['order'];
    return VideoModel(
      id: id,
      title: (map['title'] ?? '') as String,
      description: map['description'] as String?,
      thumbnail: (map['thumbnail'] ?? map['thumbnailUrl'] ?? '') as String,
      videoUrl: (map['videoUrl'] ?? '') as String,
      duration: (map['duration'] ?? '') as String,
      category: map['category'] as String?,
      active: (map['isActive'] ?? map['active'] ?? true) as bool,
      order: orderValue is num ? orderValue.toInt() : 0,
      createdAt: createdTs is Timestamp ? createdTs.toDate() : null,
      updatedAt: updatedTs is Timestamp ? updatedTs.toDate() : null,
    );
  }

  factory VideoModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return VideoModel.fromMap(doc.id, doc.data() ?? {});
  }
}
