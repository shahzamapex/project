import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/status_badge.dart';

class VendorManagementScreen extends StatelessWidget {
  const VendorManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final currency = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    final vendors = state.vendors;
    final pos = state.purchaseOrders;

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
                    "Vendor & Procurement Management",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Curated Tier-1 Architectural Suppliers, Purchase Orders, and Delivery Tracking",
                    style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("New Purchase Order draft created.")),
                  );
                },
                icon: const Icon(Icons.receipt_long, size: 16),
                label: const Text("Issue New Purchase Order"),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Vendors Grid
          const Text("Architectural Vendors & Fabricators", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
          const SizedBox(height: 14),

          LayoutBuilder(
            builder: (context, constraints) {
              int crossCount = constraints.maxWidth > 950 ? 4 : (constraints.maxWidth > 650 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.35,
                ),
                itemCount: vendors.length,
                itemBuilder: (context, index) {
                  final v = vendors[index];
                  return Container(
                    padding: const EdgeInsets.all(16),
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
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.goldPrimary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(v.category.toUpperCase(), style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.star, color: AppTheme.goldPrimary, size: 14),
                                const SizedBox(width: 4),
                                Text("${v.rating}", style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(v.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textLight), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text("Contact: ${v.contactPerson}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.mail_outline, size: 12, color: AppTheme.textMuted),
                            const SizedBox(width: 6),
                            Expanded(child: Text(v.email, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted), overflow: TextOverflow.ellipsis)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),

          const SizedBox(height: 32),

          // Purchase Orders Table
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
                    const Text("Active Purchase Orders", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                    Text("${pos.length} Tracked Orders", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  ],
                ),
                const SizedBox(height: 18),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pos.length,
                  separatorBuilder: (_, __) => const Divider(color: AppTheme.surfaceBorder, height: 20),
                  itemBuilder: (context, index) {
                    final po = pos[index];
                    final vendor = vendors.firstWhere((v) => v.id == po.vendorId, orElse: () => vendors.first);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppTheme.tealAccent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(Icons.local_shipping_outlined, color: AppTheme.tealAccent, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("PO: ${po.poNumber} • ${vendor.name}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textLight)),
                                const SizedBox(height: 2),
                                Text("Ordered: ${po.orderDate} • Expected Delivery: ${po.expectedDelivery ?? 'TBD'}", style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              ],
                            ),
                          ),
                          Text(currency.format(po.totalAmount), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.goldPrimary)),
                          const SizedBox(width: 20),
                          StatusBadge(label: po.status, type: "status"),
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
}
