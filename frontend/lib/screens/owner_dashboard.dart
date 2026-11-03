import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/metric_card.dart';
import '../widgets/status_badge.dart';

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  void _showRoleManagementDialog(BuildContext context, AppState state) {
    String selectedUser = "u-eng-002";
    String selectedRole = "owner";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: Row(
            children: const [
              Icon(Icons.admin_panel_settings_outlined, color: AppTheme.goldPrimary),
              SizedBox(width: 10),
              Text("Dynamic Role & RBAC Governance", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "As Studio Owner, you can dynamically modify role permissions and reassign access levels across team members and clients.",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                ),
                const SizedBox(height: 20),
                const Text("Select Team Member", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedUser,
                  dropdownColor: AppTheme.surfaceDark,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: "u-eng-001", child: Text("Marcus Lee (Lead Site Engineer)")),
                    DropdownMenuItem(value: "u-eng-002", child: Text("Sarah Chen (Structural Engineer)")),
                    DropdownMenuItem(value: "u-client-001", child: Text("David Sterling (Client)")),
                    DropdownMenuItem(value: "u-client-002", child: Text("Claire Fontaine (Client)")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedUser = val!),
                ),
                const SizedBox(height: 16),
                const Text("Assign New System Role", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: AppTheme.surfaceDark,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: "owner", child: Text("Owner (Full Administrative Access & Financials)")),
                    DropdownMenuItem(value: "engineer", child: Text("Engineer (Site Progress, Drawings & Markups)")),
                    DropdownMenuItem(value: "client", child: Text("Client (Design Approvals & Payment Portal)")),
                  ],
                  onChanged: (val) => setDialogState(() => selectedRole = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await state.updateTeamMemberRole(selectedUser, selectedRole);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Role updated successfully to '$selectedRole' with revised permissions.")),
                );
              },
              child: const Text("Save Permissions"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final projects = state.projects;
    final ai = state.aiPrediction;

    final totalBudget = projects.fold<double>(0.0, (sum, p) => sum + p.budget);
    final totalSpent = projects.fold<double>(0.0, (sum, p) => sum + p.spent);
    final burnRate = totalBudget > 0 ? ((totalSpent / totalBudget) * 100).toStringAsFixed(1) : "0";

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
                        "Executive Command Center",
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
                            Icon(Icons.verified_user, size: 14, color: AppTheme.goldPrimary),
                            SizedBox(width: 6),
                            Text("ROLE: OWNER", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Studio Portfolio, Scikit-Learn Predictive Risk, Financial Health, and RBAC Management",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showRoleManagementDialog(context, state),
                icon: const Icon(Icons.security, size: 16),
                label: const Text("Manage Roles & Permissions"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // KPI Cards Grid
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 1100 ? 4 : (constraints.maxWidth > 700 ? 2 : 1);
              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: constraints.maxWidth > 1100 ? 2.1 : (constraints.maxWidth > 700 ? 2.2 : 2.5),
                children: [
                  MetricCard(
                    title: "Active Projects",
                    value: "${projects.where((p) => p.status == 'In Progress').length}",
                    subtitle: "${projects.length} Total in Pipeline",
                    icon: Icons.business,
                    iconColor: AppTheme.goldPrimary,
                  ),
                  MetricCard(
                    title: "Total Portfolio Budget",
                    value: currency.format(totalBudget),
                    subtitle: "Spent: ${currency.format(totalSpent)} ($burnRate%)",
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: AppTheme.tealAccent,
                  ),
                  MetricCard(
                    title: "AI Forecasted Delay Risk",
                    value: ai != null ? "${ai.overallDelayProbability.toStringAsFixed(1)}%" : "38.5%",
                    subtitle: ai != null ? "+${ai.daysVariance} days variance predicted" : "On Track",
                    icon: Icons.psychology_outlined,
                    iconColor: ai != null && ai.overallDelayProbability > 40 ? AppTheme.roseDanger : AppTheme.emeraldSuccess,
                    trend: ai != null ? "+${ai.daysVariance}d" : null,
                    isPositiveTrend: false,
                  ),
                  MetricCard(
                    title: "Warehouse Inventory Alerts",
                    value: "${state.inventory.where((i) => i.status == 'Low Stock').length} SKUs",
                    subtitle: "Action needed for lighting & marble",
                    icon: Icons.warehouse_outlined,
                    iconColor: AppTheme.amberWarning,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 28),

          // Two-Column Section: AI Predictive Insights & Quick Actions
          LayoutBuilder(
            builder: (context, sectionConstraints) {
              final isWide = sectionConstraints.maxWidth > 920;

              final leftCard = Container(
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
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.auto_awesome, color: AppTheme.goldPrimary, size: 20),
                            SizedBox(width: 8),
                            Text("Scikit-Learn Predictive Site Analytics", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                          ],
                        ),
                        OutlinedButton.icon(
                          onPressed: () => state.setActiveTab(AppTab.aiAnalytics),
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text("Full Analysis", style: TextStyle(fontSize: 12)),
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                        ),
                      ],
                    ),
                      const SizedBox(height: 16),
                      if (ai != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.obsidian,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Text("${ai.healthScore}/100", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                                  const Text("HEALTH SCORE", style: TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Project: ${ai.projectTitle}",
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Target End Date: ${ai.targetEndDate}  |  AI Forecast: ${ai.predictedCompletionDate} (+${ai.daysVariance} business days)",
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    value: (100 - ai.overallDelayProbability) / 100,
                                    backgroundColor: AppTheme.surfaceBorder,
                                    color: ai.overallDelayProbability > 50 ? AppTheme.roseDanger : AppTheme.goldPrimary,
                                    minHeight: 6,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        const Text("Top AI Resource Recommendation:", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.goldPrimary)),
                        const SizedBox(height: 6),
                        if (ai.recommendations.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.obsidian,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppTheme.surfaceBorder),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.bolt, color: AppTheme.amberWarning, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    ai.recommendations.first.action,
                                    style: const TextStyle(fontSize: 12, color: AppTheme.textLight, height: 1.4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                );

              final rightCard = Container(
                padding: const EdgeInsets.all(22),
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
                        Icon(Icons.document_scanner_outlined, color: AppTheme.tealAccent, size: 20),
                        SizedBox(width: 8),
                        Text("OCR Task Automation", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Upload architectural drawings, specifications, or BoQ PDFs. Tesseract OCR will extract and structure tasks automatically into the Supabase database.",
                      style: TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => state.setActiveTab(AppTab.ocrTasks),
                        icon: const Icon(Icons.upload_file, size: 16),
                        label: const Text("Upload Document & Scan"),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => state.setActiveTab(AppTab.drawings),
                        icon: const Icon(Icons.draw_outlined, size: 16),
                        label: const Text("Open Drawing Center"),
                      ),
                    ),
                  ],
                ),
              );

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: leftCard),
                    const SizedBox(width: 20),
                    Expanded(flex: 2, child: rightCard),
                  ],
                );
              } else {
                return Column(
                  children: [
                    leftCard,
                    const SizedBox(height: 20),
                    rightCard,
                  ],
                );
              }
            },
          ),

          const SizedBox(height: 28),

          // Active Projects Table
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
                  children: [
                    const Text(
                      "Active Interior Architecture Projects",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                    ),
                    Text(
                      "${projects.length} Total Projects",
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 24),
                  itemBuilder: (context, index) {
                    final p = projects[index];
                    return InkWell(
                      onTap: () => state.setSelectedProject(p),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: LayoutBuilder(
                          builder: (context, rowConstraints) {
                            final rowWidget = Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldPrimary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.apartment, color: AppTheme.goldPrimary, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(p.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 2),
                                      Text("Client: ${p.clientName} • ${p.siteAddress}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Progress: ${p.progressPercent}%", style: const TextStyle(fontSize: 12, color: AppTheme.textLight)),
                                      const SizedBox(height: 4),
                                      LinearProgressIndicator(
                                        value: p.progressPercent / 100,
                                        backgroundColor: AppTheme.surfaceBorder,
                                        color: AppTheme.goldPrimary,
                                        minHeight: 5,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(currency.format(p.budget), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                                    Text("Spent: ${currency.format(p.spent)}", style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                StatusBadge(label: p.status, type: "status"),
                              ],
                            );

                            if (rowConstraints.maxWidth < 650) {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(minWidth: 650),
                                  child: rowWidget,
                                ),
                              );
                            }
                            return rowWidget;
                          },
                        ),
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
