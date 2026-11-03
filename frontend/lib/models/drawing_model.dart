class DrawingModel {
  final String id;
  final String projectId;
  final String title;
  final String revision;
  final String sheetNumber;
  final String fileUrl;
  final String fileType;
  final String? uploadedBy;
  final String createdAt;

  DrawingModel({
    required this.id,
    required this.projectId,
    required this.title,
    required this.revision,
    required this.sheetNumber,
    required this.fileUrl,
    required this.fileType,
    this.uploadedBy,
    required this.createdAt,
  });

  factory DrawingModel.fromJson(Map<String, dynamic> json) {
    return DrawingModel(
      id: json['id'] ?? '',
      projectId: json['project_id'] ?? '',
      title: json['title'] ?? '',
      revision: json['revision'] ?? 'Rev A',
      sheetNumber: json['sheet_number'] ?? 'A-101',
      fileUrl: json['file_url'] ?? '',
      fileType: json['file_type'] ?? 'application/pdf',
      uploadedBy: json['uploaded_by'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class StrokePoint {
  final double x;
  final double y;

  StrokePoint({required this.x, required this.y});

  factory StrokePoint.fromJson(Map<String, dynamic> json) {
    return StrokePoint(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
}

class DrawingStroke {
  final String tool; // 'pen', 'cloud', 'arrow', 'highlighter', 'rect'
  final String colorHex;
  final double strokeWidth;
  final List<StrokePoint> points;

  DrawingStroke({
    required this.tool,
    required this.colorHex,
    required this.strokeWidth,
    required this.points,
  });

  factory DrawingStroke.fromJson(Map<String, dynamic> json) {
    var rawPts = json['points'] as List? ?? [];
    return DrawingStroke(
      tool: json['tool'] ?? 'pen',
      colorHex: json['color'] ?? json['colorHex'] ?? '#D4AF37',
      strokeWidth: (json['stroke_width'] as num?)?.toDouble() ?? 3.0,
      points: rawPts.map((p) => StrokePoint.fromJson(p)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'tool': tool,
    'color': colorHex,
    'stroke_width': strokeWidth,
    'points': points.map((p) => p.toJson()).toList(),
  };
}

class AnnotationNote {
  final String id;
  final double x;
  final double y;
  final String text;
  final String colorHex;

  AnnotationNote({
    required this.id,
    required this.x,
    required this.y,
    required this.text,
    required this.colorHex,
  });

  factory AnnotationNote.fromJson(Map<String, dynamic> json) {
    return AnnotationNote(
      id: json['id'] ?? '',
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      text: json['text'] ?? '',
      colorHex: json['color'] ?? '#E53E3E',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'x': x,
    'y': y,
    'text': text,
    'color': colorHex,
  };
}

class DrawingMarkupModel {
  final String id;
  final String drawingId;
  final String authorName;
  final String authorRole;
  final List<DrawingStroke> strokes;
  final List<AnnotationNote> annotations;
  final String comment;
  final String createdAt;

  DrawingMarkupModel({
    required this.id,
    required this.drawingId,
    required this.authorName,
    required this.authorRole,
    required this.strokes,
    required this.annotations,
    required this.comment,
    required this.createdAt,
  });

  factory DrawingMarkupModel.fromJson(Map<String, dynamic> json) {
    var layer = json['layer_data'] as Map<String, dynamic>? ?? {};
    var rawStrokes = layer['strokes'] as List? ?? [];
    var rawNotes = layer['annotations'] as List? ?? [];

    return DrawingMarkupModel(
      id: json['id'] ?? '',
      drawingId: json['drawing_id'] ?? '',
      authorName: json['author_name'] ?? 'Engineer',
      authorRole: json['author_role'] ?? 'engineer',
      strokes: rawStrokes.map((s) => DrawingStroke.fromJson(s)).toList(),
      annotations: rawNotes.map((n) => AnnotationNote.fromJson(n)).toList(),
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
