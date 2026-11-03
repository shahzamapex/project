class ProjectModel {
  final String id;
  final String title;
  final String clientName;
  final String? clientId;
  final String status;
  final double budget;
  final double spent;
  final String startDate;
  final String targetEndDate;
  final int progressPercent;
  final String siteAddress;
  final String description;

  ProjectModel({
    required this.id,
    required this.title,
    required this.clientName,
    this.clientId,
    required this.status,
    required this.budget,
    required this.spent,
    required this.startDate,
    required this.targetEndDate,
    required this.progressPercent,
    required this.siteAddress,
    required this.description,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      clientName: json['client_name'] ?? 'Client',
      clientId: json['client_id'],
      status: json['status'] ?? 'In Progress',
      budget: (json['budget'] as num?)?.toDouble() ?? 0.0,
      spent: (json['spent'] as num?)?.toDouble() ?? 0.0,
      startDate: json['start_date'] ?? '',
      targetEndDate: json['target_end_date'] ?? '',
      progressPercent: json['progress_percent'] ?? 0,
      siteAddress: json['site_address'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class SiteModel {
  final String id;
  final String projectId;
  final String name;
  final String location;
  final String? engineerId;
  final String status;
  final String? lastInspectionDate;
  final String notes;

  SiteModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.location,
    this.engineerId,
    required this.status,
    this.lastInspectionDate,
    required this.notes,
  });

  factory SiteModel.fromJson(Map<String, dynamic> json) {
    return SiteModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      engineerId: json['engineer_id'],
      status: json['status'] ?? 'Active',
      lastInspectionDate: json['last_inspection_date'],
      notes: json['notes'] ?? '',
    );
  }
}
