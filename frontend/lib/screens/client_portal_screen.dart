import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/client_portal_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class ClientPortalScreen extends StatelessWidget {
  const ClientPortalScreen({super.key});

  void _showApprovalDialog(BuildContext context, ClientApprovalModel item, AppState state) {
    final feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceCard,
        title: Text("Design Review: ${item.title}", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.mediaUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 220,
                    color: AppTheme.surfaceDark,
                    child: const Center(child: Icon(Icons.image_outlined, size: 48, color: AppTheme.textMuted)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(item.description, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, height: 1.4)),
              const SizedBox(height: 18),
              const Text("Your Feedback / Notes for the Architect", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextField(
                controller: feedbackController,
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "e.g. Love the Calacatta island! Please confirm edge miter detail.",
                ),
              ),
            ],
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () async {
              await state.submitApprovalDecision(item.id, "Revision Requested", feedbackController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Revision request submitted to Elena & Marcus Lee.")),
              );
            },
            style: OutlinedButton.styleFrom(foregroundColor: AppTheme.amberWarning, side: const BorderSide(color: AppTheme.amberWarning)),
            child: const Text("Request Revision"),
          ),
          ElevatedButton(
            onPressed: () async {
              await state.submitApprovalDecision(item.id, "Approved", feedbackController.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Design approved! Site fabrication authorized.")),
              );
            },
            child: const Text("Approve Design"),
          ),
        ],
      ),
    );
  }

  void _showPayInvoiceDialog(BuildContext context, InvoiceModel invoice, AppState state) {
    String paymentMethod = "Wire Transfer (Chase Bank)";

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: Text("Pay Invoice: ${invoice.invoiceNumber}", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invoice.milestoneName, style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text("Due Date: ${invoice.dueDate}", style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("TOTAL DUE", style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                      Text("\$${invoice.amount.toStringAsFixed(0)}", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                const Text("Select Payment Method", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: paymentMethod,
                  dropdownColor: AppTheme.surfaceDark,
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: "Wire Transfer (Chase Bank)", child: Text("Wire Transfer (Chase Bank)")),
                    DropdownMenuItem(value: "ACH Direct Debit", child: Text("ACH Direct Debit")),
                    DropdownMenuItem(value: "Corporate Credit Card", child: Text("Corporate Credit Card")),
                  ],
                  onChanged: (val) => setDialogState(() => paymentMethod = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await state.submitInvoicePayment(invoice.id, paymentMethod);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Payment of \$${invoice.amount.toStringAsFixed(0)} confirmed. SendGrid receipt email triggered.")),
                );
              },
              child: const Text("Confirm & Submit Payment"),
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
    final project = state.selectedProject;
    final approvals = state.clientApprovals;
    final invoices = state.invoices;

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
                  Row(
                    children: [
                      const Text(
                        "Client Luxury Portal",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.goldPrimary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.goldPrimary),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.star, size: 14, color: AppTheme.goldPrimary),
                            SizedBox(width: 6),
                            Text("ROLE: CLIENT", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Welcome back, ${state.currentUser.fullName} • ${project?.title ?? 'Tribeca Residence'}",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              OutlinedButton.icon(
                onPressed: () => state.setActiveTab(AppTab.drawings),
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text("View Architectural Blueprints"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Project Banner Showcase
          if (project != null)
            Container(
              padding: const EdgeInsets.all(24),
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
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(project.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                        const SizedBox(height: 6),
                        Text(project.description, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted, height: 1.4)),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            _statItem("TOTAL BUDGET", currency.format(project.budget)),
                            const SizedBox(width: 28),
                            _statItem("FUNDS BILLED", currency.format(project.spent)),
                            const SizedBox(width: 28),
                            _statItem("ESTIMATED COMPLETION", project.targetEndDate),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceDark,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          const Text("OVERALL SITE COMPLETION", style: TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("${project.progressPercent}%", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 32, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: project.progressPercent / 100,
                            backgroundColor: AppTheme.surfaceBorder,
                            color: AppTheme.goldPrimary,
                            minHeight: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // 3D Render & Material Palette Design Approvals
          const Text("Design Concepts, 3D Renders & Material Palettes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
          const SizedBox(height: 6),
          const Text("Review architectural renderings and click 'Review & Sign-Off' to approve or request changes.", style: TextStyle(fontSize: 13, color: AppTheme.textMuted)),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossCount = constraints.maxWidth > 950 ? 3 : (constraints.maxWidth > 650 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: approvals.length,
                itemBuilder: (context, index) {
                  final a = approvals[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Stack(
                            children: [
                              Image.network(
                                a.mediaUrl,
                                height: 160,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  height: 160,
                                  color: AppTheme.surfaceDark,
                                  child: const Center(child: Icon(Icons.image, size: 40, color: AppTheme.textMuted)),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                left: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(a.stage.toUpperCase(), style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: StatusBadge(label: a.status, type: "approval"),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 6),
                              Text(a.description, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3), maxLines: 2, overflow: TextOverflow.ellipsis),
                              if (a.clientFeedback.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text("Your Note: \"${a.clientFeedback}\"", style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.goldPrimary)),
                              ],
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _showApprovalDialog(context, a, state),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    backgroundColor: a.status == 'Approved' ? AppTheme.surfaceDark : AppTheme.goldPrimary,
                                    foregroundColor: a.status == 'Approved' ? AppTheme.emeraldSuccess : Colors.black,
                                    side: a.status == 'Approved' ? const BorderSide(color: AppTheme.emeraldSuccess) : null,
                                  ),
                                  child: Text(a.status == 'Approved' ? "View Approved Sign-off" : "Review & Sign-Off", style: const TextStyle(fontSize: 12)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // Financial Milestones & Invoices
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("Payment Milestones & Invoices", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    Text("All payments backed by automated SendGrid receipts", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: invoices.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 20),
                  itemBuilder: (context, index) {
                    final inv = invoices[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: inv.status == 'Paid' ? AppTheme.emeraldSuccess.withOpacity(0.15) : AppTheme.goldPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              inv.status == 'Paid' ? Icons.check_circle : Icons.receipt_long,
                              color: inv.status == 'Paid' ? AppTheme.emeraldSuccess : AppTheme.goldPrimary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(inv.milestoneName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                const SizedBox(height: 2),
                                Text("Invoice: ${inv.invoiceNumber} • Due Date: ${inv.dueDate}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Text(currency.format(inv.amount), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                          const SizedBox(width: 20),
                          StatusBadge(label: inv.status, type: "status"),
                          const SizedBox(width: 16),
                          if (inv.status != 'Paid')
                            ElevatedButton(
                              onPressed: () => _showPayInvoiceDialog(context, inv, state),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              ),
                              child: const Text("Pay Milestone", style: TextStyle(fontSize: 12)),
                            )
                          else
                            const Text("Receipt Emailed", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        ],
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

  Widget _statItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: AppTheme.textLight, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
