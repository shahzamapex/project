import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/task_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class EngineerDashboard extends StatelessWidget {
  const EngineerDashboard({super.key});

  void _showUpdateProgressDialog(BuildContext context, TaskModel task, AppState state) {
    double progress = task.completionPercent.toDouble();
    String status = task.status;
    int actualDays = task.actualDays;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: Text("Submit Progress: ${task.title}", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Task Due Date: ${task.dueDate} • Planned: ${task.plannedDays} days", style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Completion Progress", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text("${progress.toInt()}%", style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
                Slider(
                  value: progress,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  activeColor: AppTheme.goldPrimary,
                  inactiveColor: AppTheme.surfaceBorder,
                  onChanged: (val) {
                    setDialogState(() {
                      progress = val;
                      if (val == 100) {
                        status = "Completed";
                      } else if (val > 0) {
                        status = "In Progress";
                      }
                    });
                  },
                ),
                const SizedBox(height: 14),
                const Text("Task Status", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: AppTheme.surfaceDark,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: "To Do", child: Text("To Do")),
                    DropdownMenuItem(value: "In Progress", child: Text("In Progress")),
                    DropdownMenuItem(value: "Completed", child: Text("Completed")),
                  ],
                  onChanged: (val) => setDialogState(() => status = val!),
                ),
                const SizedBox(height: 14),
                const Text("Site Inspection Notes / Remarks", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(hintText: "e.g. Subfloor moisture test passed at 12%. Ready for adhesives."),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await state.updateTaskProgress(task.id, progress.toInt(), status, actualDays + 1);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Site progress submitted for '${task.title}'. Model schedule updated.")),
                );
              },
              child: const Text("Submit Report"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currentProject = state.selectedProject;
    final tasks = state.tasks;

    final completedCount = tasks.where((t) => t.status == 'Completed').length;
    final inProgressCount = tasks.where((t) => t.status == 'In Progress').length;

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
            runSpacing: 16,
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
                        "Site Engineer Command Portal",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.tealAccent.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.tealAccent),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.engineering, size: 14, color: AppTheme.tealAccent),
                            SizedBox(width: 6),
                            Text("ROLE: SITE ENGINEER", style: TextStyle(color: AppTheme.tealAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Assigned Site: ${currentProject?.siteAddress ?? 'Tribeca Residence'} • Real-Time Punch List Execution",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => state.setActiveTab(AppTab.drawings),
                    icon: const Icon(Icons.architecture, size: 16),
                    label: const Text("View Site Blueprints & Markups"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => state.setActiveTab(AppTab.ocrTasks),
                    icon: const Icon(Icons.document_scanner, size: 16),
                    label: const Text("Scan Spec Document (OCR)"),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Site Summary Cards
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 850;
              final card1 = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.tealAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.checklist_rtl, color: AppTheme.tealAccent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TOTAL ASSIGNED TASKS", style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("${tasks.length} Site Tasks", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card2 = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldSuccess.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_outline, color: AppTheme.emeraldSuccess, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("TASKS COMPLETED", style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("$completedCount / ${tasks.length} Done", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final card3 = Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.goldPrimary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pending_actions, color: AppTheme.goldPrimary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("IN PROGRESS ON SITE", style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text("$inProgressCount In Progress", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  children: [
                    Expanded(child: card1),
                    const SizedBox(width: 16),
                    Expanded(child: card2),
                    const SizedBox(width: 16),
                    Expanded(child: card3),
                  ],
                );
              } else {
                return Column(
                  children: [
                    card1,
                    const SizedBox(height: 12),
                    card2,
                    const SizedBox(height: 12),
                    card3,
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 24),

          // Interactive Punch List Table
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
                  runSpacing: 6,
                  children: const [
                    Text("Site Execution Tasks & Punch List", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    Text("Click 'Update Progress' to log real-time site status", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 20),
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder.withOpacity(0.5)),
                      ),
                      child: LayoutBuilder(
                        builder: (context, itemConstraints) {
                          final rowContent = Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: t.status == 'Completed' ? AppTheme.emeraldSuccess.withOpacity(0.15) : AppTheme.goldPrimary.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  t.status == 'Completed' ? Icons.check : Icons.construction,
                                  color: t.status == 'Completed' ? AppTheme.emeraldSuccess : AppTheme.goldPrimary,
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                flex: 4,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(t.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                        ),
                                        const SizedBox(width: 8),
                                        StatusBadge(label: t.priority, type: "priority"),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${t.description} • Due: ${t.dueDate} (Planned: ${t.plannedDays}d)",
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                    ),
                                    if (t.sourceDocument != null) ...[
                                      const SizedBox(height: 3),
                                      Text(
                                        "Extracted from: ${t.sourceDocument} (OCR Confidence: ${t.confidenceScore ?? 95}%)",
                                        style: const TextStyle(fontSize: 11, color: AppTheme.tealAccent),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                              const SizedBox(width: 24),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text("Completion", style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                        Text("${t.completionPercent}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    LinearProgressIndicator(
                                      value: t.completionPercent / 100,
                                      backgroundColor: AppTheme.surfaceBorder,
                                      color: t.status == 'Completed' ? AppTheme.emeraldSuccess : AppTheme.goldPrimary,
                                      minHeight: 6,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              StatusBadge(label: t.status, type: "status"),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: () => _showUpdateProgressDialog(context, t, state),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.surfaceDark,
                                  foregroundColor: AppTheme.goldPrimary,
                                  side: const BorderSide(color: AppTheme.goldPrimary, width: 1),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                                child: const Text("Update Progress", style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          );

                          if (itemConstraints.maxWidth < 750) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(minWidth: 750),
                                child: rowContent,
                              ),
                            );
                          }
                          return rowContent;
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
