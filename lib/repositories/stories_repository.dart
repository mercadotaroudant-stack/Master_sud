import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/app_config.dart';
import '../models/story_model.dart';
import '../services/firebase_service.dart';

/// طبقة الوصول إلى بيانات الستوريات الدائمة (شريط أسفل Banner Slider مباشرة)
/// من Firestore. لوحة التحكم/Firebase هي المصدر الوحيد للحقيقة: لا ستوريات
/// وهمية، ولا حذف تلقائي بعد 24 ساعة.
abstract class StoriesRepository {
  Stream<List<StoryGroup>> streamActiveStoryGroups();
}

class FirebaseStoriesRepository implements StoriesRepository {
  final FirebaseFirestore _db = FirebaseService.instance.firestore;

  CollectionReference<Map<String, dynamic>> get _stories =>
      _db.collection(AppConfig.collectionStories);

  @override
  Stream<List<StoryGroup>> streamActiveStoryGroups() {
    // نفس منطق صفحة Formation: التصفية/الترتيب يتمّان محليًا حتى لا تُستبعد
    // مستندات قديمة لا تملك بعد الحقول order/isActive الجديدة من استعلام
    // Firestore مركّب صارم.
    return _stories.snapshots().map((snapshot) {
      final slides = snapshot.docs.map(StorySlideModel.fromDoc).where((s) => s.active).toList();

      final Map<String, List<StorySlideModel>> grouped = {};
      for (final slide in slides) {
        grouped.putIfAbsent(slide.groupId, () => []).add(slide);
      }

      final groups = grouped.entries.map((entry) {
        final items = entry.value..sort((a, b) => a.itemOrder.compareTo(b.itemOrder));
        final first = items.first;
        return StoryGroup(
          groupId: entry.key,
          title: first.groupTitle,
          coverImage: first.groupCoverImage,
          order: first.groupOrder,
          items: items,
        );
      }).toList();

      groups.sort((a, b) => a.order.compareTo(b.order));
      return groups;
    });
  }
}
