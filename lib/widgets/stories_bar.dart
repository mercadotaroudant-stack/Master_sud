import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimens.dart';
import '../models/story_model.dart';
import '../repositories/stories_repository.dart';
import '../screens/stories/story_viewer_screen.dart';

/// شريط الستوريات (فقاعات دائرية) أسفل Banner Slider مباشرة، على شكل
/// Instagram بالضبط — لكن دائم: لا تختفي الستوريات بعد 24 ساعة، بل تبقى
/// ظاهرة إلى أن يتم حذفها/تعطيلها من لوحة التحكم Dashboard.
class StoriesBar extends StatefulWidget {
  const StoriesBar({super.key});

  @override
  State<StoriesBar> createState() => _StoriesBarState();
}

class _StoriesBarState extends State<StoriesBar> {
  final StoriesRepository _repository = FirebaseStoriesRepository();
  Set<String> _seenGroupIds = {};

  @override
  void initState() {
    super.initState();
    _loadSeenGroups();
  }

  Future<void> _loadSeenGroups() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _seenGroupIds = (prefs.getStringList(AppConfig.prefSeenStoryGroups) ?? []).toSet();
    });
  }

  Future<void> _openStory(List<StoryGroup> groups, int initialIndex) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(groups: groups, initialGroupIndex: initialIndex),
        fullscreenDialog: true,
      ),
    );
    // نُحدّث حالة الحلقات (مُشاهَدة/غير مُشاهَدة) بعد العودة من المُشاهد.
    _loadSeenGroups();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<StoryGroup>>(
      stream: _repository.streamActiveStoryGroups(),
      builder: (context, snapshot) {
        final groups = snapshot.data ?? [];
        if (groups.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 96,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppDimens.paddingMd),
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              final seen = _seenGroupIds.contains(group.groupId);
              return _StoryBubble(
                group: group,
                seen: seen,
                onTap: () => _openStory(groups, index),
              );
            },
          ),
        );
      },
    );
  }
}

class _StoryBubble extends StatelessWidget {
  final StoryGroup group;
  final bool seen;
  final VoidCallback onTap;

  const _StoryBubble({required this.group, required this.seen, required this.onTap});

  static const _unseenGradient = LinearGradient(
    colors: [Color(0xFFE5B83F), Color(0xFFDD2A7B), Color(0xFF8134AF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 76,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: seen ? null : _unseenGradient,
                color: seen ? AppColors.border : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                child: ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: group.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: AppColors.shimmerBase),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.primary,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_outlined, color: Colors.white70, size: 20),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              group.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}
