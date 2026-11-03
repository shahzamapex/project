import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/drawing_model.dart';
import '../theme/app_theme.dart';

class MarkupCanvas extends StatefulWidget {
  final List<DrawingStroke> existingStrokes;
  final List<AnnotationNote> existingAnnotations;
  final Function(List<DrawingStroke> strokes, List<AnnotationNote> annotations) onMarkupUpdated;
  final bool isInteractive;

  const MarkupCanvas({
    super.key,
    required this.existingStrokes,
    required this.existingAnnotations,
    required this.onMarkupUpdated,
    this.isInteractive = true,
  });

  @override
  State<MarkupCanvas> createState() => _MarkupCanvasState();
}

class _MarkupCanvasState extends State<MarkupCanvas> {
  late List<DrawingStroke> _strokes;
  late List<AnnotationNote> _annotations;
  
  // Current active drawing state
  String _activeTool = 'pen'; // 'pen', 'cloud', 'arrow', 'highlighter'
  Color _activeColor = const Color(0xFFEF4444); // Red default for markup
  double _activeStrokeWidth = 3.0;

  List<StrokePoint> _currentPoints = [];

  @override
  void initState() {
    super.initState();
    _strokes = List.from(widget.existingStrokes);
    _annotations = List.from(widget.existingAnnotations);
  }

  @override
  void didUpdateWidget(covariant MarkupCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.existingStrokes != oldWidget.existingStrokes) {
      _strokes = List.from(widget.existingStrokes);
    }
    if (widget.existingAnnotations != oldWidget.existingAnnotations) {
      _annotations = List.from(widget.existingAnnotations);
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isInteractive) return;
    setState(() {
      _currentPoints = [StrokePoint(x: details.localPosition.dx, y: details.localPosition.dy)];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isInteractive) return;
    setState(() {
      _currentPoints.add(StrokePoint(x: details.localPosition.dx, y: details.localPosition.dy));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isInteractive || _currentPoints.isEmpty) return;

    setState(() {
      _strokes.add(DrawingStroke(
        tool: _activeTool,
        colorHex: _colorToHex(_activeColor),
        strokeWidth: _activeTool == 'highlighter' ? 14.0 : _activeStrokeWidth,
        points: List.from(_currentPoints),
      ));
      _currentPoints = [];
    });
    widget.onMarkupUpdated(_strokes, _annotations);
  }

  void _showAddNoteDialog(Offset position) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: const Text("Add Architectural Callout Note", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "e.g. Verify 40mm rough-in clearance",
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _annotations.add(AnnotationNote(
                    id: "note-${DateTime.now().millisecondsSinceEpoch}",
                    x: position.dx,
                    y: position.dy,
                    text: controller.text.trim(),
                    colorHex: _colorToHex(_activeColor),
                  ));
                });
                widget.onMarkupUpdated(_strokes, _annotations);
              }
              Navigator.pop(ctx);
            },
            child: const Text("Place Note"),
          ),
        ],
      ),
    );
  }

  void _undo() {
    if (_strokes.isNotEmpty) {
      setState(() => _strokes.removeLast());
      widget.onMarkupUpdated(_strokes, _annotations);
    } else if (_annotations.isNotEmpty) {
      setState(() => _annotations.removeLast());
      widget.onMarkupUpdated(_strokes, _annotations);
    }
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _annotations.clear();
      _currentPoints.clear();
    });
    widget.onMarkupUpdated(_strokes, _annotations);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top Toolbar
        if (widget.isInteractive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              children: [
                // Tool selection
                _toolButton('pen', Icons.edit_outlined, "Pen"),
                const SizedBox(width: 6),
                _toolButton('cloud', Icons.cloud_queue_outlined, "Revision Cloud"),
                const SizedBox(width: 6),
                _toolButton('arrow', Icons.arrow_outward, "Arrow Pointer"),
                const SizedBox(width: 6),
                _toolButton('highlighter', Icons.brush_outlined, "Highlighter"),
                const SizedBox(width: 14),
                Container(height: 24, width: 1, color: AppTheme.surfaceBorder),
                const SizedBox(width: 14),

                // Color picker dots
                _colorDot(const Color(0xFFEF4444)),
                _colorDot(const Color(0xFFD4AF37)),
                _colorDot(const Color(0xFF0EA5E9)),
                _colorDot(const Color(0xFF10B981)),
                _colorDot(const Color(0xFFF59E0B)),

                const Spacer(),

                // Note tool
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Click anywhere on the blueprint to place an architectural note.")),
                    );
                  },
                  icon: const Icon(Icons.sticky_note_2_outlined, size: 16),
                  label: const Text("Note Tool", style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                ),
                const SizedBox(width: 8),

                IconButton(
                  tooltip: "Undo Stroke",
                  icon: const Icon(Icons.undo, color: AppTheme.textMuted, size: 20),
                  onPressed: _strokes.isEmpty && _annotations.isEmpty ? null : _undo,
                ),
                IconButton(
                  tooltip: "Clear All Markups",
                  icon: const Icon(Icons.delete_outline, color: AppTheme.roseDanger, size: 20),
                  onPressed: _strokes.isEmpty && _annotations.isEmpty ? null : _clearAll,
                ),
              ],
            ),
          ),

        // Drawing Area with CustomPaint & GestureDetector
        Expanded(
          child: GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            onDoubleTapDown: (details) {
              if (widget.isInteractive) {
                _showAddNoteDialog(details.localPosition);
              }
            },
            child: CustomPaint(
              size: Size.infinite,
              painter: DrawingMarkupPainter(
                strokes: _strokes,
                annotations: _annotations,
                currentPoints: _currentPoints,
                currentTool: _activeTool,
                currentColor: _activeColor,
                currentStrokeWidth: _activeTool == 'highlighter' ? 14.0 : _activeStrokeWidth,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _toolButton(String tool, IconData icon, String label) {
    final isSelected = _activeTool == tool;
    return InkWell(
      onTap: () => setState(() => _activeTool = tool),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? AppTheme.goldPrimary : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted, fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }

  Widget _colorDot(Color color) {
    final isSelected = _activeColor == color;
    return InkWell(
      onTap: () => setState(() => _activeColor = color),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? Colors.white : Colors.transparent, width: 2),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.5), blurRadius: 6)] : null,
        ),
      ),
    );
  }
}

