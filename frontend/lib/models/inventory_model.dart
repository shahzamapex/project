class InventoryItemModel {
  final String id;
  final String sku;
  final String name;
  final String category;
  int quantity;
  final String unit;
  final int minThreshold;
  final double unitPrice;
  final String warehouseZone;
  String status;
  double totalStock;
  double reservedStock;
  double availableStock;

  InventoryItemModel({
    required this.id,
    required this.sku,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.minThreshold,
    required this.unitPrice,
    required this.warehouseZone,
    required this.status,
    double? totalStock,
    double? reservedStock,
    double? availableStock,
  })  : totalStock = totalStock ?? quantity.toDouble(),
        reservedStock = reservedStock ?? 0.0,
        availableStock = availableStock ?? ((totalStock ?? quantity.toDouble()) - (reservedStock ?? 0.0));

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    final int qty = json['quantity'] ?? (json['total_stock'] as num?)?.toInt() ?? 0;
    final double tot = (json['total_stock'] as num?)?.toDouble() ?? qty.toDouble();
    final double res = (json['reserved_stock'] as num?)?.toDouble() ?? 0.0;
    final double avail = (json['available_stock'] as num?)?.toDouble() ?? (tot - res);
    return InventoryItemModel(
      id: json['id'] ?? '',
      sku: json['sku'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'General',
      quantity: qty,
      unit: json['unit'] ?? 'pcs',
      minThreshold: json['min_threshold'] ?? 10,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      warehouseZone: json['warehouse_zone'] ?? 'Zone A',
      status: json['status'] ?? 'In Stock',
      totalStock: tot,
      reservedStock: res,
      availableStock: avail,
    );
  }
}

class WarehouseTransactionModel {
  final String id;
  final String itemId;
  final String? itemName;
  final String? projectId;
  final String transactionType; // IN_RESTOCK, OUT_DISPATCH
  final int quantity;
  final String date;
  final String? notes;

  WarehouseTransactionModel({
    required this.id,
    required this.itemId,
    this.itemName,
    this.projectId,
    required this.transactionType,
    required this.quantity,
    required this.date,
    this.notes,
  });

  factory WarehouseTransactionModel.fromJson(Map<String, dynamic> json) {
    return WarehouseTransactionModel(
      id: json['id'] ?? '',
      itemId: json['item_id'] ?? '',
      itemName: json['item_name'],
      projectId: json['project_id'],
      transactionType: json['transaction_type'] ?? 'OUT_DISPATCH',
      quantity: json['quantity'] ?? 0,
      date: json['date'] ?? '',
      notes: json['notes'],
    );
  }
}

class VendorModel {
  final String id;
  final String name;
  final String contactPerson;
  final String email;
  final String phone;
  final String category;
  final double rating;

  VendorModel({
    required this.id,
    required this.name,
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.category,
    required this.rating,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      contactPerson: json['contact_person'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      category: json['category'] ?? 'Supplier',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }
}

class PurchaseOrderModel {
  final String id;
  final String vendorId;
  final String? projectId;
  final String poNumber;
  final double totalAmount;
  final String status;
  final String orderDate;
  final String? expectedDelivery;

  PurchaseOrderModel({
    required this.id,
    required this.vendorId,
    this.projectId,
    required this.poNumber,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.expectedDelivery,
  });

  factory PurchaseOrderModel.fromJson(Map<String, dynamic> json) {
    return PurchaseOrderModel(
      id: json['id'] ?? '',
      vendorId: json['vendor_id'] ?? '',
      projectId: json['project_id'],
      poNumber: json['po_number'] ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Issued',
      orderDate: json['order_date'] ?? '',
      expectedDelivery: json['expected_delivery'],
    );
  }
}
