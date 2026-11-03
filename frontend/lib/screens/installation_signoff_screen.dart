import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/material_requirement_model.dart';
import '../theme/app_theme.dart';

class InstallationSignoffScreen extends StatefulWidget {
  const InstallationSignoffScreen({super.key});

  @override
  State<InstallationSignoffScreen> createState() => _InstallationSignoffScreenState();
}

class _InstallationSignoffScreenState extends State<InstallationSignoffScreen> {
  String _activeTab = 'PENDING'; // 'PENDING' or 'CONFIRMED'

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // Filter items based on dispatched or installed status
    final pendingItems = state.materialRequirements.where((r) {
      final hasDispatched = r.allocations.any((a) => a.status == 'DISPATCHED_TO_SITE');
      final needsInstall = r.installedQuantity < r.requiredQuantity;
      return (hasDispatched || r.fulfillmentStatus == 'FULFILLED_WAREHOUSE') &&
          r.installationStatus != 'INSTALLED_CONFIRMED' &&
          needsInstall;
    }).toList();

    final confirmedItems = state.materialRequirements.where((r) {
      return r.installationStatus == 'INSTALLED_CONFIRMED' || r.installedQuantity >= r.requiredQuantity;
    }).toList();

    final displayItems = _activeTab == 'PENDING' ? pendingItems : confirmedItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.tealPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.tealPrimary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            "SITE ENGINEER INTERFACE",
                            style: TextStyle(
                              color: AppTheme.tealPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.selectedProject?.title ?? "Project Site",
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Material Check-in & Installation Sign-off",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                // Inspector Identity Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppTheme.tealPrimary,
                        child: Icon(Icons.engineering, size: 16, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.currentUser.fullName,
                            style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          const Text(
                            "Field Fitment Inspector",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Tabs Selector
            Row(
              children: [
                _buildTabButton("PENDING", "Pending Site Fitment (${pendingItems.length})", Icons.hourglass_top),
                const SizedBox(width: 12),
                _buildTabButton("CONFIRMED", "Confirmed & Signed Off (${confirmedItems.length})", Icons.verified),
              ],
            ),

            const SizedBox(height: 20),

            // Empty State or Item Cards
            if (displayItems.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Icon(
                      _activeTab == 'PENDING' ? Icons.check_circle_outline : Icons.inventory_2_outlined,
                      size: 48,
                      color: AppTheme.tealPrimary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _activeTab == 'PENDING'
                          ? "All dispatched materials have been confirmed and installed!"
                          : "No installation records have been signed off yet.",
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Material deliveries dispatched from warehouse will automatically appear in this checklist.",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayItems.length,
                separatorBuilder: (ctx, i) => const SizedBox(height: 14),
                itemBuilder: (ctx, idx) {
                  final req = displayItems[idx];
                  return _buildMaterialCard(context, req, state);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String tabKey, String label, IconData icon) {
    final isSelected = _activeTab == tabKey;
    return InkWell(
      onTap: () => setState(() => _activeTab = tabKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.tealPrimary.withOpacity(0.15) : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTheme.tealPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppTheme.tealPrimary : AppTheme.textMuted),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.tealPrimary : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(BuildContext context, MaterialRequirementModel req, AppState state) {
    final allocation = req.allocations.isNotEmpty ? req.allocations.first : null;
    final gatePass = allocation?.gatePassNumber ?? "GP-2026-8801";
    final remainingQty = (req.requiredQuantity - req.installedQuantity).clamp(0, req.requiredQuantity);
    final isConfirmed = req.installationStatus == 'INSTALLED_CONFIRMED';

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isConfirmed ? AppTheme.tealPrimary.withOpacity(0.3) : AppTheme.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_shipping, size: 12, color: Colors.blue),
                                const SizedBox(width: 4),
                                Text(
                                  "Gate Pass: $gatePass",
                                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              req.itemCategory,
                              style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        req.itemName,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (req.specificationDetails.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          req.specificationDetails.entries.map((e) => "${e.key}: ${e.value}").join("  •  "),
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),

                // Fitment Action / Status
                if (!isConfirmed)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.tealPrimary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => _showFitmentSignoffDialog(context, req, state, remainingQty.toDouble()),
                    icon: const Icon(Icons.check_circle_outline, size: 18),
                    label: const Text(
                      "Confirm Fitment",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.tealPrimary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.tealPrimary),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.verified, color: AppTheme.tealPrimary, size: 16),
                        SizedBox(width: 6),
                        Text(
                          "Fitment Signed Off",
                          style: TextStyle(color: AppTheme.tealPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppTheme.surfaceBorder, height: 1),
            const SizedBox(height: 14),

            // Installation Quantity Progress Bar
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Installed: ${req.installedQuantity.toStringAsFixed(0)} / ${req.requiredQuantity.toStringAsFixed(0)} units",
                            style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "${((req.installedQuantity / (req.requiredQuantity > 0 ? req.requiredQuantity : 1)) * 100).toStringAsFixed(0)}%",
                            style: const TextStyle(color: AppTheme.tealPrimary, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: req.requiredQuantity > 0
                              ? (req.installedQuantity / req.requiredQuantity).clamp(0.0, 1.0)
                              : 0.0,
                          backgroundColor: AppTheme.surfaceBorder,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.tealPrimary),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Remaining to fit: ${remainingQty.toStringAsFixed(0)}",
                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Single-Tap Confirm Fitment Modal with Counter & Photo Attachment
  void _showFitmentSignoffDialog(
    BuildContext context,
    MaterialRequirementModel req,
    AppState state,
    double defaultRemaining,
  ) {
    double installQty = defaultRemaining > 0 ? defaultRemaining : 1.0;
    final notesController = TextEditingController(text: "Inspected alignment, structural substrate, and aesthetic tolerances. All specs verified.");
    String simulatedPhotoUrl = "https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=800";
    bool photoAttached = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.verified, color: AppTheme.tealPrimary, size: 22),
                SizedBox(width: 10),
                Text("Confirm Fitment & Sign-Off",
                    style: TextStyle(color: AppTheme.textLight, fontSize: 17, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      req.itemName,
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Gate Pass linked to transit batch. Total Required: ${req.requiredQuantity.toStringAsFixed(0)}",
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),

                    const SizedBox(height: 18),
                    const Text("Quantity Installed / Fitted:",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Counter with Stepper
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, color: AppTheme.goldPrimary),
                            onPressed: () {
                              if (installQty > 1) {
                                setDlgState(() => installQty -= 1);
                              }
                            },
                          ),
                          Text(
                            "${installQty.toStringAsFixed(0)} Units",
                            style: const TextStyle(
                              color: AppTheme.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: AppTheme.goldPrimary),
                            onPressed: () {
                              setDlgState(() => installQty += 1);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),
                    const Text("Verification Proof Photo:",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),

                    // Photo Picker & Preview Box
                    Container(
                      height: 130,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.surfaceBorder),
                        image: photoAttached
                            ? DecorationImage(
                                image: NetworkImage(simulatedPhotoUrl),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: photoAttached
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.black.withOpacity(0.4),
                              ),
                              child: Center(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black87,
                                    foregroundColor: AppTheme.tealPrimary,
                                  ),
                                  onPressed: () {
                                    setDlgState(() => photoAttached = false);
                                  },
                                  icon: const Icon(Icons.refresh, size: 16),
                                  label: const Text("Replace Site Photo", style: TextStyle(fontSize: 11)),
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () {
                                setDlgState(() => photoAttached = true);
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.camera_alt, color: AppTheme.tealPrimary, size: 32),
                                  SizedBox(height: 6),
                                  Text("Tap to snap or upload site verification photo",
                                      style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                                ],
                              ),
                            ),
                    ),

                    const SizedBox(height: 18),
                    const Text("Engineer Inspection Notes & Quality Verification:",
                        style: TextStyle(color: AppTheme.textMuted, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.tealPrimary,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await state.confirmInstallation(
                    req.id,
                    installQty,
                    notes: notesController.text.trim(),
                    proofAttachmentUrl: photoAttached ? simulatedPhotoUrl : null,
                  );
                },
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text("Submit Fitment Sign-Off", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }
}
