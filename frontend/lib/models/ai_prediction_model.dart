class CriticalPathTask {
  final String taskId;
  final String title;
  final String priority;
  final String status;
  final int completionPercent;
  final double plannedDays;
  final double predictedTotalDays;
  final double varianceDays;
  final double delayProbability;
  final String riskLevel;

  CriticalPathTask({
    required this.taskId,
    required this.title,
    required this.priority,
    required this.status,
    required this.completionPercent,
    required this.plannedDays,
    required this.predictedTotalDays,
    required this.varianceDays,
    required this.delayProbability,
    required this.riskLevel,
  });

  factory CriticalPathTask.fromJson(Map<String, dynamic> json) {
    return CriticalPathTask(
      taskId: json['task_id'] ?? '',
      title: json['title'] ?? '',
      priority: json['priority'] ?? 'Medium',
      status: json['status'] ?? 'To Do',
      completionPercent: json['completion_percent'] ?? 0,
      plannedDays: (json['planned_days'] as num?)?.toDouble() ?? 5.0,
      predictedTotalDays: (json['predicted_total_days'] as num?)?.toDouble() ?? 5.0,
      varianceDays: (json['variance_days'] as num?)?.toDouble() ?? 0.0,
      delayProbability: (json['delay_probability'] as num?)?.toDouble() ?? 0.0,
      riskLevel: json['risk_level'] ?? 'On Schedule',
    );
  }
}

class AIRecommendation {
  final String type;
  final String severity;
  final String title;
  final String action;

  AIRecommendation({
    required this.type,
    required this.severity,
    required this.title,
    required this.action,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      type: json['type'] ?? 'GENERAL',
      severity: json['severity'] ?? 'Medium',
      title: json['title'] ?? '',
      action: json['action'] ?? '',
    );
  }
}

class AIPredictionResult {
  final String projectId;
  final String projectTitle;
  final String clientName;
  final int healthScore;
  final double overallDelayProbability;
  final double daysVariance;
  final String targetEndDate;
  final String predictedCompletionDate;
  final int highRiskTaskCount;
  final int totalTasksTracked;
  final List<CriticalPathTask> criticalPathTasks;
  final List<AIRecommendation> recommendations;

  AIPredictionResult({
    required this.projectId,
    required this.projectTitle,
    required this.clientName,
    required this.healthScore,
    required this.overallDelayProbability,
    required this.daysVariance,
    required this.targetEndDate,
    required this.predictedCompletionDate,
    required this.highRiskTaskCount,
    required this.totalTasksTracked,
    required this.criticalPathTasks,
    required this.recommendations,
  });

  factory AIPredictionResult.fromJson(Map<String, dynamic> json) {
    var rawCritical = json['critical_path_tasks'] as List? ?? [];
    var rawRecs = json['recommendations'] as List? ?? [];

    return AIPredictionResult(
      projectId: json['project_id'] ?? '',
      projectTitle: json['project_title'] ?? 'Project',
      clientName: json['client_name'] ?? 'Client',
      healthScore: json['health_score'] ?? 80,
      overallDelayProbability: (json['overall_delay_probability'] as num?)?.toDouble() ?? 10.0,
      daysVariance: (json['days_variance'] as num?)?.toDouble() ?? 0.0,
      targetEndDate: json['target_end_date'] ?? '',
      predictedCompletionDate: json['predicted_completion_date'] ?? '',
      highRiskTaskCount: json['high_risk_task_count'] ?? 0,
      totalTasksTracked: json['total_tasks_tracked'] ?? 0,
      criticalPathTasks: rawCritical.map((c) => CriticalPathTask.fromJson(c)).toList(),
      recommendations: rawRecs.map((r) => AIRecommendation.fromJson(r)).toList(),
    );
  }
}
