import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class OCRTaskAutomationScreen extends StatefulWidget {
  const OCRTaskAutomationScreen({super.key});

  @override
  State<OCRTaskAutomationScreen> createState() => _OCRTaskAutomationScreenState();
}

class _OCRTaskAutomationScreenState extends State<OCRTaskAutomationScreen> {
  bool _isProcessing = false;
  String? _uploadedFileName;
  Map<String, dynamic>? _ocrResult;

  void _pickAndProcessFile(AppState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'txt'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes != null) {
        setState(() {
          _isProcessing = true;
          _uploadedFileName = file.name;
        });

        final ocrData = await state.uploadDocumentOCR(bytes, file.name);

        setState(() {
          _isProcessing = false;
          _ocrResult = ocrData;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tesseract OCR completed for '${file.name}'. ${ocrData['tasks_detected_count']} tasks mapped to ${state.selectedProject?.title}.")),
        );
      }
    }
  }

  void _runSampleDocument(AppState state) async {
    const sampleText = """
PROJECT SPECIFICATION & ARCHITECTURAL PUNCH LIST
Skyline Penthouse 42 - Calacatta & Walnut Execution

1. Inspect Calacatta Viola slabs and verify bookmatch continuity - 4 days - Critical
2. Recessed plaster cove architectural LED channels wiring - 3 days - High
3. Mount Dornbracht Tara brushed brass concealed thermostatic mixers - 2 days - Medium
4. Fit bespoke Italian fluted walnut wardrobes with integrated pulls - 6 days - High
5. Apply three coats of waterproof microcement in guest powder room - 3 days - Medium
6. Program Lutron Palladiom motorized blackout & sheer shading pockets - 2 days - Medium
7. Commission architectural lighting scenes and clean stone surfaces - 1 days - Low
""";

    final bytes = Uint8List.fromList(utf8.encode(sampleText));
    setState(() {
      _isProcessing = true;
      _uploadedFileName = "Penthouse_42_PunchList_Spec.pdf";
    });

    final ocrData = await state.uploadDocumentOCR(bytes, "Penthouse_42_PunchList_Spec.pdf");

    setState(() {
      _isProcessing = false;
      _ocrResult = ocrData;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Sample OCR extraction complete! ${ocrData['tasks_detected_count'] ?? 4} structured tasks added to ${state.selectedProject?.title}.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currentProject = state.selectedProject;
    final extractedTasks = (_ocrResult != null && _ocrResult!['tasks'] != null)
        ? (_ocrResult!['tasks'] as List)
        : [];

    return SingleChildScrollView(
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
                    runSpacing: 8,
                    children: [
                      const Text(
                        "OCR Task Automation Module",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.goldPrimary),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.smart_toy_outlined, size: 14, color: AppTheme.goldPrimary),
                            SizedBox(width: 6),
                            Text("TESSERACT OCR INTEGRATION", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Target Project: ${currentProject?.title ?? 'Penthouse 42'} • Automate Task Insertion from PDF Drawings & BoQs",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _runSampleDocument(state),
                icon: const Icon(Icons.flash_on, size: 16),
                label: const Text("Load Sample Interior BoQ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Upload Dropzone Card
          Container(
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.4), width: 1.5),
            ),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppTheme.goldPrimary.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, size: 40, color: AppTheme.goldPrimary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Upload Architectural Drawing, Spec Sheet, or Bill of Quantities",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Accepts PDF, PNG, JPG, or TXT documents. Tesseract OCR will extract task names, deadlines, priorities, and map them to Supabase.",
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  if (_isProcessing) ...[
                    const CircularProgressIndicator(color: AppTheme.goldPrimary),
                    const SizedBox(height: 12),
                    Text(
                      "Running Tesseract OCR & Heuristic NLP parsing on $_uploadedFileName...",
                      style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ] else ...[
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => _pickAndProcessFile(state),
                          icon: const Icon(Icons.file_open_outlined, size: 16),
                          label: const Text("Select Document to Scan"),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _runSampleDocument(state),
                          icon: const Icon(Icons.science_outlined, size: 16),
                          label: const Text("Run Instant Demo"),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16)),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          // OCR Extraction Results Panel
          if (_ocrResult != null) ...[
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.emeraldSuccess, size: 20),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "OCR Structured Results: ${_ocrResult!['document_name']}",
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldSuccess.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "Confidence: ${_ocrResult!['base_confidence_score']}% • Method: ${_ocrResult!['extraction_method']}",
                          style: const TextStyle(color: AppTheme.emeraldSuccess, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "The following ${extractedTasks.length} tasks were detected from the document text and mapped into the '${currentProject?.title}' project:",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: extractedTasks.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 16),
                    itemBuilder: (context, index) {
                      final t = extractedTasks[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: LayoutBuilder(
                          builder: (context, taskConstraints) {
                            final taskRow = Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldPrimary.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text("${index + 1}", style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(t['title'] ?? 'Task', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text(t['description'] ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Planned: ${t['planned_days']} days",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "Due: ${t['due_date']}",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.goldPrimary, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                StatusBadge(label: t['priority'] ?? 'Medium', type: "priority"),
                              ],
                            );

                            if (taskConstraints.maxWidth < 650) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 650),
                                  child: taskRow,
                                ),
                              );
                            }
                            return taskRow;
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => state.setActiveTab(AppTab.dashboard),
                        child: const Text("Go to Task List"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => state.setActiveTab(AppTab.aiAnalytics),
                        icon: const Icon(Icons.auto_awesome, size: 16),
                        label: const Text("Run Scikit-Learn Predictive Model"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ] else ...[
            // Current Project Tasks List summary
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Project Tasks Table (Supabase)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                  const SizedBox(height: 6),
                  Text("Showing active tasks in '${currentProject?.title}'", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: state.tasks.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 16),
                    itemBuilder: (context, index) {
                      final t = state.tasks[index];
                      return Row(
                        children: [
                          Icon(Icons.check_box_outlined, color: t.status == 'Completed' ? AppTheme.emeraldSuccess : AppTheme.textMuted, size: 18),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                if (t.sourceDocument != null)
                                  Text("Source: ${t.sourceDocument}", style: const TextStyle(fontSize: 11, color: AppTheme.tealAccent)),
                              ],
                            ),
                          ),
                          Text("Due: ${t.dueDate}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                          const SizedBox(width: 16),
                          StatusBadge(label: t.priority, type: "priority"),
                          const SizedBox(width: 12),
                          StatusBadge(label: t.status, type: "status"),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