class DrawingMarkupPainter extends CustomPainter {
  final List<DrawingStroke> strokes;
  final List<AnnotationNote> annotations;
  final List<StrokePoint> currentPoints;
  final String currentTool;
  final Color currentColor;
  final double currentStrokeWidth;

  DrawingMarkupPainter({
    required this.strokes,
    required this.annotations,
    required this.currentPoints,
    required this.currentTool,
    required this.currentColor,
    required this.currentStrokeWidth,
  });

  Color _parseHex(String hex, {double opacity = 1.0}) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex";
    return Color(int.parse(hex, radix: 16)).withOpacity(opacity);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Render all committed strokes
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke.tool, _parseHex(stroke.colorHex), stroke.strokeWidth, stroke.points);
    }

    // 2. Render live stroke
    if (currentPoints.isNotEmpty) {
      _drawStroke(canvas, currentTool, currentColor, currentStrokeWidth, currentPoints);
    }

    // 3. Render callout text annotations
    for (final note in annotations) {
      _drawAnnotation(canvas, note);
    }
  }

  void _drawStroke(Canvas canvas, String tool, Color color, double strokeWidth, List<StrokePoint> points) {
    if (points.isEmpty) return;

    if (tool == 'cloud') {
      _drawCloud(canvas, points, color, strokeWidth);
    } else if (tool == 'arrow') {
      _drawArrow(canvas, points, color, strokeWidth);
    } else if (tool == 'highlighter') {
      _drawFreehand(canvas, points, color.withOpacity(0.35), strokeWidth);
    } else {
      _drawFreehand(canvas, points, color, strokeWidth);
    }
  }

  void _drawFreehand(Canvas canvas, List<StrokePoint> points, Color color, double strokeWidth) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.x, points.first.y);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].x, points[i].y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawCloud(Canvas canvas, List<StrokePoint> points, Color color, double strokeWidth) {
    if (points.length < 2) return;
    // Bounding rect from points
    double minX = points.map((p) => p.x).reduce(math.min);
    double maxX = points.map((p) => p.x).reduce(math.max);
    double minY = points.map((p) => p.y).reduce(math.min);
    double maxY = points.map((p) => p.y).reduce(math.max);

    if (maxX - minX < 20 || maxY - minY < 20) {
      maxX = minX + 60;
      maxY = minY + 40;
    }

    final rect = Rect.fromLTRB(minX, minY, maxX, maxY);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    // Draw scalloped revision cloud
    final path = Path();
    const double arcRadius = 14.0;
    
    // Top edge
    for (double x = rect.left; x < rect.right; x += arcRadius * 1.6) {
      path.addArc(Rect.fromCircle(center: Offset(x + arcRadius, rect.top), radius: arcRadius), math.pi, math.pi);
    }
    // Right edge
    for (double y = rect.top; y < rect.bottom; y += arcRadius * 1.6) {
      path.addArc(Rect.fromCircle(center: Offset(rect.right, y + arcRadius), radius: arcRadius), -math.pi / 2, math.pi);
    }
    // Bottom edge
    for (double x = rect.right; x > rect.left; x -= arcRadius * 1.6) {
      path.addArc(Rect.fromCircle(center: Offset(x - arcRadius, rect.bottom), radius: arcRadius), 0, math.pi);
    }
    // Left edge
    for (double y = rect.bottom; y > rect.top; y -= arcRadius * 1.6) {
      path.addArc(Rect.fromCircle(center: Offset(rect.left, y - arcRadius), radius: arcRadius), math.pi / 2, math.pi);
    }

    canvas.drawRect(rect, fillPaint);
    canvas.drawPath(path, paint);
  }

  void _drawArrow(Canvas canvas, List<StrokePoint> points, Color color, double strokeWidth) {
    if (points.length < 2) return;
    final start = Offset(points.first.x, points.first.y);
    final end = Offset(points.last.x, points.last.y);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(start, end, linePaint);

    // Arrowhead at end
    final angle = math.atan2(end.dy - start.dy, end.dx - start.dx);
    const arrowLength = 16.0;
    const arrowAngle = math.pi / 6;

    final p1 = Offset(
      end.dx - arrowLength * math.cos(angle - arrowAngle),
      end.dy - arrowLength * math.sin(angle - arrowAngle),
    );
    final p2 = Offset(
      end.dx - arrowLength * math.cos(angle + arrowAngle),
      end.dy - arrowLength * math.sin(angle + arrowAngle),
    );

    final arrowPath = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(p1.dx, p1.dy)
      ..lineTo(p2.dx, p2.dy)
      ..close();

    final headPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(arrowPath, headPaint);
  }

  void _drawAnnotation(Canvas canvas, AnnotationNote note) {
    final textSpan = TextSpan(
      text: "💬 ${note.text}",
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        backgroundColor: Color(0xDD0F172A),
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final bgRect = Rect.fromLTWH(
      note.x - 6,
      note.y - 6,
      textPainter.width + 12,
      textPainter.height + 12,
    );
    final rrect = RRect.fromRectAndRadius(bgRect, const Radius.circular(6));

    final bgPaint = Paint()..color = const Color(0xEE1E293B);
    final borderPaint = Paint()
      ..color = _parseHex(note.colorHex)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawRRect(rrect, bgPaint);
    canvas.drawRRect(rrect, borderPaint);
    textPainter.paint(canvas, Offset(note.x, note.y));
  }

  @override
  bool shouldRepaint(covariant DrawingMarkupPainter oldDelegate) => true;
}
