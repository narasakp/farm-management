class ResearchProject {
  final String id;
  final String title;
  final String description;
  final String researcherName;
  final String researcherEmail;
  final String researcherPhone;
  final ResearchStatus status;
  final ResearchType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String? location;
  final List<String> objectives;
  final List<String> methods;
  final String? findings;
  final String? conclusion;
  final List<String> attachments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ResearchProject({
    required this.id,
    required this.title,
    required this.description,
    required this.researcherName,
    required this.researcherEmail,
    required this.researcherPhone,
    required this.status,
    required this.type,
    required this.startDate,
    this.endDate,
    this.location,
    required this.objectives,
    required this.methods,
    this.findings,
    this.conclusion,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
  });

  ResearchProject copyWith({
    String? id,
    String? title,
    String? description,
    String? researcherName,
    String? researcherEmail,
    String? researcherPhone,
    ResearchStatus? status,
    ResearchType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? location,
    List<String>? objectives,
    List<String>? methods,
    String? findings,
    String? conclusion,
    List<String>? attachments,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResearchProject(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      researcherName: researcherName ?? this.researcherName,
      researcherEmail: researcherEmail ?? this.researcherEmail,
      researcherPhone: researcherPhone ?? this.researcherPhone,
      status: status ?? this.status,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      location: location ?? this.location,
      objectives: objectives ?? this.objectives,
      methods: methods ?? this.methods,
      findings: findings ?? this.findings,
      conclusion: conclusion ?? this.conclusion,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'researcherName': researcherName,
      'researcherEmail': researcherEmail,
      'researcherPhone': researcherPhone,
      'status': status.toString(),
      'type': type.toString(),
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'location': location,
      'objectives': objectives,
      'methods': methods,
      'findings': findings,
      'conclusion': conclusion,
      'attachments': attachments,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ResearchProject.fromJson(Map<String, dynamic> json) {
    return ResearchProject(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      researcherName: json['researcherName'],
      researcherEmail: json['researcherEmail'],
      researcherPhone: json['researcherPhone'],
      status: ResearchStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
      type: ResearchType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      location: json['location'],
      objectives: List<String>.from(json['objectives']),
      methods: List<String>.from(json['methods']),
      findings: json['findings'],
      conclusion: json['conclusion'],
      attachments: List<String>.from(json['attachments']),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

enum ResearchStatus {
  planning,     // วางแผน
  ongoing,      // ดำเนินการ
  dataCollection, // เก็บข้อมูล
  analysis,     // วิเคราะห์
  completed,    // เสร็จสิ้น
  published,    // เผยแพร่
  cancelled,    // ยกเลิก
}

enum ResearchType {
  livestockHealth,    // สุขภาพปศุสัตว์
  breeding,          // การผสมพันธุ์
  nutrition,         // โภชนาการ
  production,        // การผลิต
  economics,         // เศรษฐศาสตร์
  environment,       // สิ่งแวดล้อม
  technology,        // เทคโนโลยี
  socialStudy,       // สังคมศาสตร์
  other,            // อื่นๆ
}

extension ResearchStatusExtension on ResearchStatus {
  String get displayName {
    switch (this) {
      case ResearchStatus.planning:
        return 'วางแผน';
      case ResearchStatus.ongoing:
        return 'ดำเนินการ';
      case ResearchStatus.dataCollection:
        return 'เก็บข้อมูล';
      case ResearchStatus.analysis:
        return 'วิเคราะห์';
      case ResearchStatus.completed:
        return 'เสร็จสิ้น';
      case ResearchStatus.published:
        return 'เผยแพร่';
      case ResearchStatus.cancelled:
        return 'ยกเลิก';
    }
  }
}

extension ResearchTypeExtension on ResearchType {
  String get displayName {
    switch (this) {
      case ResearchType.livestockHealth:
        return 'สุขภาพปศุสัตว์';
      case ResearchType.breeding:
        return 'การผสมพันธุ์';
      case ResearchType.nutrition:
        return 'โภชนาการ';
      case ResearchType.production:
        return 'การผลิต';
      case ResearchType.economics:
        return 'เศรษฐศาสตร์';
      case ResearchType.environment:
        return 'สิ่งแวดล้อม';
      case ResearchType.technology:
        return 'เทคโนโลยี';
      case ResearchType.socialStudy:
        return 'สังคมศาสตร์';
      case ResearchType.other:
        return 'อื่นๆ';
    }
  }
}
