import 'package:desktop_drop/desktop_drop.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _teal = Color(0xFF2F8E94);

class DropZone extends StatelessWidget {
  const DropZone({
    super.key,
    required this.dragging,
    required this.loading,
    required this.onDragging,
    required this.onDrop,
    required this.onPick,
  });

  final bool dragging;
  final bool loading;
  final ValueChanged<bool> onDragging;
  final ValueChanged<List<XFile>> onDrop;
  final VoidCallback onPick;

  // On mobile/web there is no real drag source, so the whole zone is a tap target.
  static bool get _tapZone =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final accent = dragging ? _teal : const Color(0xFF5C656B);
    Widget zone = Container(
      height: 180,
      decoration: BoxDecoration(
        color: dragging ? _teal.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      foregroundDecoration: _DashedBorder(
        dragging ? _teal : const Color(0xFFC7D1D6),
      ),
      child: Center(
        child: loading
            ? const CircularProgressIndicator(color: _teal)
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.upload_file, size: 36, color: accent),
                  const SizedBox(height: 8),
                  const Text(
                    'Drag & drop a file here',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF33434C),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'or',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A9399)),
                  ),
                  const SizedBox(height: 8),
                  FilledButton(
                    onPressed: onPick,
                    style: FilledButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: const Text('Choose file'),
                  ),
                ],
              ),
      ),
    );
    if (_tapZone && !loading) {
      zone = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPick,
        child: zone,
      );
    }
    return DropTarget(
      enable: !loading,
      onDragEntered: (_) => onDragging(true),
      onDragExited: (_) => onDragging(false),
      onDragDone: (d) => onDrop(d.files),
      child: zone,
    );
  }
}

class _DashedBorder extends Decoration {
  const _DashedBorder(this.color);
  final Color color;

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) =>
      _DashedPainter(color);
}

class _DashedPainter extends BoxPainter {
  _DashedPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration cfg) {
    final size = cfg.size;
    if (size == null) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final rrect = RRect.fromRectAndRadius(
      (offset & size).deflate(0.75),
      const Radius.circular(8),
    );
    final path = Path()..addRRect(rrect);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 10) {
        canvas.drawPath(m.extractPath(d, (d + 6).clamp(0, m.length)), paint);
      }
    }
  }
}
