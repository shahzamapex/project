import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';

class AIAnalyticsScreen extends StatelessWidget {
  const AIAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final project = state.selectedProject;
    final ai = state.aiPrediction;

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
                        "AI Predictive Analytics Engine",
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
                            Icon(Icons.psychology, size: 14, color: AppTheme.goldPrimary),
                            SizedBox(width: 6),
                            Text("SCIKIT-LEARN ML BACKEND", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Project: ${project?.title ?? 'Penthouse 42'} • Assessing Real-Time Engineer Velocity Against Milestones",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await state.refreshData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Scikit-Learn regression and classification models re-evaluated against real-time site data.")),
                  );
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Re-run Scikit-Learn Model"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Main Prediction Gauges
          if (ai != null) ...[
            LayoutBuilder(
              builder: (context, gaugeConstraints) {
                final isWide = gaugeConstraints.maxWidth > 950;

                final healthCard = Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      const Text("PROJECT HEALTH SCORE", style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: ai.healthScore / 100,
                              strokeWidth: 10,
                              backgroundColor: AppTheme.surfaceBorder,
                              color: ai.healthScore > 70 ? AppTheme.goldPrimary : AppTheme.roseDanger,
                            ),
                          ),
                          Column(
                            children: [
                              Text("${ai.healthScore}", style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                              const Text("/100", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        ai.healthScore > 75 ? "Optimal Pipeline Status" : "Actionable Site Risk Flagged",
                        style: TextStyle(
                          color: ai.healthScore > 75 ? AppTheme.emeraldSuccess : AppTheme.amberWarning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );

                final delayCard = Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      const Text("DELAY PROBABILITY", style: TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: CircularProgressIndicator(
                              value: ai.overallDelayProbability / 100,
                              strokeWidth: 10,
                              backgroundColor: AppTheme.surfaceBorder,
                              color: ai.overallDelayProbability > 50 ? AppTheme.roseDanger : AppTheme.amberWarning,
                            ),
                          ),
                          Column(
                            children: [
                              Text("${ai.overallDelayProbability.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                              const Text("Risk", style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "+${ai.daysVariance} Days Variance Forecast",
                        style: const TextStyle(color: AppTheme.roseDanger, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                );

                final timelineCard = Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TIMELINE RECONCILIATION", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("Contractual Target Deadline", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text(ai.targetEndDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                            ],
                          ),
                          const Icon(Icons.arrow_forward, color: AppTheme.goldPrimary),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text("AI Predicted Handover", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              const SizedBox(height: 4),
                              Text(ai.predictedCompletionDate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.roseDanger)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: AppTheme.surfaceBorder),
                      const SizedBox(height: 8),
                      Text(
                        "Scikit-Learn model assessed ${ai.totalTasksTracked} real-time tasks with ${ai.highRiskTaskCount} critical path tasks exceeding normal trade duration.",
                        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                      ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(flex: 1, child: healthCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 1, child: delayCard),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: timelineCard),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: healthCard),
                          const SizedBox(width: 14),
                          Expanded(child: delayCard),
                        ],
                      ),
                      const SizedBox(height: 14),
                      timelineCard,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 28),

            // AI Resource Reallocation Recommendations
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
                        children: const [
                          Icon(Icons.bolt, color: AppTheme.goldPrimary, size: 22),
                          SizedBox(width: 8),
                          Text("AI Resource Allocation & Optimization Recommendations", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                        ],
                      ),
                      Text("${ai.recommendations.length} Recommendations Generated", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ai.recommendations.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final rec = ai.recommendations[index];
                      Color badgeColor = rec.severity == 'High' ? AppTheme.roseDanger : (rec.severity == 'Medium' ? AppTheme.amberWarning : AppTheme.tealAccent);
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: badgeColor.withOpacity(0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(rec.severity.toUpperCase(), style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rec.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                                  const SizedBox(height: 4),
                                  Text(rec.action, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Critical Path Bottlenecks Table
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
                  const Text("Flagged Critical Path Tasks & Variance Analysis", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                  const SizedBox(height: 6),
                  const Text("Tasks where machine learning predicts completion duration exceeding planned site allocation:", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const SizedBox(height: 16),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: ai.criticalPathTasks.length,
                    separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 18),
                    itemBuilder: (context, index) {
                      final ct = ai.criticalPathTasks[index];
                      return Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: AppTheme.roseDanger, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ct.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                const SizedBox(height: 2),
                                Text("Progress: ${ct.completionPercent}% • Status: ${ct.status}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Planned: ${ct.plannedDays.toStringAsFixed(0)}d  |  AI Forecast: ${ct.predictedTotalDays.toStringAsFixed(1)}d", style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                                Text("Variance: +${ct.varianceDays} days", style: const TextStyle(fontSize: 11, color: AppTheme.roseDanger, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.roseDanger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text("${ct.delayProbability.toStringAsFixed(1)}% Delay Risk", style: const TextStyle(color: AppTheme.roseDanger, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
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
