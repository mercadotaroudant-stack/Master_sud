import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/video_model.dart';
import '../../repositories/video_repository.dart';
import 'player/video_player_screen.dart';
import 'widgets/formation_app_bar.dart';
import 'widgets/formation_card.dart';
import 'widgets/formation_card_skeleton.dart';
import 'widgets/formation_empty_state.dart';

/// Page "Formation" : grille 2 colonnes des vidéos de formation, gérées en
/// temps réel depuis le Dashboard/Firebase (ajout, édition, activation,
/// désactivation, suppression, ordre d'affichage).
class FormationScreen extends StatefulWidget {
  const FormationScreen({super.key});

  @override
  State<FormationScreen> createState() => _FormationScreenState();
}

class _FormationScreenState extends State<FormationScreen> {
  final VideoRepository _repository = FirebaseVideoRepository();

  void _openVideo(VideoModel video) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fmBackground,
      body: SafeArea(
        child: Column(
          children: [
            FormationAppBar(title: 'Formation', onBack: () => Navigator.of(context).maybePop()),
            Expanded(
              child: StreamBuilder<List<VideoModel>>(
                stream: _repository.streamActiveVideos(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildSkeleton();
                  }
                  if (snapshot.hasError) {
                    return const FormationEmptyState(
                      icon: Icons.wifi_off_rounded,
                      message: 'Impossible de charger les vidéos pour le moment.',
                    );
                  }

                  final videos = snapshot.data ?? [];
                  if (videos.isEmpty) {
                    return const FormationEmptyState(
                      message: 'Aucune vidéo de formation disponible.',
                    );
                  }

                  return _buildGrid(videos);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(List<VideoModel> videos) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisSpacing = 13.0;
        const mainAxisSpacing = 16.0;

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              sliver: SliverToBoxAdapter(
                child: Text(
                  'VIDÉOS DE FORMATION',
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: AppColors.fmTitle,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: crossAxisSpacing,
                  mainAxisSpacing: mainAxisSpacing,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final video = videos[index];
                    return FormationCard(video: video, onTap: () => _openVideo(video));
                  },
                  childCount: videos.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSkeleton() {
    return CustomScrollView(
      physics: const NeverScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Text(
              'VIDÉOS DE FORMATION',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
                color: AppColors.fmTitle,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 16,
              childAspectRatio: 0.72,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const FormationCardSkeleton(),
              childCount: 6,
            ),
          ),
        ),
      ],
    );
  }
}
