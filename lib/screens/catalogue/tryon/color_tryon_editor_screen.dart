import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/color_tryon_selection.dart';
import '../../../services/image_save_service.dart';
import 'widgets/mask_stroke.dart';
import 'widgets/tryon_tool_dock.dart';
import 'widgets/wall_color_painter.dart';

/// Éditeur Color Try-On plein écran : permet de peindre manuellement la
/// couleur sélectionnée (venant de Firebase) sur la zone du mur indiquée
/// par l'utilisateur, sur la photo qu'il vient de prendre ou de choisir.
class ColorTryOnEditorScreen extends StatefulWidget {
  final XFile imageFile;
  final ColorTryOnSelection selection;

  const ColorTryOnEditorScreen({super.key, required this.imageFile, required this.selection});

  @override
  State<ColorTryOnEditorScreen> createState() => _ColorTryOnEditorScreenState();
}

class _ColorTryOnEditorScreenState extends State<ColorTryOnEditorScreen> {
  final GlobalKey _repaintKey = GlobalKey();
  final TransformationController _transformController = TransformationController();

  ui.Image? _image;
  final List<MaskStroke> _strokes = [];
  MaskStroke? _activeStroke;

  TryOnTool _tool = TryOnTool.brush;
  double _brushSize = 40;
  bool _showAfter = true;
  bool _saving = false;

  TapDownDetails? _lastDoubleTapDetails;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final bytes = await widget.imageFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    if (!mounted) return;
    setState(() => _image = frame.image);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onPanStart(DragStartDetails details) {
    if (_tool == TryOnTool.pan) return;
    setState(() {
      _activeStroke = MaskStroke(brushSize: _brushSize, isEraser: _tool == TryOnTool.eraser)
        ..addPoint(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_tool == TryOnTool.pan || _activeStroke == null) return;
    setState(() => _activeStroke!.addPoint(details.localPosition));
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeStroke == null) return;
    setState(() {
      _strokes.add(_activeStroke!);
      _activeStroke = null;
    });
  }

  void _handleDoubleTap() {
    final position = _lastDoubleTapDetails?.localPosition;
    if (position == null) return;
    final isZoomed = _transformController.value.getMaxScaleOnAxis() > 1.05;
    if (isZoomed) {
      _transformController.value = Matrix4.identity();
    } else {
      const scale = 2.5;
      _transformController.value = Matrix4.identity()
        ..translate(-position.dx * (scale - 1), -position.dy * (scale - 1))
        ..scale(scale);
    }
  }

  Future<void> _handleSave() async {
    if (_image == null || _saving) return;
    setState(() => _saving = true);

    final wasShowingBefore = !_showAfter;
    if (wasShowingBefore) {
      setState(() => _showAfter = true);
      // Laisse le painter se redessiner en mode "Après" avant la capture.
      await Future.delayed(const Duration(milliseconds: 30));
    }

    try {
      final boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('capture indisponible');
      final captured = await boundary.toImage(pixelRatio: 2.5);
      final byteData = await captured.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) throw Exception('encodage impossible');
      final Uint8List bytes = byteData.buffer.asUint8List();

      final result = await ImageSaveService.saveImageBytes(
        bytes,
        name: 'master_sud_${widget.selection.colorCode}',
      );

      if (!mounted) return;
      switch (result) {
        case SaveImageResult.success:
          _showSnack('Image enregistrée avec succès.');
          break;
        case SaveImageResult.permissionDenied:
          _showSnack("Veuillez autoriser l'accès aux photos dans les réglages pour enregistrer l'image.");
          break;
        case SaveImageResult.failure:
          _showSnack("Une erreur est survenue lors de l'enregistrement.");
          break;
      }
    } catch (_) {
      if (mounted) _showSnack("Une erreur est survenue lors de l'enregistrement.");
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          if (wasShowingBefore) _showAfter = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF10131A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(child: _buildWorkspace()),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: widget.selection.hexColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.selection.colorCode,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkspace() {
    final image = _image;
    if (image == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: GestureDetector(
              onDoubleTapDown: (details) => _lastDoubleTapDetails = details,
              onDoubleTap: _handleDoubleTap,
              child: InteractiveViewer(
                transformationController: _transformController,
                minScale: 1,
                maxScale: 5,
                panEnabled: _tool == TryOnTool.pan,
                scaleEnabled: _tool == TryOnTool.pan,
                child: RepaintBoundary(
                  key: _repaintKey,
                  child: GestureDetector(
                    onPanStart: _tool == TryOnTool.pan ? null : _onPanStart,
                    onPanUpdate: _tool == TryOnTool.pan ? null : _onPanUpdate,
                    onPanEnd: _tool == TryOnTool.pan ? null : _onPanEnd,
                    child: CustomPaint(
                      size: size,
                      painter: WallColorPainter(
                        image: image,
                        strokes: _strokes,
                        activeStroke: _activeStroke,
                        paintColor: widget.selection.hexColor,
                        showAfter: _showAfter,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TryOnToolDock(
            tool: _tool,
            brushSize: _brushSize,
            onToolChanged: (tool) => setState(() => _tool = tool),
            onBrushSizeChanged: (value) => setState(() => _brushSize = value),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _showAfter = false),
                  onTapUp: (_) => setState(() => _showAfter = true),
                  onTapCancel: () => setState(() => _showAfter = true),
                  child: Container(
                    height: 54,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      _showAfter ? 'Avant / Après' : 'Avant',
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _saving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192E52),
                disabledBackgroundColor: const Color(0xFF192E52).withOpacity(0.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text(
                      'Enregistrer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
