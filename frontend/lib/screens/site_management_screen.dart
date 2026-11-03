import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class SiteManagementScreen extends StatelessWidget {
  const SiteManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currentProject = state.selectedProject;
    final tasks = state.tasks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Site & Field Operations Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Project Sites Mapping, Engineer Workload Allocation, and Site Quality Logs",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Site inspection checklist generated.")),
                  );
                },
                icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                label: const Text("Schedule Site Inspection"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Primary Site Card
          if (currentProject != null)
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.goldPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.location_on, color: AppTheme.goldPrimary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(currentProject.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                              const SizedBox(height: 2),
                              Text(currentProject.siteAddress, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                            ],
                          ),
                        ],
                      ),
                      const StatusBadge(label: "Active Site", type: "status"),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: AppTheme.surfaceBorder),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _siteDetailCol("ASSIGNED LEAD ENGINEER", "Marcus Lee (Lead Site Engineer)"),
                      _siteDetailCol("LAST FIELD INSPECTION", "2026-11-01 14:00 (Passed)"),
                      _siteDetailCol("ACTIVE SITE TASKS", "${tasks.length} Tracked Tasks"),
                      _siteDetailCol("ESTIMATED COMPLETION", currentProject.targetEndDate),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.notes, size: 16, color: AppTheme.goldPrimary),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Site Log: Custom fluted walnut millwork delivered to Tribeca 42nd floor. Subfloor moisture barrier tested. Plumbing roughs ready for Dornbracht trim.",
                            style: TextStyle(fontSize: 12, color: AppTheme.textLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // Secondary Sites Grid
          const Text("All Company Project Sites", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
          const SizedBox(height: 14),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.projects.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final p = state.projects[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.apartment, color: AppTheme.tealAccent, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                          const SizedBox(height: 2),
                          Text(p.siteAddress, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        index == 0 ? "Eng. Marcus Lee" : (index == 1 ? "Eng. Sarah Chen" : "Pending Assignment"),
                        style: const TextStyle(fontSize: 12, color: AppTheme.goldPrimary, fontWeight: FontWeight.w600),
                      ),
                    ),
                    StatusBadge(label: p.status, type: "status"),
                    const SizedBox(width: 14),
                    OutlinedButton(
                      onPressed: () {
                        state.setSelectedProject(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Switched active site to '${p.title}'.")),
                        );
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                      child: const Text("Select Site", style: TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _siteDetailCol(String title, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
