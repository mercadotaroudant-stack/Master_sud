import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../models/video_model.dart';
import 'widgets/video_controls_overlay.dart';

/// Lecteur vidéo plein écran dédié à une vidéo Formation (Firebase).
///
/// Bascule automatiquement l'appareil en mode paysage à l'ouverture et
/// restaure le mode portrait à la fermeture, quel que soit le chemin de
/// sortie (bouton retour du player, geste système, `Navigator.pop`).
class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _initializing = true;
  bool _hasError = false;
  bool _controlsVisible = true;
  bool _completed = false;
  bool _isMuted = false;
  double _volumeBeforeMute = 1.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _enterImmersiveLandscape();
    _initializePlayer();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.removeListener(_onControllerTick);
    _controller?.dispose();
    _restorePortraitMode();
    super.dispose();
  }

  Future<void> _enterImmersiveLandscape() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _restorePortraitMode() async {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  Future<void> _initializePlayer() async {
    setState(() {
      _initializing = true;
      _hasError = false;
    });

    final url = widget.video.videoUrl;
    if (url.trim().isEmpty) {
      setState(() {
        _initializing = false;
        _hasError = true;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    _controller = controller;
    try {
      await controller.initialize();
      controller.addListener(_onControllerTick);
      await controller.play();
      if (!mounted) return;
      setState(() => _initializing = false);
      _scheduleAutoHide();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _hasError = true;
      });
    }
  }

  void _onControllerTick() {
    final controller = _controller;
    if (controller == null || !mounted) return;
    final value = controller.value;
    final hasEnded = value.isInitialized &&
        value.duration.inMilliseconds > 0 &&
        value.position >= value.duration &&
        !value.isPlaying;

    if (hasEnded && !_completed) {
      _hideTimer?.cancel();
      setState(() {
        _completed = true;
        _controlsVisible = true;
      });
    }
  }

  void _scheduleAutoHide() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 3000), () {
      if (!mounted) return;
      final controller = _controller;
      if (controller != null && controller.value.isPlaying) {
        setState(() => _controlsVisible = false);
      }
    });
  }

  void _showControls() {
    setState(() => _controlsVisible = true);
    _scheduleAutoHide();
  }

  void _onTapVideoArea() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _togglePlayPause() {
    final controller = _controller;
    if (controller == null) return;
    if (_completed) {
      _replay();
      return;
    }
    if (controller.value.isPlaying) {
      controller.pause();
      _hideTimer?.cancel();
    } else {
      controller.play();
      _scheduleAutoHide();
    }
    setState(() => _controlsVisible = true);
  }

  void _replay() {
    final controller = _controller;
    if (controller == null) return;
    controller.seekTo(Duration.zero);
    controller.play();
    setState(() => _completed = false);
    _scheduleAutoHide();
  }

  void _seekBy(Duration offset) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final duration = controller.value.duration;
    var target = controller.value.position + offset;
    if (target < Duration.zero) target = Duration.zero;
    if (target > duration) target = duration;
    controller.seekTo(target);
    _showControls();
  }

  void _toggleMute() {
    final controller = _controller;
    if (controller == null) return;
    setState(() {
      if (_isMuted) {
        controller.setVolume(_volumeBeforeMute == 0 ? 1.0 : _volumeBeforeMute);
        _isMuted = false;
      } else {
        _volumeBeforeMute = controller.value.volume;
        controller.setVolume(0);
        _isMuted = true;
      }
    });
    _showControls();
  }

  void _onSeekBarDragStart() {
    _hideTimer?.cancel();
    setState(() => _controlsVisible = true);
  }

  void _onSeekBarChanged(Duration position) {
    _controller?.seekTo(position);
  }

  void _onSeekBarDragEnd() {
    _scheduleAutoHide();
  }

  void _close() {
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onTapVideoArea,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildVideoArea(),
            AnimatedOpacity(
              opacity: _controlsVisible ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: IgnorePointer(
                ignoring: !_controlsVisible,
                child: (_controller != null && _controller!.value.isInitialized)
                    ? VideoControlsOverlay(
                        controller: _controller!,
                        completed: _completed,
                        isMuted: _isMuted,
                        onClose: _close,
                        onPlayPause: _togglePlayPause,
                        onReplay: _replay,
                        onSeekBackward: () => _seekBy(const Duration(seconds: -10)),
                        onSeekForward: () => _seekBy(const Duration(seconds: 10)),
                        onToggleMute: _toggleMute,
                        onSeekBarDragStart: _onSeekBarDragStart,
                        onSeekBarChanged: _onSeekBarChanged,
                        onSeekBarDragEnd: _onSeekBarDragEnd,
                      )
                    : _buildMinimalCloseButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoArea() {
    if (_hasError) {
      return _buildErrorState();
    }
    final controller = _controller;
    if (_initializing || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }
    return Center(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildErrorState() {
    return Stack(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 40),
                const SizedBox(height: 14),
                const Text(
                  'Impossible de lire cette vidéo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(height: 18),
                OutlinedButton(
                  onPressed: _initializePlayer,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                  ),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
        _buildMinimalCloseButton(),
      ],
    );
  }

  Widget _buildMinimalCloseButton() {
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _close,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}
