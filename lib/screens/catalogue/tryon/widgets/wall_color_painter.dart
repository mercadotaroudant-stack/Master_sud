import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'mask_stroke.dart';

/// Peint l'image de base puis, si [showAfter] est vrai, superpose la
/// couleur sélectionnée uniquement sur la zone peinte au pinceau
/// ([strokes] + [activeStroke]), en préservant la lumière, les ombres et
/// la texture du mur d'origine.
///
/// Technique : la couleur est appliquée avec BlendMode.color (garde la
/// luminosité de la photo, remplace seulement teinte/saturation), puis le
/// résultat est restreint à la zone peinte via un second calque composé
/// avec BlendMode.dstIn — jamais un aplat opaque plaqué sur l'image.
class WallColorPainter extends CustomPainter {
  final ui.Image image;
  final List<MaskStroke> strokes;
  final MaskStroke? activeStroke;
  final Color paintColor;
  final bool showAfter;

  WallColorPainter({
    required this.image,
    required this.strokes,
    required this.activeStroke,
    required this.paintColor,
    required this.showAfter,
  });

  Rect _imageRect(Size size) => Rect.fromLTWH(0, 0, size.width, size.height);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = _imageRect(size);

    // Base : la photo d'origine, toujours visible en dehors des zones peintes.
    paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.contain);

    if (!showAfter) return; // Mode "Avant" : image d'origine uniquement.

    final allStrokes = [...strokes, if (activeStroke != null) activeStroke!]
        .where((s) => s.isDrawable)
        .toList();
    if (allStrokes.isEmpty) return;

    // Calque A : version entièrement recolorée de l'image.
    canvas.saveLayer(rect, Paint());
    paintImage(canvas: canvas, rect: rect, image: image, fit: BoxFit.contain);
    canvas.drawRect(
      rect,
      Paint()
        ..color = paintColor
        ..blendMode = BlendMode.color,
    );

    // Calque B : masque construit à partir des traits (pinceau = ajoute,
    // gomme = retire), composé sur le calque A via dstIn pour ne garder
    // que la zone réellement peinte par l'utilisateur.
    canvas.saveLayer(rect, Paint()..blendMode = BlendMode.dstIn);
    for (final stroke in allStrokes) {
      final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (final point in stroke.points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      final maskPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke.brushSize
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5)
        ..blendMode = stroke.isEraser ? BlendMode.clear : BlendMode.srcOver;
      canvas.drawPath(path, maskPaint);
    }
    canvas.restore(); // composite du masque sur le calque A (dstIn)

    canvas.restore(); // composite du calque A recolorée+masquée sur l'image de base
  }

  @override
  bool shouldRepaint(covariant WallColorPainter oldDelegate) => true;
}
