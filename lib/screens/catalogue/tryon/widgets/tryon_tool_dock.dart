import 'package:flutter/material.dart';

enum TryOnTool { pan, brush, eraser }

/// Sélecteur d'outil (déplacement/zoom, pinceau, gomme) + réglage de la
/// taille du pinceau, affiché en bas de l'éditeur Color Try-On.
class TryOnToolDock extends StatelessWidget {
  final TryOnTool tool;
  final double brushSize;
  final ValueChanged<TryOnTool> onToolChanged;
  final ValueChanged<double> onBrushSizeChanged;

  const TryOnToolDock({
    super.key,
    required this.tool,
    required this.brushSize,
    required this.onToolChanged,
    required this.onBrushSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1F2A),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolButton(
                icon: Icons.pan_tool_alt_outlined,
                label: 'Déplacer',
                selected: tool == TryOnTool.pan,
                onTap: () => onToolChanged(TryOnTool.pan),
              ),
              _ToolButton(
                icon: Icons.brush_rounded,
                label: 'Pinceau',
                selected: tool == TryOnTool.brush,
                onTap: () => onToolChanged(TryOnTool.brush),
              ),
              _ToolButton(
                icon: Icons.auto_fix_normal_rounded,
                label: 'Gomme',
                selected: tool == TryOnTool.eraser,
                onTap: () => onToolChanged(TryOnTool.eraser),
              ),
            ],
          ),
          if (tool != TryOnTool.pan) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.circle, size: 10, color: Colors.white54),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white24,
                      thumbColor: Colors.white,
                      overlayColor: Colors.white24,
                    ),
                    child: Slider(
                      value: brushSize,
                      min: 10,
                      max: 100,
                      onChanged: onBrushSizeChanged,
                    ),
                  ),
                ),
                const Icon(Icons.circle, size: 18, color: Colors.white54),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.white : Colors.white54;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
