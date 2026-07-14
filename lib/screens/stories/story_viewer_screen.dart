import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

import '../../config/app_config.dart';
import '../../models/story_model.dart';

/// مُشاهد الستوريات بملء الشاشة — بنفس منطق Instagram: أشرطة تقدّم أعلى
/// الشاشة، تبديل تلقائي، نقر يمين/يسار للتنقل، ضغط مطوّل للإيقاف المؤقت،
/// سحب لأسفل للإغلاق، وتمرير أفقي للانتقال بين الستوريات (الفقاعات).
///
/// الفرق الوحيد عن Instagram الحقيقي: هذه الستوريات لا تُحذف تلقائيًا بعد
/// 24 ساعة — تبقى معروضة حتى تُحذف/تُعطَّل يدويًا من لوحة التحكم.
class StoryViewerScreen extends StatefulWidget {
  final List<StoryGroup> groups;
  final int initialGroupIndex;

  const StoryViewerScreen({super.key, required this.groups, required this.initialGroupIndex});

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late final PageController _pageController;
  late int _currentGroupIndex;

  @override
  void initState() {
    super.initState();
    _currentGroupIndex = widget.initialGroupIndex;
    _pageController = PageController(initialPage: _currentGroupIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToGroup(int index) {
    if (index < 0 || index >= widget.groups.length) {
      Navigator.of(context).maybePop();
      return;
    }
    _pageController.animateToPage(index, duration: const Duration(milliseconds: 260), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.delta.dy > 14) Navigator.of(context).maybePop();
        },
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.groups.length,
          onPageChanged: (index) => setState(() => _currentGroupIndex = index),
          itemBuilder: (context, index) {
            final group = widget.groups[index];
            return _StoryGroupPage(
              key: ValueKey(group.groupId),
              group: group,
              isActive: index == _currentGroupIndex,
              onFinishedGroup: () => _goToGroup(index + 1),
              onExitToPreviousGroup: () => _goToGroup(index - 1),
              onClose: () => Navigator.of(context).maybePop(),
            );
          },
        ),
      ),
    );
  }
}

class _StoryGroupPage extends StatefulWidget {
  final StoryGroup group;
  final bool isActive;
  final VoidCallback onFinishedGroup;
  final VoidCallback onExitToPreviousGroup;
  final VoidCallback onClose;

  const _StoryGroupPage({
    required super.key,
    required this.group,
    required this.isActive,
    required this.onFinishedGroup,
    required this.onExitToPreviousGroup,
    required this.onClose,
  });

  @override
  State<_StoryGroupPage> createState() => _StoryGroupPageState();
}

class _StoryGroupPageState extends State<_StoryGroupPage> with SingleTickerProviderStateMixin {
  static const _imageDuration = Duration(seconds: 5);

  late AnimationController _progressController;
  VideoPlayerController? _videoController;
  int _itemIndex = 0;
  bool _paused = false;
  bool _mediaReady = false;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _advance();
      });
    if (widget.isActive) {
      _markGroupSeen();
      _startItem(0);
    }
  }

  @override
  void didUpdateWidget(covariant _StoryGroupPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isActive && widget.isActive) {
      _markGroupSeen();
      _startItem(0);
    } else if (oldWidget.isActive && !widget.isActive) {
      _stopCurrent();
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _markGroupSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final seen = (prefs.getStringList(AppConfig.prefSeenStoryGroups) ?? []).toSet();
    seen.add(widget.group.groupId);
    await prefs.setStringList(AppConfig.prefSeenStoryGroups, seen.toList());
  }

  void _stopCurrent() {
    _progressController.stop();
    _videoController?.pause();
  }

  Future<void> _startItem(int index) async {
    _progressController.stop();
    _progressController.reset();
    _videoController?.dispose();
    _videoController = null;
    setState(() {
      _itemIndex = index;
      _mediaReady = false;
      _paused = false;
    });

    final item = widget.group.items[index];
    if (item.mediaType == StoryMediaType.video) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(item.mediaUrl));
      _videoController = controller;
      try {
        await controller.initialize();
        if (!mounted || _videoController != controller) return;
        final duration = controller.value.duration.inMilliseconds > 0
            ? controller.value.duration
            : _imageDuration;
        _progressController.duration = duration;
        controller.play();
        setState(() => _mediaReady = true);
        if (widget.isActive) _progressController.forward();
      } catch (_) {
        if (!mounted) return;
        // فشل تحميل الفيديو: ننتقل مباشرة للشريحة التالية بدل تجميد الشاشة.
        _advance();
      }
    } else {
      _progressController.duration = _imageDuration;
      setState(() => _mediaReady = true);
      if (widget.isActive) _progressController.forward();
    }
  }

  void _advance() {
    if (!mounted) return;
    if (_itemIndex + 1 < widget.group.items.length) {
      _startItem(_itemIndex + 1);
    } else {
      widget.onFinishedGroup();
    }
  }

  void _rewind() {
    if (_itemIndex > 0) {
      _startItem(_itemIndex - 1);
    } else {
      widget.onExitToPreviousGroup();
    }
  }

  void _pause() {
    if (_paused || !widget.isActive) return;
    setState(() => _paused = true);
    _progressController.stop();
    _videoController?.pause();
  }

  void _resume() {
    if (!_paused || !widget.isActive) return;
    setState(() => _paused = false);
    if (_mediaReady) _progressController.forward();
    _videoController?.play();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.group.items[_itemIndex];
    return GestureDetector(
      onLongPressStart: (_) => _pause(),
      onLongPressEnd: (_) => _resume(),
      onTapUp: (details) {
        final width = MediaQuery.of(context).size.width;
        if (details.globalPosition.dx < width * 0.3) {
          _rewind();
        } else {
          _advance();
        }
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          Center(
            child: item.mediaType == StoryMediaType.video
                ? (_videoController != null && _videoController!.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _videoController!.value.aspectRatio,
                        child: VideoPlayer(_videoController!),
                      )
                    : const CircularProgressIndicator(color: Colors.white))
                : CachedNetworkImage(
                    imageUrl: item.mediaUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    placeholder: (_, __) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image_outlined, color: Colors.white54, size: 42),
                    ),
                  ),
          ),
          _buildTopOverlay(),
        ],
      ),
    );
  }

  Widget _buildTopOverlay() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          children: [
            Row(
              children: List.generate(widget.group.items.length, (i) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _ProgressSegment(
                      state: i < _itemIndex
                          ? _SegmentState.filled
                          : i == _itemIndex
                              ? _SegmentState.active
                              : _SegmentState.empty,
                      animation: _progressController,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: widget.group.coverImage,
                    width: 32,
                    height: 32,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(width: 32, height: 32, color: Colors.white24),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.group.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(Icons.close_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _SegmentState { filled, active, empty }

class _ProgressSegment extends StatelessWidget {
  final _SegmentState state;
  final Animation<double> animation;

  const _ProgressSegment({required this.state, required this.animation});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 2.5,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: Stack(
          children: [
            Container(color: Colors.white.withOpacity(0.35)),
            if (state == _SegmentState.filled) Container(color: Colors.white),
            if (state == _SegmentState.active)
              AnimatedBuilder(
                animation: animation,
                builder: (context, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animation.value.clamp(0.0, 1.0),
                    child: Container(color: Colors.white),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
