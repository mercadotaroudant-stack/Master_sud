import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/app_colors.dart';

/// Zone de vignette d'une carte vidéo Formation.
///
/// Affiche l'image réelle (BoxFit.cover) fournie par le Dashboard/Firebase.
/// Pendant le chargement : squelette neutre. En cas d'échec : état de repli
/// propre (fond navy + icône vidéo) — jamais une icône d'image cassée.
class FormationThumbnail extends StatelessWidget {
  final String? imageUrl;

  const FormationThumbnail({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.trim().isEmpty) {
      return _fallback();
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (_, __) => _skeleton(),
      errorWidget: (_, __, ___) => _fallback(),
    );
  }

  Widget _skeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.shimmerBase,
      highlightColor: AppColors.shimmerHighlight,
      child: Container(color: Colors.white),
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.fmIconNavy,
      alignment: Alignment.center,
      child: const Icon(Icons.videocam_outlined, size: 34, color: Colors.white70),
    );
  }
}
