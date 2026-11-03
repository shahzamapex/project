import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/drawing_model.dart';
import '../theme/app_theme.dart';
import '../widgets/markup_canvas.dart';

class DrawingMarkupCenter extends StatefulWidget {
  const DrawingMarkupCenter({super.key});

  @override
  State<DrawingMarkupCenter> createState() => _DrawingMarkupCenterState();
}

class _DrawingMarkupCenterState extends State<DrawingMarkupCenter> {
  bool _isDrawingMode = true; // true = draw markup, false = pan & zoom
  final TransformationController _transformController = TransformationController();

  List<DrawingStroke> _pendingStrokes = [];
  List<AnnotationNote> _pendingNotes = [];
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = Provider.of<AppState>(context, listen: false);
    if (state.markups.isNotEmpty) {
      _pendingStrokes = List.from(state.markups.first.strokes);
      _pendingNotes = List.from(state.markups.first.annotations);
    }
  }

  void _saveCurrentMarkups(AppState state) async {
    final drawing = state.selectedDrawing;
    if (drawing == null) return;

    final newMarkup = DrawingMarkupModel(
      id: "mk-${DateTime.now().millisecondsSinceEpoch}",
      drawingId: drawing.id,
      authorName: state.currentUser.fullName,
      authorRole: state.userRole,
      strokes: List.from(_pendingStrokes),
      annotations: List.from(_pendingNotes),
      comment: _commentController.text.trim().isNotEmpty
          ? _commentController.text.trim()
          : "Site revision markup added on ${DateTime.now().toString().substring(0, 10)}",
      createdAt: DateTime.now().toIsoformatString(),
    );

    await state.addDrawingMarkup(newMarkup);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Vector markups saved successfully to Supabase.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final drawings = state.drawings;
    final selectedDrawing = state.selectedDrawing ?? (drawings.isNotEmpty ? drawings.first : null);
    final markups = state.markups;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      const Text(
                        "Architectural Drawing & Markup Center",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                      ),
                      if (selectedDrawing != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.goldPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.goldPrimary),
                          ),
                          child: Text(
                            "${selectedDrawing.sheetNumber} • ${selectedDrawing.revision}",
                            style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "InteractiveViewer Blueprint Zoom with CustomPaint Vector Markup Overlay (Pen, Clouds, Pointers, Notes)",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              Wrap(
                spacing: 14,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  // Mode Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _modeButton(
                          isActive: _isDrawingMode,
                          icon: Icons.edit_outlined,
                          label: "Markup Mode",
                          onTap: () => setState(() => _isDrawingMode = true),
                        ),
                        _modeButton(
                          isActive: !_isDrawingMode,
                          icon: Icons.pan_tool_outlined,
                          label: "Pan & Zoom",
                          onTap: () => setState(() => _isDrawingMode = false),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _saveCurrentMarkups(state),
                    icon: const Icon(Icons.cloud_upload_outlined, size: 16),
                    label: const Text("Save Markups"),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Drawing Selector Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: drawings.map((d) {
                final isSelected = selectedDrawing?.id == d.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text("${d.sheetNumber}: ${d.title} (${d.revision})"),
                    selected: isSelected,
                    selectedColor: AppTheme.goldPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : AppTheme.textLight,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    backgroundColor: AppTheme.surfaceCard,
                    onSelected: (val) {
                      if (val) state.selectDrawing(d);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Main Workspace: Drawing Canvas on Left, Markup Notes on Right
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blueprint Viewer with InteractiveViewer and MarkupCanvas overlay
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF070B14), // Deep blueprint background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // InteractiveViewer handles smooth pan and zoom
                        InteractiveViewer(
                          transformationController: _transformController,
                          panEnabled: !_isDrawingMode,
                          scaleEnabled: !_isDrawingMode,
                          minScale: 0.6,
                          maxScale: 4.0,
                          child: Stack(
                            children: [
                              // Architectural Blueprint CAD Graphic simulation
                              CustomPaint(
                                size: const Size(1200, 800),
                                painter: BlueprintPlanPainter(title: selectedDrawing?.title ?? "Floor Layout Plan"),
                              ),

                              // CustomPaint & GestureDetector Markup Canvas Layer
                              Positioned.fill(
                                child: MarkupCanvas(
                                  existingStrokes: _pendingStrokes,
                                  existingAnnotations: _pendingNotes,
                                  isInteractive: _isDrawingMode,
                                  onMarkupUpdated: (strokes, notes) {
                                    _pendingStrokes = strokes;
                                    _pendingNotes = notes;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Mode indicator badge
                        Positioned(
                          bottom: 14,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _isDrawingMode ? AppTheme.goldPrimary : AppTheme.tealAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isDrawingMode ? Icons.edit : Icons.zoom_in,
                                  size: 14,
                                  color: _isDrawingMode ? AppTheme.goldPrimary : AppTheme.tealAccent,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isDrawingMode ? "DRAWING MODE: Click & drag to draw clouds/arrows" : "PAN & ZOOM MODE: Scroll / pinch to zoom CAD drawing",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _isDrawingMode ? AppTheme.goldPrimary : AppTheme.tealAccent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 18),

                // Markup Revisions & Notes Sidebar
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.history_edu, color: AppTheme.goldPrimary, size: 20),
                            SizedBox(width: 8),
                            Text("Markup Layers & History", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Markups are saved as vector layers associated with this drawing sheet in Supabase.",
                          style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          maxLines: 2,
                          decoration: const InputDecoration(
                            hintText: "Add revision comment for this markup layer...",
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(color: AppTheme.surfaceBorder),
                        const SizedBox(height: 8),
                        const Text("Committed Site Markups", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.separated(
                            itemCount: markups.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final m = markups[index];
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.surfaceDark,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.surfaceBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(m.authorName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                                        Text(m.authorRole.toUpperCase(), style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(m.comment, style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.3)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.draw, size: 12, color: AppTheme.textMuted),
                                        const SizedBox(width: 4),
                                        Text("${m.strokes.length} strokes • ${m.annotations.length} callouts", style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton({required bool isActive, required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.goldPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.black : AppTheme.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : AppTheme.textMuted,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension DateTimeFormat on DateTime {
  String toIsoformatString() => toIso8601String();
}

class BlueprintPlanPainter extends CustomPainter {
  final String title;
  BlueprintPlanPainter({required this.title});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF1E2B45).withOpacity(0.4)
      ..strokeWidth = 0.5;

    // Draw CAD Grid
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final wallPaint = Paint()
      ..color = const Color(0xFF64B5F6)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final thinPaint = Paint()
      ..color = const Color(0xFF90CAF9).withOpacity(0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Draw Perimeter walls of Penthouse Suite
    canvas.drawRect(const Rect.fromLTWH(80, 80, 840, 560), wallPaint);

    // Interior Rooms
    // Master Suite
    canvas.drawRect(const Rect.fromLTWH(80, 80, 360, 280), wallPaint);
    // Master Bath / Calacatta island
    canvas.drawRect(const Rect.fromLTWH(80, 360, 240, 280), wallPaint);
    // Island marble
    canvas.drawRect(const Rect.fromLTWH(140, 440, 120, 80), Paint()..color = const Color(0xFF64B5F6).withOpacity(0.2));
    canvas.drawRect(const Rect.fromLTWH(140, 440, 120, 80), thinPaint);

    // Living Gallery Pavilion
    canvas.drawRect(const Rect.fromLTWH(440, 80, 480, 360), wallPaint);
    // Custom Fluted Walnut Wall indication
    for (double x = 460; x < 900; x += 15) {
      canvas.drawLine(Offset(x, 90), Offset(x, 110), thinPaint);
    }

    // Kitchen & Dining
    canvas.drawRect(const Rect.fromLTWH(320, 440, 340, 200), wallPaint);

    // Text labels
    _drawText(canvas, "MASTER SUITE (OAK PARQUET)", 120, 140);
    _drawText(canvas, "LIVING GALLERY (FLUTED WALNUT)", 500, 200);
    _drawText(canvas, "WATERFALL MARBLE ISLAND", 140, 540);
    _drawText(canvas, "CHEF KITCHEN & DINING", 360, 520);
    _drawText(canvas, "ARCHITECTURAL SHEET: A-102 • $title", 100, 680, isHeader: true);
  }

  void _drawText(Canvas canvas, String text, double x, double y, {bool isHeader = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: isHeader ? const Color(0xFFD4AF37) : const Color(0xFF90CAF9),
        fontSize: isHeader ? 14 : 11,
        fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
        letterSpacing: 0.8,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(x, y));
  }

  @override
  bool shouldRepaint(covariant BlueprintPlanPainter oldDelegate) => false;
}
