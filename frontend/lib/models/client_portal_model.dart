class ClientApprovalModel {
  final String id;
  final String projectId;
  final String title;
  final String stage; // Moodboard, 3D Render, Material Palette, etc.
  final String mediaUrl;
  final String description;
  String status; // Pending, Approved, Revision Requested
  String clientFeedback;
  final String submittedAt;
  final String? respondedAt;

  ClientApprovalModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.stage,
    required this.mediaUrl,
    required this.description,
    required this.status,
    this.clientFeedback = '',
    required this.submittedAt,
    this.respondedAt,
  });

  factory ClientApprovalModel.fromJson(Map<String, dynamic> json) {
    return ClientApprovalModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      title: json['title'] ?? '',
      stage: json['stage'] ?? '3D Render',
      mediaUrl: json['media_url'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'Pending',
      clientFeedback: json['client_feedback'] ?? '',
      submittedAt: json['submitted_at'] ?? '',
      respondedAt: json['responded_at'],
    );
  }
}

class InvoiceModel {
  final String id;
  final String projectId;
  final String invoiceNumber;
  final String milestoneName;
  final double amount;
  final String dueDate;
  String status; // Pending, Paid, Overdue
  final String? paidAt;
  final String? paymentMethod;
  final String? notes;

  InvoiceModel({
    required this.id,
    required this.projectId,
    required this.invoiceNumber,
    required this.milestoneName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidAt,
    this.paymentMethod,
    this.notes,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    return InvoiceModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      invoiceNumber: json['invoice_number'] ?? '',
      milestoneName: json['milestone_name'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['due_date'] ?? '',
      status: json['status'] ?? 'Pending',
      paidAt: json['paid_at'],
      paymentMethod: json['payment_method'],
      notes: json['notes'],
    );
  }
}
