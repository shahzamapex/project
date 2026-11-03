import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/inventory_model.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class InventoryWarehouseScreen extends StatelessWidget {
  const InventoryWarehouseScreen({super.key});

  void _showDispatchDialog(BuildContext context, InventoryItemModel item, AppState state) {
    int quantityToDispatch = 1;
    final notesController = TextEditingController(text: "Dispatched to site for installation");

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceCard,
          title: Text("Dispatch: ${item.name}", style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SKU: ${item.sku} • In Stock: ${item.quantity} ${item.unit} • Zone: ${item.warehouseZone}", style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 18),
                const Text("Destination Project", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.surfaceBorder),
                  ),
                  child: Text(state.selectedProject?.title ?? "Tribeca Penthouse 42", style: const TextStyle(color: AppTheme.goldPrimary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Quantity to Dispatch", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.goldPrimary),
                          onPressed: quantityToDispatch > 1 ? () => setDialogState(() => quantityToDispatch--) : null,
                        ),
                        Text("$quantityToDispatch ${item.unit}", style: const TextStyle(color: AppTheme.textLight, fontSize: 15, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline, color: AppTheme.goldPrimary),
                          onPressed: quantityToDispatch < item.quantity ? () => setDialogState(() => quantityToDispatch++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text("Dispatch Notes", style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(hintText: "e.g. Master bathroom cladding install"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                await state.dispatchStock(item.id, quantityToDispatch, notesController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Dispatched $quantityToDispatch ${item.unit} of '${item.name}' to site.")),
                );
              },
              child: const Text("Confirm Dispatch"),
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
    final inventory = state.inventory;

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
                children: const [
                  Text(
                    "Warehouse & Material Inventory Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Track Luxury Fixtures, Calacatta Marble, Millwork Veneers, and Project Dispatches across Warehouse Zones",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Barcode scanning and restock order creation initiated.")),
                  );
                },
                icon: const Icon(Icons.add_box_outlined, size: 16),
                label: const Text("Receive Shipment"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Zone Breakdown Cards
          Row(
            children: [
              _zoneSummaryCard("Zone A (Stone & Heavy)", "${inventory.where((i) => i.warehouseZone.contains('Zone A')).length} SKUs", Icons.terrain, AppTheme.tealAccent),
              const SizedBox(width: 16),
              _zoneSummaryCard("Zone B (Woodcraft Veneers)", "${inventory.where((i) => i.warehouseZone.contains('Zone B')).length} SKUs", Icons.forest, AppTheme.amberWarning),
              const SizedBox(width: 16),
              _zoneSummaryCard("Zone C (Lighting & Fragile)", "${inventory.where((i) => i.warehouseZone.contains('Zone C')).length} SKUs", Icons.lightbulb_outline, AppTheme.goldPrimary),
              const SizedBox(width: 16),
              _zoneSummaryCard("Zone D/E (Fabrics & Hardware)", "${inventory.where((i) => i.warehouseZone.contains('Zone D') || i.warehouseZone.contains('Zone E')).length} SKUs", Icons.plumbing, AppTheme.emeraldSuccess),
            ],
          ),

          const SizedBox(height: 28),

          // Inventory Table
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
                  children: [
                    const Text("Stock Inventory Records", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    Text("${inventory.length} Total SKUs", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 18),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: inventory.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 20),
                  itemBuilder: (context, index) {
                    final item = inventory[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: item.status == 'Low Stock' ? AppTheme.roseDanger.withOpacity(0.15) : AppTheme.goldPrimary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              item.status == 'Low Stock' ? Icons.warning_amber : Icons.inventory_2_outlined,
                              color: item.status == 'Low Stock' ? AppTheme.roseDanger : AppTheme.goldPrimary,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                const SizedBox(height: 2),
                                Text("SKU: ${item.sku} • Category: ${item.category} • Zone: ${item.warehouseZone}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${item.quantity} ${item.unit}", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: item.status == 'Low Stock' ? AppTheme.roseDanger : AppTheme.textLight)),
                                Text("Min Threshold: ${item.minThreshold} ${item.unit}", style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Text(currency.format(item.unitPrice), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                          const SizedBox(width: 20),
                          StatusBadge(label: item.status, type: "status"),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: item.quantity > 0 ? () => _showDispatchDialog(context, item, state) : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.surfaceDark,
                              foregroundColor: AppTheme.goldPrimary,
                              side: const BorderSide(color: AppTheme.goldPrimary),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            child: const Text("Dispatch to Site", style: TextStyle(fontSize: 12)),
                          ),
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

  Widget _zoneSummaryCard(String title, String count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppTheme.surfaceBorder),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 11, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Text(count, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
