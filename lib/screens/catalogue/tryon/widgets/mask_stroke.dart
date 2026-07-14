import 'package:flutter/material.dart';

/// Un trait de pinceau ou de gomme, en coordonnées locales de la zone de
/// travail de l'éditeur (mêmes coordonnées que le CustomPainter).
class MaskStroke {
  final List<Offset> points = [];
  final double brushSize;
  final bool isEraser;

  MaskStroke({required this.brushSize, required this.isEraser});

  void addPoint(Offset point) => points.add(point);

  bool get isDrawable => points.length > 1;
}
