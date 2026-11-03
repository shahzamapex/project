class TaskModel {
  final String id;
  final String projectId;
  final String? siteId;
  final String title;
  final String description;
  final String? assignedTo;
  final String priority; // Low, Medium, High, Critical
  String status; // To Do, In Progress, Completed
  final int plannedDays;
  int actualDays;
  final String dueDate;
  int completionPercent;
  final String? sourceDocument;
  final double? confidenceScore;

  TaskModel({
    required this.id,
    required this.projectId,
    this.siteId,
    required this.title,
    required this.description,
    this.assignedTo,
    required this.priority,
    required this.status,
    required this.plannedDays,
    required this.actualDays,
    required this.dueDate,
    required this.completionPercent,
    this.sourceDocument,
    this.confidenceScore,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      siteId: json['site_id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      assignedTo: json['assigned_to'],
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'To Do',
      plannedDays: json['planned_days'] ?? 5,
      actualDays: json['actual_days'] ?? 0,
      dueDate: json['due_date'] ?? '',
      completionPercent: json['completion_percent'] ?? 0,
      sourceDocument: json['source_document'],
      confidenceScore: (json['confidence_score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'site_id': siteId,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'priority': priority,
      'status': status,
      'planned_days': plannedDays,
      'actual_days': actualDays,
      'due_date': dueDate,
      'completion_percent': completionPercent,
      'source_document': sourceDocument,
      'confidence_score': confidenceScore,
    };
  }
}
