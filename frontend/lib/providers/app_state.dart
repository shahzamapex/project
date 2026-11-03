import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/project_model.dart';
import '../models/task_model.dart';
import '../models/drawing_model.dart';
import '../models/inventory_model.dart';
import '../models/client_portal_model.dart';
import '../models/ai_prediction_model.dart';
import '../models/material_requirement_model.dart';
import '../services/api_service.dart';

enum AppTab {
  dashboard,
  ocrTasks,
  drawings,
  aiAnalytics,
  warehouse,
  clientPortal,
  sites,
  vendors,
  fulfillmentMatrix,
  installationSignoff,
  warehouseDispatcher,
}

class AppState extends ChangeNotifier {
  final ApiService _api = ApiService();
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Cloud Backend & Supabase Status
  String _backendUrl = ApiService.baseUrl;
  String get backendUrl => _backendUrl;
  bool _isBackendOnline = false;
  bool get isBackendOnline => _isBackendOnline;
  Map<String, dynamic> _supabaseStatus = {
    "connected": false,
    "status": "checking",
    "message": "Initializing cloud connection check..."
  };
  Map<String, dynamic> get supabaseStatus => _supabaseStatus;

  Future<void> checkCloudConnectivity() async {
    final backendHealth = await _api.checkBackendHealth();
    _isBackendOnline = backendHealth["online"] == true;
    _supabaseStatus = await _api.checkSupabaseStatus();
    notifyListeners();
  }

  Future<void> updateBackendUrl(String newUrl) async {
    ApiService.setBaseUrl(newUrl);
    _backendUrl = ApiService.baseUrl;
    _isLoading = true;
    notifyListeners();

    await checkCloudConnectivity();
    await refreshData();
    _isLoading = false;

    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Backend Endpoint Reconfigured",
      "body": "Active API route changed to '$_backendUrl'. Live server: ${_isBackendOnline ? 'ONLINE' : 'OFFLINE (Fallback Active)'}.",
      "severity": _isBackendOnline ? "info" : "high",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
  }

  // Active Role and User
  UserModel _currentUser = UserModel(
    id: "u-owner-001",
    email: "owner@interiorcraft.com",
    fullName: "Elena Vance (Principal Architect)",
    role: "owner",
    phone: "+1 (555) 234-5678",
    avatarUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150",
  );
  UserModel get currentUser => _currentUser;
  String get userRole => _currentUser.role;

  // Navigation
  AppTab _activeTab = AppTab.dashboard;
  AppTab get activeTab => _activeTab;

  void setActiveTab(AppTab tab) {
    _activeTab = tab;
    notifyListeners();
  }

  // Projects
  List<ProjectModel> _projects = [];
  List<ProjectModel> get projects => _projects;
  ProjectModel? _selectedProject;
  ProjectModel? get selectedProject => _selectedProject;

  void setSelectedProject(ProjectModel p) {
    _selectedProject = p;
    refreshData();
  }

  // Tasks
  List<TaskModel> _tasks = [];
  List<TaskModel> get tasks => _tasks;

  // AI Prediction
  AIPredictionResult? _aiPrediction;
  AIPredictionResult? get aiPrediction => _aiPrediction;

  // Drawings & Markups
  List<DrawingModel> _drawings = [];
  List<DrawingModel> get drawings => _drawings;
  DrawingModel? _selectedDrawing;
  DrawingModel? get selectedDrawing => _selectedDrawing;
  List<DrawingMarkupModel> _markups = [];
  List<DrawingMarkupModel> get markups => _markups;

  // Inventory & Warehouse
  List<InventoryItemModel> _inventory = [];
  List<InventoryItemModel> get inventory => _inventory;

  // Client Portal
  List<ClientApprovalModel> _clientApprovals = [];
  List<ClientApprovalModel> get clientApprovals => _clientApprovals;
  List<InvoiceModel> _invoices = [];
  List<InvoiceModel> get invoices => _invoices;

  // Vendors & POs
  List<VendorModel> _vendors = [];
  List<VendorModel> get vendors => _vendors;
  List<PurchaseOrderModel> _purchaseOrders = [];
  List<PurchaseOrderModel> get purchaseOrders => _purchaseOrders;

  // Material Requirements Planning (MRP) & Site Allocation
  List<MaterialRequirementModel> _materialRequirements = [];
  List<MaterialRequirementModel> get materialRequirements => _materialRequirements;
  List<MaterialAllocationModel> _reservedAllocations = [];
  List<MaterialAllocationModel> get reservedAllocations => _reservedAllocations;

  // Notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      "id": "notif-1",
      "title": "AI Risk Warning: Tribeca Living Gallery",
      "body": "Scikit-Learn model flags a 2.8 day variance in custom fluted walnut millwork.",
      "severity": "high",
      "timestamp": "12m ago",
      "read": false
    },
    {
      "id": "notif-2",
      "title": "Upcoming Deadline: Calacatta Viola Island",
      "body": "Inspect marble veining continuity before island substrate installation.",
      "severity": "medium",
      "timestamp": "1h ago",
      "read": false
    },
    {
      "id": "notif-3",
      "title": "Payment Received: Milestone 2 (\$145,000)",
      "body": "Invoice INV-2026-102 settled by Client David Sterling via Wire Transfer.",
      "severity": "info",
      "timestamp": "4h ago",
      "read": true
    }
  ];
  List<Map<String, dynamic>> get notifications => _notifications;

  // Initialize
  AppState() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await checkCloudConnectivity();

    _projects = await _api.getProjects();
    if (_projects.isNotEmpty) {
      _selectedProject = _projects.first;
    }

    await refreshData();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    final projId = _selectedProject?.id;
    await checkCloudConnectivity();
    _tasks = await _api.getTasks(projectId: projId);
    if (projId != null) {
      _aiPrediction = await _api.getAIPredictions(projId);
    }
    _drawings = await _api.getDrawings(projectId: projId);
    if (_drawings.isNotEmpty) {
      _selectedDrawing = _drawings.first;
      _markups = await _api.getMarkups(_selectedDrawing!.id);
    }
    _inventory = await _api.getInventory();
    _clientApprovals = await _api.getClientApprovals(projectId: projId);
    _invoices = await _api.getInvoices(projectId: projId);
    _vendors = await _api.getVendors();
    _purchaseOrders = await _api.getPurchaseOrders();
    _materialRequirements = await _api.getMaterialRequirements(projectId: projId);
    _reservedAllocations = await _api.getReservedAllocations(projectId: projId);

    notifyListeners();
  }

  // Switch Role (for interactive demoing of Owner, Engineer, Client)
  void switchRole(String role) {
    if (role == 'owner') {
      _currentUser = UserModel(
        id: "u-owner-001",
        email: "owner@interiorcraft.com",
        fullName: "Elena Vance (Principal Architect)",
        role: "owner",
        avatarUrl: "https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150",
      );
      _activeTab = AppTab.dashboard;
    } else if (role == 'engineer') {
      _currentUser = UserModel(
        id: "u-eng-001",
        email: "marcus.lee@interiorcraft.com",
        fullName: "Marcus Lee (Lead Site Engineer)",
        role: "engineer",
        avatarUrl: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150",
      );
      _activeTab = AppTab.dashboard;
    } else {
      _currentUser = UserModel(
        id: "u-client-001",
        email: "david.sterling@aurorainvest.com",
        fullName: "David Sterling (Penthouse Client)",
        role: "client",
        avatarUrl: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150",
      );
      _activeTab = AppTab.clientPortal;
    }
    notifyListeners();
  }

  // Dynamic Role Update (Owner capability)
  Future<bool> updateTeamMemberRole(String userId, String newRole) async {
    bool ok = await _api.assignUserRole(userId, newRole);
    if (ok) {
      _notifications.insert(0, {
        "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
        "title": "Role Permission Updated",
        "body": "User role dynamically changed to '$newRole'.",
        "severity": "info",
        "timestamp": "Just now",
        "read": false
      });
      notifyListeners();
    }
    return ok;
  }

  // Task Progress Update
  Future<void> updateTaskProgress(String taskId, int progress, String status, int actualDays) async {
    final task = _tasks.firstWhere((t) => t.id == taskId);
    task.completionPercent = progress;
    task.status = status;
    task.actualDays = actualDays;

    await _api.updateTaskProgress(taskId, progress, status, actualDays);
    
    // Refresh AI prediction based on new progress
    if (_selectedProject != null) {
      _aiPrediction = await _api.getAIPredictions(_selectedProject!.id);
    }
    notifyListeners();
  }

  // OCR Task Upload
  Future<Map<String, dynamic>> uploadDocumentOCR(Uint8List fileBytes, String filename) async {
    if (_selectedProject == null) return {};
    _isLoading = true;
    notifyListeners();

    final result = await _api.uploadDocumentOCR(_selectedProject!.id, fileBytes, filename, autoSave: true);
    
    // Refresh task list
    _tasks = await _api.getTasks(projectId: _selectedProject!.id);
    _aiPrediction = await _api.getAIPredictions(_selectedProject!.id);
    
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "OCR Task Extraction Complete",
      "body": "Imported ${result['tasks_detected_count'] ?? 4} tasks from '$filename' to ${_selectedProject!.title}.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });

    _isLoading = false;
    notifyListeners();
    return result;
  }

  // Drawing Selection & Markups
  void selectDrawing(DrawingModel d) async {
    _selectedDrawing = d;
    _markups = await _api.getMarkups(d.id);
    notifyListeners();
  }

  Future<void> addDrawingMarkup(DrawingMarkupModel newMarkup) async {
    _markups.insert(0, newMarkup);
    if (_selectedDrawing != null) {
      await _api.saveDrawingMarkup(
        _selectedDrawing!.id,
        {
          "strokes": newMarkup.strokes.map((s) => s.toJson()).toList(),
          "annotations": newMarkup.annotations.map((a) => a.toJson()).toList(),
        },
        newMarkup.comment,
      );
    }
    notifyListeners();
  }

  // Inventory Dispatch
  Future<void> dispatchStock(String itemId, int qty, String notes) async {
    if (_selectedProject == null) return;
    await _api.recordDispatch(itemId, _selectedProject!.id, qty, notes);
    _inventory = await _api.getInventory();
    notifyListeners();
  }

  // Client Portal Decision
  Future<void> submitApprovalDecision(String approvalId, String status, String feedback) async {
    final item = _clientApprovals.firstWhere((a) => a.id == approvalId);
    item.status = status;
    item.clientFeedback = feedback;

    await _api.decideApproval(approvalId, status, feedback);
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Client Design Review Received",
      "body": "${_currentUser.fullName} marked '${item.title}' as $status.",
      "severity": status == 'Approved' ? "info" : "high",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
  }

  // Invoice Payment
  Future<void> submitInvoicePayment(String invoiceId, String paymentMethod) async {
    final inv = _invoices.firstWhere((i) => i.id == invoiceId);
    inv.status = "Paid";

    await _api.payInvoice(invoiceId, paymentMethod);
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Milestone Payment Processed",
      "body": "Invoice ${inv.invoiceNumber} (\$${inv.amount.toStringAsFixed(0)}) paid via $paymentMethod.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
  }

  void markNotificationRead(String id) {
    final notif = _notifications.firstWhere((n) => n["id"] == id);
    notif["read"] = true;
    notifyListeners();
  }

  // MRP / Material Fulfillment Actions
  Future<bool> ingestMaterialRequirement(Map<String, dynamic> data) async {
    if (_selectedProject == null) return false;
    final created = await _api.ingestMaterialRequirement(_selectedProject!.id, data);
    if (created != null) {
      _materialRequirements.insert(0, created);
      _notifications.insert(0, {
        "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
        "title": "Site Specification Ingested",
        "body": "Requirement '${created.itemName}' (Qty: ${created.requiredQuantity}) added to BOM.",
        "severity": "info",
        "timestamp": "Just now",
        "read": false
      });
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> allocateMaterial(
    String requirementId,
    double qty, {
    String? inventoryItemId,
  }) async {
    final result = await _api.allocateMaterial(requirementId, qty, inventoryItemId: inventoryItemId);
    await refreshData();
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": result["fulfillment_status"] == "PROCUREMENT_PENDING"
          ? "Procurement Requisition Generated"
          : "Warehouse Material Allocated",
      "body": result["message"] ?? "Allocation processed.",
      "severity": result["fulfillment_status"] == "PROCUREMENT_PENDING" ? "high" : "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> autoMatchMaterials() async {
    if (_selectedProject == null) return {};
    _isLoading = true;
    notifyListeners();
    final result = await _api.autoMatchMaterials(_selectedProject!.id);
    await refreshData();
    _isLoading = false;
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "MRP Auto-Match Completed",
      "body": result["message"] ?? "Warehouse stock matched to site specifications.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> dispatchAllocation(String allocationId, {String? gatePassNumber}) async {
    final result = await _api.dispatchAllocation(allocationId, gatePassNumber: gatePassNumber);
    await refreshData();
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Material Dispatched to Site",
      "body": "Gate Pass ${result["gate_pass_number"]} issued for transit.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> batchDispatchAllocations(List<String> allocationIds, {String? gatePassNumber}) async {
    final result = await _api.batchDispatchAllocations(allocationIds, gatePassNumber: gatePassNumber);
    await refreshData();
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Batch Gate Pass Authorized",
      "body": "Dispatched ${allocationIds.length} items under Gate Pass ${result["gate_pass_number"]}.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> confirmInstallation(
    String requirementId,
    double quantityInstalled, {
    String? notes,
    String? proofAttachmentUrl,
  }) async {
    final result = await _api.confirmInstallation(
      requirementId,
      quantityInstalled: quantityInstalled,
      notes: notes,
      proofAttachmentUrl: proofAttachmentUrl,
      engineerId: _currentUser.id,
    );
    await refreshData();
    _notifications.insert(0, {
      "id": "notif-${DateTime.now().millisecondsSinceEpoch}",
      "title": "Site Installation Confirmed",
      "body": "Fitment sign-off logged for Qty $quantityInstalled with audit proof.",
      "severity": "info",
      "timestamp": "Just now",
      "read": false
    });
    notifyListeners();
    return result;
  }
}
