import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/material_requirement_model.dart';
import '../theme/app_theme.dart';

class FulfillmentMatrixScreen extends StatefulWidget {
  const FulfillmentMatrixScreen({super.key});

  @override
  State<FulfillmentMatrixScreen> createState() => _FulfillmentMatrixScreenState();
}

class _FulfillmentMatrixScreenState extends State<FulfillmentMatrixScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final requirements = state.materialRequirements.where((r) {
      if (_selectedFilter == 'FULFILLED') {
        if (r.fulfillmentStatus != 'FULFILLED_WAREHOUSE') return false;
      } else if (_selectedFilter == 'PROCUREMENT') {
        if (r.fulfillmentStatus != 'PROCUREMENT_PENDING') return false;
      } else if (_selectedFilter == 'INSTALLED') {
        if (r.installationStatus != 'INSTALLED_CONFIRMED') return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return r.itemName.toLowerCase().contains(q) ||
            r.itemCategory.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    // Summary metrics
    final totalCount = state.materialRequirements.length;
    final fulfilledCount = state.materialRequirements
        .where((r) => r.fulfillmentStatus == 'FULFILLED_WAREHOUSE')
        .length;
    final procurementCount = state.materialRequirements
        .where((r) => r.fulfillmentStatus == 'PROCUREMENT_PENDING')
        .length;
    final installedCount = state.materialRequirements
        .where((r) => r.installationStatus == 'INSTALLED_CONFIRMED')
        .length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar & Title
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
                            color: AppTheme.goldPrimary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.3)),
                          ),
                          child: const Text(
                            "MRP MODULE",
                            style: TextStyle(
                              color: AppTheme.goldPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          state.selectedProject?.title ?? "Project Site",
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Site Specification & Fulfillment Matrix",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textLight,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                // Global Actions
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.tealPrimary.withOpacity(0.15),
                        foregroundColor: AppTheme.tealPrimary,
                        side: const BorderSide(color: AppTheme.tealPrimary),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _handleAutoMatch(context, state),
                      icon: const Icon(Icons.auto_awesome, size: 18),
                      label: const Text(
                        "Auto-Match & Allocate",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.goldPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () => _showAddSpecificationDialog(context, state),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text(
                        "Add Site Specification",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // KPI Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    title: "TOTAL SPECIFIED",
                    value: "$totalCount Items",
                    subtitle: "Site Bill of Materials",
                    icon: Icons.list_alt,
                    accentColor: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: "WAREHOUSE FULFILLED",
                    value: "$fulfilledCount Items",
                    subtitle: "Reserved or In Transit",
                    icon: Icons.check_circle_outline,
                    accentColor: const Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: "OUT OF STOCK / DEFICIT",
                    value: "$procurementCount POs",
                    subtitle: "Procurement Requisitions",
                    icon: Icons.shopping_cart_checkout,
                    accentColor: Colors.amber,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildKpiCard(
                    title: "INSTALLED CONFIRMED",
                    value: "$installedCount Fitted",
                    subtitle: "Signed off on site",
                    icon: Icons.verified,
                    accentColor: AppTheme.tealPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Controls & Filters Bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "Search site specification by material name, category...",
                        hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textMuted, size: 20),
                        isDense: true,
                        filled: true,
                        fillColor: AppTheme.surfaceDark,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppTheme.surfaceBorder),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: AppTheme.surfaceBorder),
                        ),
                      ),
                      onChanged: (val) {
                        setState(() => _searchQuery = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildFilterChip("ALL", "All Items ($totalCount)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("FULFILLED", "Fulfilled ($fulfilledCount)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("PROCUREMENT", "Out of Stock ($procurementCount)"),
                  const SizedBox(width: 8),
                  _buildFilterChip("INSTALLED", "Installed ($installedCount)"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Main Interactive Specification Matrix
            Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.surfaceBorder),
              ),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceDark.withOpacity(0.6),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
                    ),
                    child: Row(
                      children: const [
                        Expanded(flex: 3, child: Text("MATERIAL SPECIFICATION & DETAILS", style: _headerStyle)),
                        Expanded(flex: 2, child: Text("CATEGORY", style: _headerStyle)),
                        Expanded(flex: 1, child: Text("REQUIRED", style: _headerStyle)),
                        Expanded(flex: 1, child: Text("ALLOCATED", style: _headerStyle)),
                        Expanded(flex: 1, child: Text("INSTALLED", style: _headerStyle)),
                        Expanded(flex: 2, child: Text("FULFILLMENT STATUS", style: _headerStyle)),
                        Expanded(flex: 2, child: Text("INSTALLATION", style: _headerStyle)),
                        SizedBox(width: 140, child: Text("ACTIONS", style: _headerStyle, textAlign: TextAlign.right)),
                      ],
                    ),
                  ),

                  // Table Rows
                  if (requirements.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(
                        child: Text(
                          "No material requirements match the selected filter.",
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: requirements.length,
                      separatorBuilder: (ctx, i) => Divider(color: AppTheme.surfaceBorder, height: 1),
                      itemBuilder: (ctx, idx) {
                        final req = requirements[idx];
                        return _buildMatrixRow(context, req, state);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const TextStyle _headerStyle = TextStyle(
    color: AppTheme.textMuted,
    fontSize: 11,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.0,
  );

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;
    return InkWell(
      onTap: () => setState(() => _selectedFilter = key),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.goldPrimary.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.goldPrimary : AppTheme.surfaceBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
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
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 24),
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

  Widget _buildMatrixRow(BuildContext context, MaterialRequirementModel req, AppState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Name & Spec details
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  req.itemName,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (req.specificationDetails.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: req.specificationDetails.entries.take(2).map((e) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceDark,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppTheme.surfaceBorder),
                        ),
                        child: Text(
                          "${e.key}: ${e.value}",
                          style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: Text(
              req.itemCategory,
              style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ),

          // Required Qty
          Expanded(
            flex: 1,
            child: Text(
              "${req.requiredQuantity.toStringAsFixed(0)}",
              style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),

          // Allocated Qty
          Expanded(
            flex: 1,
            child: Text(
              "${req.allocatedQuantity.toStringAsFixed(0)}",
              style: TextStyle(
                color: req.allocatedQuantity >= req.requiredQuantity ? const Color(0xFF10B981) : Colors.amber,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          // Installed Qty
          Expanded(
            flex: 1,
            child: Text(
              "${req.installedQuantity.toStringAsFixed(0)}",
              style: TextStyle(
                color: req.installedQuantity >= req.requiredQuantity ? AppTheme.tealPrimary : AppTheme.textMuted,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          // Fulfillment Status Badge
          Expanded(
            flex: 2,
            child: _buildFulfillmentBadge(req.fulfillmentStatus),
          ),

          // Installation Status Badge
          Expanded(
            flex: 2,
            child: _buildInstallationBadge(req.installationStatus),
          ),

          // Action Buttons
          SizedBox(
            width: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (req.fulfillmentStatus == 'PROCUREMENT_PENDING' || req.fulfillmentStatus == 'UNFULFILLED')
                  IconButton(
                    tooltip: "Allocate Warehouse Stock",
                    icon: const Icon(Icons.inventory_2_outlined, color: AppTheme.goldPrimary, size: 20),
                    onPressed: () => _showAllocateDialog(context, req, state),
                  ),
                if (req.fulfillmentStatus == 'PROCUREMENT_PENDING')
                  IconButton(
                    tooltip: "Raise Vendor PO Requisition",
                    icon: const Icon(Icons.post_add, color: Colors.amber, size: 20),
                    onPressed: () => _showRaisePoDialog(context, req, state),
                  ),
                IconButton(
                  tooltip: "Specification Details",
                  icon: const Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 20),
                  onPressed: () => _showSpecDetailsModal(context, req),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFulfillmentBadge(String status) {
    Color bg;
    Color text;
    String label;
    IconData icon;

    switch (status) {
      case 'FULFILLED_WAREHOUSE':
        bg = const Color(0xFF10B981).withOpacity(0.15);
        text = const Color(0xFF10B981);
        label = "Warehouse Fulfilled";
        icon = Icons.check_circle;
        break;
      case 'PROCUREMENT_PENDING':
        bg = Colors.amber.withOpacity(0.15);
        text = Colors.amber;
        label = "Procurement Pending";
        icon = Icons.error_outline;
        break;
      case 'PARTIALLY_FULFILLED':
        bg = Colors.blue.withOpacity(0.15);
        text = Colors.blue;
        label = "Partially Fulfilled";
        icon = Icons.timelapse;
        break;
      default:
        bg = Colors.grey.withOpacity(0.15);
        text = Colors.grey;
        label = "Unfulfilled";
        icon = Icons.hourglass_empty;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: text.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: text, fontSize: 11, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstallationBadge(String status) {
    final isConfirmed = status == 'INSTALLED_CONFIRMED';
    final color = isConfirmed ? AppTheme.tealPrimary : AppTheme.textMuted;
    final label = isConfirmed ? "Installed Confirmed" : "Pending Delivery";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isConfirmed ? Icons.task_alt : Icons.local_shipping_outlined, color: color, size: 13),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Auto-Match Trigger
  void _handleAutoMatch(BuildContext context, AppState state) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppTheme.goldPrimary),
      ),
    );

    final res = await state.autoMatchMaterials();
    if (context.mounted) {
      Navigator.of(context).pop();
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.surfaceDark,
          title: Row(
            children: const [
              Icon(Icons.auto_awesome, color: AppTheme.goldPrimary),
              SizedBox(width: 10),
              Text("Auto-Match Execution Complete", style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
            ],
          ),
          content: Text(
            res["message"] ?? "Warehouse stock verified and allocated against site specifications.",
            style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary, foregroundColor: Colors.black),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("OK"),
            )
          ],
        ),
      );
    }
  }

  // Allocate Stock Dialog
  void _showAllocateDialog(BuildContext context, MaterialRequirementModel req, AppState state) {
    double reqQty = req.requiredQuantity - req.allocatedQuantity;
    if (reqQty <= 0) reqQty = 1;
    final qtyController = TextEditingController(text: reqQty.toStringAsFixed(0));
    String? selectedInvId = state.inventory.isNotEmpty ? state.inventory.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            title: Text("Allocate Warehouse Stock: ${req.itemName}",
                style: const TextStyle(color: AppTheme.textLight, fontSize: 16)),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Match with Warehouse SKU / Available Stock:",
                      style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedInvId,
                    dropdownColor: AppTheme.surfaceDark,
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    items: state.inventory.map((inv) {
                      return DropdownMenuItem<String>(
                        value: inv.id,
                        child: Text(
                          "${inv.sku} - ${inv.name} (Avail: ${inv.availableStock.toStringAsFixed(0)} ${inv.unit})",
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setDlgState(() => selectedInvId = val),
                  ),
                  const SizedBox(height: 16),
                  const Text("Quantity to Allocate:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: AppTheme.textLight),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.surfaceCard,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      helperText: "Transaction checks available stock >= quantity. Deficit branches to PO requisition.",
                      helperStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary, foregroundColor: Colors.black),
                onPressed: () async {
                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                  Navigator.of(ctx).pop();
                  await state.allocateMaterial(req.id, qty, inventoryItemId: selectedInvId);
                },
                child: const Text("Execute Allocation"),
              )
            ],
          );
        },
      ),
    );
  }

  // Raise PO Dialog
  void _showRaisePoDialog(BuildContext context, MaterialRequirementModel req, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: Row(
          children: const [
            Icon(Icons.shopping_cart, color: Colors.amber),
            SizedBox(width: 8),
            Text("Procurement Purchase Order", style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Stock deficit identified for: ${req.itemName}.",
                style: const TextStyle(color: AppTheme.textLight, fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            Text("Deficit Quantity: ${(req.requiredQuantity - req.allocatedQuantity).toStringAsFixed(0)} units required.",
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              child: const Text(
                "Automated Purchase Order requisition PO-2026-MRP will be generated and assigned to primary trade vendor.",
                style: TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Dismiss", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Purchase Order issued to trade supplier.")),
              );
            },
            child: const Text("Confirm PO Requisition"),
          ),
        ],
      ),
    );
  }

  // Add Specification Dialog
  void _showAddSpecificationDialog(BuildContext context, AppState state) {
    final nameCtrl = TextEditingController();
    final catCtrl = TextEditingController(text: "Flooring & Marble");
    final qtyCtrl = TextEditingController(text: "10");
    final finishCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text("Ingest Site Material Specification",
            style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Material / Item Name:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "e.g., Calacatta Viola Marble Slabs",
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Category:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: catCtrl,
                          style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Required Qty:", style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppTheme.surfaceCard,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text("Specification Details (Finish / Grade / Notes):",
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              const SizedBox(height: 6),
              TextField(
                controller: finishCtrl,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                decoration: InputDecoration(
                  hintText: "e.g., Honed finish, 20mm bookmatched, anti-slip sealer",
                  filled: true,
                  fillColor: AppTheme.surfaceCard,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text("Cancel", style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.goldPrimary, foregroundColor: Colors.black),
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty) return;
              final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
              Navigator.of(ctx).pop();
              await state.ingestMaterialRequirement({
                "item_name": nameCtrl.text.trim(),
                "item_category": catCtrl.text.trim(),
                "required_quantity": qty,
                "specification_details": {
                  "details": finishCtrl.text.trim(),
                }
              });
            },
            child: const Text("Save Specification"),
          )
        ],
      ),
    );
  }

  // Spec Details Modal
  void _showSpecDetailsModal(BuildContext context, MaterialRequirementModel req) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(req.itemName, style: const TextStyle(color: AppTheme.textLight, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text("Category: ${req.itemCategory} | Required: ${req.requiredQuantity} | Allocated: ${req.allocatedQuantity}",
                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
              const Divider(color: AppTheme.surfaceBorder, height: 24),
              const Text("Technical Specifications & Schedule:",
                  style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              if (req.specificationDetails.isEmpty)
                const Text("No additional technical parameters recorded.", style: TextStyle(color: AppTheme.textMuted))
              else
                ...req.specificationDetails.entries.map((e) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text("${e.key}: ${e.value}", style: const TextStyle(color: AppTheme.textLight, fontSize: 13)),
                    )),
              const SizedBox(height: 16),
              const Text("Allocations & Dispatches:",
                  style: TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(height: 8),
              if (req.allocations.isEmpty)
                const Text("No active warehouse allocations linked.", style: TextStyle(color: AppTheme.textMuted))
              else
                ...req.allocations.map((a) => Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.surfaceBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Status: ${a.status} (Qty: ${a.allocatedQuantity})",
                              style: const TextStyle(color: AppTheme.textLight, fontSize: 12)),
                          if (a.gatePassNumber != null)
                            Text("Gate Pass: ${a.gatePassNumber}",
                                style: const TextStyle(color: AppTheme.tealPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }
}
