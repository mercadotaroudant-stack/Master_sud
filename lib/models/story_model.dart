import 'package:cloud_firestore/cloud_firestore.dart';

/// نوع الوسائط داخل شريحة الستوري (صورة أو فيديو قصير).
enum StoryMediaType { image, video }

/// شريحة واحدة داخل ستوري (صورة أو فيديو). عدّة شرائح بنفس [groupId] تُشكّل
/// ستوري واحدة (فقاعة واحدة) بترتيب عرض داخلي.
///
/// Firestore collection: stories
/// الحقول: groupId, groupTitle, groupCoverImage, groupOrder, mediaUrl,
/// mediaType ('image' | 'video'), itemOrder, isActive/active, createdAt.
///
/// ⚠️ على عكس ستوريات Instagram الحقيقية، هذه الستوريات دائمة: لا يتم حذفها
/// تلقائيًا بعد 24 ساعة. هي تبقى ظاهرة في التطبيق إلى أن يتم حذفها أو
/// تعطيلها (isActive = false) يدويًا من لوحة التحكم Dashboard.
class StorySlideModel {
  final String id;
  final String groupId;
  final String groupTitle;
  final String groupCoverImage;
  final int groupOrder;
  final String mediaUrl;
  final StoryMediaType mediaType;
  final int itemOrder;
  final bool active;
  final DateTime? createdAt;

  const StorySlideModel({
    required this.id,
    required this.groupId,
    required this.groupTitle,
    required this.groupCoverImage,
    required this.groupOrder,
    required this.mediaUrl,
    required this.mediaType,
    required this.itemOrder,
    this.active = true,
    this.createdAt,
  });

  factory StorySlideModel.fromMap(String id, Map<String, dynamic> map) {
    final ts = map['createdAt'];
    final groupOrderValue = map['groupOrder'];
    final itemOrderValue = map['itemOrder'];
    final typeStr = (map['mediaType'] ?? 'image') as String;

    return StorySlideModel(
      id: id,
      groupId: (map['groupId'] ?? id) as String,
      groupTitle: (map['groupTitle'] ?? '') as String,
      groupCoverImage: (map['groupCoverImage'] ?? map['mediaUrl'] ?? '') as String,
      groupOrder: groupOrderValue is num ? groupOrderValue.toInt() : 0,
      mediaUrl: (map['mediaUrl'] ?? '') as String,
      mediaType: typeStr == 'video' ? StoryMediaType.video : StoryMediaType.image,
      itemOrder: itemOrderValue is num ? itemOrderValue.toInt() : 0,
      active: (map['isActive'] ?? map['active'] ?? true) as bool,
      createdAt: ts is Timestamp ? ts.toDate() : null,
    );
  }

  factory StorySlideModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    return StorySlideModel.fromMap(doc.id, doc.data() ?? {});
  }
}

/// مجموعة ستوريات (فقاعة واحدة في الشريط) — نتيجة تجميع [StorySlideModel]
/// حسب groupId، مرتّبة داخليًا حسب itemOrder. لا تُخزَّن في Firestore مباشرة،
/// بل تُبنى محليًا من طرف [StoriesRepository].
class StoryGroup {
  final String groupId;
  final String title;
  final String coverImage;
  final int order;
  final List<StorySlideModel> items;

  const StoryGroup({
    required this.groupId,
    required this.title,
    required this.coverImage,
    required this.order,
    required this.items,
  });
}
