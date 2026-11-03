import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/material_requirement_model.dart';
import '../theme/app_theme.dart';

class WarehouseDispatcherScreen extends StatefulWidget {
  const WarehouseDispatcherScreen({super.key});

  @override
  State<WarehouseDispatcherScreen> createState() => _WarehouseDispatcherScreenState();
}

class _WarehouseDispatcherScreenState extends State<WarehouseDispatcherScreen> {
  final Set<String> _selectedAllocationIds = {};

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final reservedAllocations = state.reservedAllocations;

    // Group allocations by project
    final Map<String, List<MaterialAllocationModel>> grouped = {};
    for (var a in reservedAllocations) {
      final pid = a.projectId ?? (state.selectedProject?.id ?? "proj-001");
      grouped.putIfAbsent(pid, () => []).add(a);
    }

    final totalReservedUnits = reservedAllocations.fold<double>(
      0.0,
      (acc, a) => acc + a.allocatedQuantity,
    );

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: const Text(
                            "DISPATCH CONTROL",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Warehouse Central Depot (Zone A-E)",
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Warehouse Dispatcher Dashboard",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                // Global Batch Dispatch Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAllocationIds.isNotEmpty ? AppTheme.goldPrimary : AppTheme.surfaceDark,
                    foregroundColor: _selectedAllocationIds.isNotEmpty ? Colors.black : AppTheme.textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _selectedAllocationIds.isNotEmpty
                      ? () => _showBatchDispatchGatePassDialog(context, state, _selectedAllocationIds.toList())
                      : null,
                  icon: const Icon(Icons.departure_board, size: 20),
                  label: Text(
                    "Generate Site Gate Pass & Dispatch (${_selectedAllocationIds.length})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Top KPI Row
            LayoutBuilder(
              builder: (context, kpiConstraints) {
                final m1 = _buildMetricCard(
                  title: "RESERVED QUEUE",
                  value: "${reservedAllocations.length} Items",
                  subtitle: "Allocations awaiting dispatch",
                  icon: Icons.bookmark_added,
                  color: Colors.blue,
                );
                final m2 = _buildMetricCard(
                  title: "TOTAL RESERVED VOLUME",
                  value: "${totalReservedUnits.toStringAsFixed(0)} Units",
                  subtitle: "Locked warehouse inventory",
                  icon: Icons.inventory_2,
                  color: AppTheme.goldPrimary,
                );
                final m3 = _buildMetricCard(
                  title: "DESTINATION SITES",
                  value: "${grouped.keys.length} Projects",
                  subtitle: "Staging staging sites",
                  icon: Icons.location_on_outlined,
                  color: AppTheme.tealPrimary,
                );
                final m4 = _buildMetricCard(
                  title: "TRANSIT GATE PASSES",
                  value: "14 Issued",
                  subtitle: "Active on-road deliveries",
                  icon: Icons.local_shipping,
                  color: const Color(0xFF10B981),
                );

                if (kpiConstraints.maxWidth > 1050) {
                  return Row(
                    children: [
                      Expanded(child: m1),
                      const SizedBox(width: 16),
                      Expanded(child: m2),
                      const SizedBox(width: 16),
                      Expanded(child: m3),
                      const SizedBox(width: 16),
                      Expanded(child: m4),
                    ],
                  );
                } else if (kpiConstraints.maxWidth > 650) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: m1),
                          const SizedBox(width: 14),
                          Expanded(child: m2),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: m3),
                          const SizedBox(width: 14),
                          Expanded(child: m4),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      m1,
                      const SizedBox(height: 10),
                      m2,
                      const SizedBox(height: 10),
                      m3,
                      const SizedBox(height: 10),
                      m4,
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: 24),

            // Allocations Grouped by Site
            if (grouped.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(48),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.surfaceBorder),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.inventory_outlined, size: 48, color: AppTheme.textMuted),
                    SizedBox(height: 12),
                    Text(
                      "No reserved allocations currently in dispatch queue.",
                      style: TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Items allocated by Project Managers will appear here grouped by destination site for gate pass generation.",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              )
            else
              ...grouped.entries.map((entry) {
                final projectId = entry.key;
                final items = entry.value;
                final projectObj = state.projects.firstWhere(
                  (p) => p.id == projectId,
                  orElse: () => state.selectedProject ?? state.projects.first,
                );

                final allSiteSelected = items.every((i) => _selectedAllocationIds.contains(i.id));

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Column(
                    children: [
                      // Site Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark.withOpacity(0.7),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              activeColor: AppTheme.goldPrimary,
                              checkColor: Colors.black,
                              value: allSiteSelected,
                              onChanged: (val) {
                                setState(() {
                                  if (val == true) {
                                    _selectedAllocationIds.addAll(items.map((i) => i.id));
                                  } else {
                                    _selectedAllocationIds.removeAll(items.map((i) => i.id));
                                  }
                                });
                              },
                            ),
                            const Icon(Icons.location_city, color: AppTheme.goldPrimary, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    projectObj.title,
                                    style: const TextStyle(
                                      color: AppTheme.textLight,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${projectObj.clientName}  •  ${items.length} materials reserved for dispatch",
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.goldPrimary.withOpacity(0.15),
                                foregroundColor: AppTheme.goldPrimary,
                                side: const BorderSide(color: AppTheme.goldPrimary),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () {
                                final siteItemIds = items.map((i) => i.id).toList();
                                _showBatchDispatchGatePassDialog(context, state, siteItemIds, projectName: projectObj.title);
                              },
                              icon: const Icon(Icons.local_shipping, size: 16),
                              label: const Text("Dispatch All For Site", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),

                      // Items List
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (ctx, i) => Divider(color: AppTheme.surfaceBorder, height: 1),
                        itemBuilder: (ctx, idx) {
                          final alloc = items[idx];
                          final isChecked = _selectedAllocationIds.contains(alloc.id);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                Checkbox(
                                  activeColor: AppTheme.goldPrimary,
                                  checkColor: Colors.black,
                                  value: isChecked,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedAllocationIds.add(alloc.id);
                                      } else {
                                        _selectedAllocationIds.remove(alloc.id);
                                      }
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alloc.itemName,
                                        style: const TextStyle(
                                          color: AppTheme.textLight,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Allocation ID: ${alloc.id}  •  Status: ${alloc.status}",
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Reserved: ${alloc.allocatedQuantity.toStringAsFixed(0)} units",
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.surfaceDark,
                                    foregroundColor: AppTheme.textLight,
                                    side: BorderSide(color: AppTheme.surfaceBorder),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  onPressed: () {
                                    _showBatchDispatchGatePassDialog(context, state, [alloc.id], projectName: projectObj.title);
                                  },
                                  icon: const Icon(Icons.send, size: 14, color: AppTheme.goldPrimary),
                                  label: const Text("Dispatch Item", style: TextStyle(fontSize: 11)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Batch Gate Pass Modal
  void _showBatchDispatchGatePassDialog(
    BuildContext context,
    AppState state,
    List<String> allocationIds, {
    String? projectName,
  }) {
    final gatePassNumber = "GP-SITE-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
    final driverCtrl = TextEditingController(text: "Alexander Petrov (Fleet Driver #12)");
    final vehicleCtrl = TextEditingController(text: "Ford Transit High-Roof (NY Plate #HMR-4912)");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.departure_board, color: AppTheme.goldPrimary),
            SizedBox(width: 10),
            Text("Issue Site Gate Pass & Dispatch",
                style: TextStyle(color: AppTheme.textLight, fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceCard,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("GATE PASS NUMBER",
                            style: TextStyle(color: AppTheme.textMuted, fontSize: 9, letterSpacing: 1.2)),
                        const SizedBox(height: 2),
                        Text(
                          gatePassNumber,
                          style: const TextStyle(
                            color: AppTheme.goldPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "${allocationIds.length} Items Selected",
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              if (projectName != null) ...[
                Text("Destination Site: $projectName",
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
              ],

              const Text("Assigned Transporter / Courier:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: driverCtrl,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 12),
              const Text("Vehicle / Carrier Registration:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: vehicleCtrl,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),

              const SizedBox(height: 14),
              const Text(
                "Authorizing dispatch decrements total warehouse inventory and marks allocations as active in-transit.",
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.goldPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await state.batchDispatchAllocations(allocationIds, gatePassNumber: gatePassNumber);
              setState(() {
                _selectedAllocationIds.removeAll(allocationIds);
              });
              if (context.mounted) {
                _showGatePassReceiptModal(context, gatePassNumber, allocationIds.length);
              }
            },
            icon: const Icon(Icons.check, size: 18),
            label: const Text("Authorize & Dispatch", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showGatePassReceiptModal(BuildContext context, String gatePassNumber, int itemCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Row(
          children: const [
            Icon(Icons.verified, color: Color(0xFF10B981)),
            SizedBox(width: 10),
            Text("Gate Pass Authorized", style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Gate Pass $gatePassNumber is now active for site transport.",
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
            const SizedBox(height: 8),
            Text("Dispatched $itemCount items. Physical manifest printed to warehouse dispatch printer.",
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary, foregroundColor: Colors.black),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
