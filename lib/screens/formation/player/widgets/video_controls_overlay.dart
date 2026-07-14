import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../constants/app_colors.dart';

/// Contrôles custom superposés au lecteur vidéo plein écran : back, play/pause,
/// avance/recul 10s, barre de progression (or MASTER SUD), temps de lecture,
/// mute/unmute et action Replay en fin de vidéo.
class VideoControlsOverlay extends StatelessWidget {
  final VideoPlayerController controller;
  final bool completed;
  final bool isMuted;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;
  final VoidCallback onReplay;
  final VoidCallback onSeekBackward;
  final VoidCallback onSeekForward;
  final VoidCallback onToggleMute;
  final VoidCallback onSeekBarDragStart;
  final ValueChanged<Duration> onSeekBarChanged;
  final VoidCallback onSeekBarDragEnd;

  const VideoControlsOverlay({
    super.key,
    required this.controller,
    required this.completed,
    required this.isMuted,
    required this.onClose,
    required this.onPlayPause,
    required this.onReplay,
    required this.onSeekBackward,
    required this.onSeekForward,
    required this.onToggleMute,
    required this.onSeekBarDragStart,
    required this.onSeekBarChanged,
    required this.onSeekBarDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.45),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.55),
          ],
          stops: const [0, 0.25, 0.7, 1],
        ),
      ),
      child: Column(
        children: [
          _topBar(),
          Expanded(child: Center(child: _centerControls())),
          _bottomBar(),
        ],
      ),
    );
  }

  Widget _topBar() {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            _circleButton(icon: Icons.arrow_back_rounded, onTap: onClose, dimension: 44, iconSize: 24),
          ],
        ),
      ),
    );
  }

  Widget _centerControls() {
    if (completed) {
      return _circleButton(icon: Icons.replay_rounded, onTap: onReplay, dimension: 70, iconSize: 34);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _circleButton(icon: Icons.replay_10_rounded, onTap: onSeekBackward, dimension: 54, iconSize: 30),
        const SizedBox(width: 26),
        AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final playing = controller.value.isPlaying;
            return _circleButton(
              icon: playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
              onTap: onPlayPause,
              dimension: 68,
              iconSize: 34,
              backgroundOpacity: 0.5,
            );
          },
        ),
        const SizedBox(width: 26),
        _circleButton(icon: Icons.forward_10_rounded, onTap: onSeekForward, dimension: 54, iconSize: 30),
      ],
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final value = controller.value;
            final duration = value.duration;
            final position = value.position;
            final durationMs = duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0;
            final positionMs = position.inMilliseconds.toDouble().clamp(0.0, durationMs);

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                    activeTrackColor: AppColors.fmGold,
                    inactiveTrackColor: Colors.white.withOpacity(0.3),
                    thumbColor: AppColors.fmGold,
                    overlayColor: AppColors.fmGold.withOpacity(0.2),
                  ),
                  child: Slider(
                    min: 0,
                    max: durationMs,
                    value: positionMs,
                    onChangeStart: (_) => onSeekBarDragStart(),
                    onChanged: (v) => onSeekBarChanged(Duration(milliseconds: v.round())),
                    onChangeEnd: (v) => onSeekBarDragEnd(),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatDuration(position)} / ${_formatDuration(duration)}',
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: onToggleMute,
                      child: Icon(
                        isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    required double dimension,
    required double iconSize,
    double backgroundOpacity = 0.45,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: dimension,
        height: dimension,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(backgroundOpacity),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }

  String _formatDuration(Duration d) {
    if (d.isNegative || d == Duration.zero) return '00:00';
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '${hours.toString().padLeft(2, '0')}:$minutes:$seconds' : '$minutes:$seconds';
  }
}
