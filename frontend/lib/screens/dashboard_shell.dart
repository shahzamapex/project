import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/project_model.dart';
import '../theme/app_theme.dart';
import 'owner_dashboard.dart';
import 'engineer_dashboard.dart';
import 'client_portal_screen.dart';
import 'drawing_markup_center.dart';
import 'ocr_task_automation_screen.dart';
import 'ai_analytics_screen.dart';
import 'inventory_warehouse_screen.dart';
import 'site_management_screen.dart';
import 'vendor_management_screen.dart';
import 'fulfillment_matrix_screen.dart';
import 'installation_signoff_screen.dart';
import 'warehouse_dispatcher_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildActiveContent(AppState state) {
    switch (state.activeTab) {
      case AppTab.dashboard:
        if (state.userRole == 'owner') {
          return const OwnerDashboard();
        } else if (state.userRole == 'engineer') {
          return const EngineerDashboard();
        } else {
          return const ClientPortalScreen();
        }
      case AppTab.fulfillmentMatrix:
        return const FulfillmentMatrixScreen();
      case AppTab.installationSignoff:
        return const InstallationSignoffScreen();
      case AppTab.warehouseDispatcher:
        return const WarehouseDispatcherScreen();
      case AppTab.ocrTasks:
        return const OCRTaskAutomationScreen();
      case AppTab.drawings:
        return const DrawingMarkupCenter();
      case AppTab.aiAnalytics:
        return const AIAnalyticsScreen();
      case AppTab.warehouse:
        return const InventoryWarehouseScreen();
      case AppTab.clientPortal:
        return const ClientPortalScreen();
      case AppTab.sites:
        return const SiteManagementScreen();
      case AppTab.vendors:
        return const VendorManagementScreen();
    }
  }

  void _openNotificationsDrawer() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);
    final unreadCount = state.notifications.where((n) => n["read"] == false).length;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: _buildNotificationsDrawer(state),
      body: Row(
        children: [
          // Luxury Left Sidebar
          Container(
            width: 260,
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark,
              border: Border(right: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Brand Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.goldPrimary, AppTheme.brassAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.architecture, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "INTERIORCRAFT",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              color: AppTheme.textLight,
                            ),
                          ),
                          Text(
                            "STUDIO MANAGEMENT",
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.2,
                              color: AppTheme.goldPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Project Selector Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ProjectModel>(
                        value: state.selectedProject,
                        isExpanded: true,
                        dropdownColor: AppTheme.surfaceDark,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppTheme.goldPrimary, size: 18),
                        items: state.projects.map((p) {
                          return DropdownMenuItem<ProjectModel>(
                            value: p,
                            child: Text(
                              p.title,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (p) {
                          if (p != null) state.setSelectedProject(p);
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Items
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _navItem(
                        tab: AppTab.dashboard,
                        icon: Icons.dashboard_outlined,
                        activeIcon: Icons.dashboard,
                        title: state.userRole == 'owner'
                            ? "Executive Dashboard"
                            : (state.userRole == 'engineer' ? "Site Punch List" : "Project Progress"),
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.fulfillmentMatrix,
                        icon: Icons.playlist_add_check_circle_outlined,
                        activeIcon: Icons.playlist_add_check_circle,
                        title: "Fulfillment Matrix",
                        badge: "MRP",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.installationSignoff,
                        icon: Icons.verified_outlined,
                        activeIcon: Icons.verified,
                        title: "Installation Sign-Off",
                        badge: "Site Eng",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.warehouseDispatcher,
                        icon: Icons.departure_board_outlined,
                        activeIcon: Icons.departure_board,
                        title: "Warehouse Dispatch",
                        badge: "Gate Pass",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.drawings,
                        icon: Icons.draw_outlined,
                        activeIcon: Icons.draw,
                        title: "Drawings & Markups",
                        badge: "Interactive",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.ocrTasks,
                        icon: Icons.document_scanner_outlined,
                        activeIcon: Icons.document_scanner,
                        title: "OCR Task Engine",
                        badge: "Tesseract",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.aiAnalytics,
                        icon: Icons.psychology_outlined,
                        activeIcon: Icons.psychology,
                        title: "AI Predictive Analytics",
                        badge: "Scikit-Learn",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.warehouse,
                        icon: Icons.warehouse_outlined,
                        activeIcon: Icons.warehouse,
                        title: "Warehouse Inventory",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.clientPortal,
                        icon: Icons.view_in_ar_outlined,
                        activeIcon: Icons.view_in_ar,
                        title: "Client Portal & Invoices",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.sites,
                        icon: Icons.location_city_outlined,
                        activeIcon: Icons.location_city,
                        title: "Site Management",
                        state: state,
                      ),
                      _navItem(
                        tab: AppTab.vendors,
                        icon: Icons.local_shipping_outlined,
                        activeIcon: Icons.local_shipping,
                        title: "Vendors & Orders",
                        state: state,
                      ),
                    ],
                  ),
                ),

                // User Profile & System Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundImage: NetworkImage(state.currentUser.avatarUrl),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.currentUser.fullName.split(' ')[0],
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textLight),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.currentUser.role.toUpperCase(),
                              style: const TextStyle(fontSize: 10, color: AppTheme.goldPrimary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Screen Shell
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceDark,
                    border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
                  ),
                  child: Row(
                    children: [
                      // Breadcrumb
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Icon(Icons.home_outlined, size: 16, color: AppTheme.textMuted),
                              const SizedBox(width: 8),
                              const Text("/", style: TextStyle(color: AppTheme.surfaceBorder)),
                              const SizedBox(width: 8),
                              Text(
                                state.selectedProject?.title ?? "Studio Projects",
                                style: const TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              const Text("/", style: TextStyle(color: AppTheme.surfaceBorder)),
                              const SizedBox(width: 8),
                              Text(
                                _getTabTitle(state.activeTab),
                                style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Interactive Role Switcher Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.goldPrimary.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Text("View as Role: ", style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                            DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: state.userRole,
                                dropdownColor: AppTheme.surfaceDark,
                                icon: const Icon(Icons.arrow_drop_down, color: AppTheme.goldPrimary),
                                items: const [
                                  DropdownMenuItem(value: "owner", child: Text("👑 Owner", style: TextStyle(color: AppTheme.goldPrimary, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DropdownMenuItem(value: "engineer", child: Text("📐 Engineer", style: TextStyle(color: AppTheme.tealAccent, fontSize: 12, fontWeight: FontWeight.bold))),
                                  DropdownMenuItem(value: "client", child: Text("🌟 Client", style: TextStyle(color: AppTheme.warmCream, fontSize: 12, fontWeight: FontWeight.bold))),
                                ],
                                onChanged: (role) {
                                  if (role != null) state.switchRole(role);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Cloud & Supabase Connection Pill
                      InkWell(
                        onTap: () => _showCloudConnectionDialog(context, state),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceCard,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: state.isBackendOnline
                                  ? const Color(0xFF10B981)
                                  : Colors.amber.withOpacity(0.5),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: state.isBackendOnline
                                      ? const Color(0xFF10B981)
                                      : Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.isBackendOnline ? "API Live" : "API Offline",
                                style: TextStyle(
                                  color: state.isBackendOnline
                                      ? const Color(0xFF10B981)
                                      : Colors.amber,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 12,
                                color: AppTheme.surfaceBorder,
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.cloud_outlined,
                                size: 14,
                                color: state.supabaseStatus['connected'] == true
                                    ? AppTheme.tealPrimary
                                    : AppTheme.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                state.supabaseStatus['connected'] == true ? "Supabase" : "Mock Store",
                                style: TextStyle(
                                  color: state.supabaseStatus['connected'] == true
                                      ? AppTheme.tealPrimary
                                      : AppTheme.textMuted,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Notification Center Bell
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: AppTheme.textLight),
                            onPressed: _openNotificationsDrawer,
                          ),
                          if (unreadCount > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppTheme.roseDanger,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$unreadCount",
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Content View
                Expanded(
                  child: Container(
                    color: AppTheme.obsidian,
                    child: _buildActiveContent(state),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem({
    required AppTab tab,
    required IconData icon,
    required IconData activeIcon,
    required String title,
    String? badge,
    required AppState state,
  }) {
    final isSelected = state.activeTab == tab;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => state.setActiveTab(tab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.goldPrimary.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? AppTheme.goldPrimary.withOpacity(0.4) : Colors.transparent),
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 18,
                color: isSelected ? AppTheme.goldPrimary : AppTheme.textMuted,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isSelected ? AppTheme.textLight : AppTheme.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(color: AppTheme.goldPrimary, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsDrawer(AppState state) {
    return Drawer(
      backgroundColor: AppTheme.surfaceDark,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("System Alerts & SendGrid Logs", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                  Icon(Icons.mark_email_read_outlined, color: AppTheme.goldPrimary),
                ],
              ),
              const SizedBox(height: 6),
              const Text("Real-time notifications for deadlines, AI risks, and invoice payments.", style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const SizedBox(height: 18),
              const Divider(color: AppTheme.surfaceBorder),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: state.notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final n = state.notifications[index];
                    Color alertColor = n["severity"] == 'high' ? AppTheme.roseDanger : (n["severity"] == 'medium' ? AppTheme.amberWarning : AppTheme.tealAccent);
                    return InkWell(
                      onTap: () => state.markNotificationRead(n["id"]),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: n["read"] ? AppTheme.surfaceCard.withOpacity(0.4) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: n["read"] ? AppTheme.surfaceBorder : alertColor.withOpacity(0.5)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(n["title"], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textLight)),
                                ),
                                Text(n["timestamp"], style: const TextStyle(fontSize: 10, color: AppTheme.textMuted)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(n["body"], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTabTitle(AppTab tab) {
    switch (tab) {
      case AppTab.dashboard:
        return "Dashboard";
      case AppTab.ocrTasks:
        return "OCR Task Automation";
      case AppTab.drawings:
        return "Drawings & Markups";
      case AppTab.aiAnalytics:
        return "AI Predictive Analytics";
      case AppTab.warehouse:
        return "Warehouse Inventory";
      case AppTab.clientPortal:
        return "Client Portal";
      case AppTab.sites:
        return "Site Operations";
      case AppTab.vendors:
        return "Vendor Directory";
      case AppTab.fulfillmentMatrix:
        return "Fulfillment Matrix";
      case AppTab.installationSignoff:
        return "Installation Sign-off";
      case AppTab.warehouseDispatcher:
        return "Warehouse Dispatcher";
    }
  }

  void _showCloudConnectionDialog(BuildContext context, AppState state) {
    final urlController = TextEditingController(text: state.backendUrl);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) {
          final isOnline = state.isBackendOnline;
          final supa = state.supabaseStatus;

          return AlertDialog(
            backgroundColor: AppTheme.surfaceDark,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.cloud_sync, color: AppTheme.goldPrimary),
                SizedBox(width: 10),
                Text("Cloud Backend & Supabase Configuration",
                    style: TextStyle(color: AppTheme.textLight, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            content: SizedBox(
              width: 520,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Backend API Endpoint (FastAPI / Vercel):",
                        style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: urlController,
                      style: const TextStyle(color: AppTheme.textLight, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: "e.g. http://localhost:8000/api or https://your-app.vercel.app/api",
                        filled: true,
                        fillColor: AppTheme.surfaceCard,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setDlgState(() {
                              urlController.text = "http://localhost:8000/api";
                            });
                          },
                          icon: const Icon(Icons.computer, size: 14),
                          label: const Text("Use Localhost (8000)", style: TextStyle(fontSize: 11)),
                        ),
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setDlgState(() {
                              urlController.text = "https://backend-orpin-delta-43.vercel.app/api";
                            });
                          },
                          icon: const Icon(Icons.cloud_upload_outlined, size: 14),
                          label: const Text("Use Vercel URL", style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.surfaceBorder),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isOnline ? const Color(0xFF10B981) : Colors.amber.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      isOnline ? Icons.check_circle : Icons.error_outline,
                                      size: 16,
                                      color: isOnline ? const Color(0xFF10B981) : Colors.amber,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isOnline ? "FastAPI Online" : "FastAPI Offline",
                                      style: TextStyle(
                                        color: isOnline ? const Color(0xFF10B981) : Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOnline
                                      ? "Connected and responding to health check"
                                      : "Offline. Falling back to local data store",
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceCard,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: supa["connected"] == true
                                    ? AppTheme.tealPrimary
                                    : AppTheme.textMuted.withOpacity(0.5),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      supa["connected"] == true ? Icons.storage : Icons.storage_outlined,
                                      size: 16,
                                      color: supa["connected"] == true ? AppTheme.tealPrimary : AppTheme.textMuted,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      supa["connected"] == true ? "Supabase Live" : "Supabase Local",
                                      style: TextStyle(
                                        color: supa["connected"] == true ? AppTheme.tealPrimary : AppTheme.textMuted,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  supa["message"] ?? "Checking database...",
                                  style: const TextStyle(color: AppTheme.textMuted, fontSize: 10),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Deploying to Vercel & Supabase:",
                              style: TextStyle(color: AppTheme.goldPrimary, fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("1. In backend/: run 'vercel' or push to your GitHub repo connected to Vercel.",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          Text("2. In Vercel Project Settings -> Environment Variables, add:",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                          Text("   - SUPABASE_URL: (your project URL from Supabase dashboard)",
                              style: TextStyle(color: AppTheme.textLight, fontSize: 10)),
                          Text("   - SUPABASE_KEY: (your anon or service_role key)",
                              style: TextStyle(color: AppTheme.textLight, fontSize: 10)),
                          Text("3. Copy the assigned Vercel URL and paste it into the endpoint field above.",
                              style: TextStyle(color: AppTheme.textMuted, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text("Close", style: TextStyle(color: AppTheme.textMuted)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.goldPrimary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final newUrl = urlController.text.trim();
                  await state.updateBackendUrl(newUrl);
                  setDlgState(() {});
                  if (context.mounted) {
                    Navigator.of(ctx).pop();
                  }
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text("Apply & Connect"),
              ),
            ],
          );
        },
      ),
    );
  }
}
