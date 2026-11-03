class MaterialAllocationModel {
  final String id;
  final String requirementId;
  final String? inventoryItemId;
  final String itemName;
  final String? projectId;
  final double allocatedQuantity;
  String status; // RESERVED, DISPATCHED_TO_SITE, CONSUMED_INSTALLED
  final String? allocatedBy;
  String? installedBy;
  String? proofAttachmentUrl;
  String? gatePassNumber;
  String? notes;
  final String createdAt;
  String updatedAt;

  MaterialAllocationModel({
    required this.id,
    required this.requirementId,
    this.inventoryItemId,
    required this.itemName,
    this.projectId,
    required this.allocatedQuantity,
    required this.status,
    this.allocatedBy,
    this.installedBy,
    this.proofAttachmentUrl,
    this.gatePassNumber,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialAllocationModel.fromJson(Map<String, dynamic> json) {
    return MaterialAllocationModel(
      id: json['id'] ?? '',
      requirementId: json['requirement_id'] ?? '',
      inventoryItemId: json['inventory_item_id'],
      itemName: json['item_name'] ?? 'Material Item',
      projectId: json['project_id'],
      allocatedQuantity: (json['allocated_quantity'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'RESERVED',
      allocatedBy: json['allocated_by'],
      installedBy: json['installed_by'],
      proofAttachmentUrl: json['proof_attachment_url'],
      gatePassNumber: json['gate_pass_number'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'requirement_id': requirementId,
    'inventory_item_id': inventoryItemId,
    'item_name': itemName,
    'project_id': projectId,
    'allocated_quantity': allocatedQuantity,
    'status': status,
    'allocated_by': allocatedBy,
    'installed_by': installedBy,
    'proof_attachment_url': proofAttachmentUrl,
    'gate_pass_number': gatePassNumber,
    'notes': notes,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

class MaterialRequirementModel {
  final String id;
  final String projectId;
  final String itemName;
  final String itemCategory;
  final Map<String, dynamic> specificationDetails;
  final double requiredQuantity;
  double allocatedQuantity;
  double installedQuantity;
  String fulfillmentStatus; // UNFULFILLED, FULFILLED_WAREHOUSE, PROCUREMENT_PENDING
  String installationStatus; // PENDING_DELIVERY, INSTALLED_CONFIRMED
  final List<MaterialAllocationModel> allocations;
  final String createdAt;
  String updatedAt;

  MaterialRequirementModel({
    required this.id,
    required this.projectId,
    required this.itemName,
    required this.itemCategory,
    required this.specificationDetails,
    required this.requiredQuantity,
    required this.allocatedQuantity,
    required this.installedQuantity,
    required this.fulfillmentStatus,
    required this.installationStatus,
    this.allocations = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialRequirementModel.fromJson(Map<String, dynamic> json) {
    var rawAllocs = json['allocations'] as List? ?? [];
    return MaterialRequirementModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      itemName: json['item_name'] ?? '',
      itemCategory: json['item_category'] ?? 'General',
      specificationDetails: json['specification_details'] as Map<String, dynamic>? ?? {},
      requiredQuantity: (json['required_quantity'] as num?)?.toDouble() ?? 0.0,
      allocatedQuantity: (json['allocated_quantity'] as num?)?.toDouble() ?? 0.0,
      installedQuantity: (json['installed_quantity'] as num?)?.toDouble() ?? 0.0,
      fulfillmentStatus: json['fulfillment_status'] ?? 'UNFULFILLED',
      installationStatus: json['installation_status'] ?? 'PENDING_DELIVERY',
      allocations: rawAllocs.map((a) => MaterialAllocationModel.fromJson(a)).toList(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'project_id': projectId,
    'item_name': itemName,
    'item_category': itemCategory,
    'specification_details': specificationDetails,
    'required_quantity': requiredQuantity,
    'allocated_quantity': allocatedQuantity,
    'installed_quantity': installedQuantity,
    'fulfillment_status': fulfillmentStatus,
    'installation_status': installationStatus,
    'allocations': allocations.map((a) => a.toJson()).toList(),
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
