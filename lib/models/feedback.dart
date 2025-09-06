class Feedback {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String phone;
  final FeedbackType type;
  final FeedbackCategory category;
  final String subject;
  final String message;
  final int rating; // 1-5 stars
  final List<String> attachments; // URLs or file paths
  final FeedbackStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final DateTime? respondedAt;

  Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.phone,
    required this.type,
    required this.category,
    required this.subject,
    required this.message,
    required this.rating,
    this.attachments = const [],
    this.status = FeedbackStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.respondedAt,
  });

  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['id'],
      userId: json['userId'],
      userName: json['userName'],
      email: json['email'],
      phone: json['phone'],
      type: FeedbackType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      category: FeedbackCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
      ),
      subject: json['subject'],
      message: json['message'],
      rating: json['rating'],
      attachments: List<String>.from(json['attachments'] ?? []),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      adminResponse: json['adminResponse'],
      respondedAt: json['respondedAt'] != null ? DateTime.parse(json['respondedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'email': email,
      'phone': phone,
      'type': type.toString().split('.').last,
      'category': category.toString().split('.').last,
      'subject': subject,
      'message': message,
      'rating': rating,
      'attachments': attachments,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  Feedback copyWith({
    String? id,
    String? userId,
    String? userName,
    String? email,
    String? phone,
    FeedbackType? type,
    FeedbackCategory? category,
    String? subject,
    String? message,
    int? rating,
    List<String>? attachments,
    FeedbackStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    DateTime? respondedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      rating: rating ?? this.rating,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  String get statusText {
    switch (status) {
      case FeedbackStatus.pending:
        return 'รอดำเนินการ';
      case FeedbackStatus.inProgress:
        return 'กำลังดำเนินการ';
      case FeedbackStatus.resolved:
        return 'แก้ไขแล้ว';
      case FeedbackStatus.closed:
        return 'ปิดเรื่อง';
    }
  }

  String get typeText {
    switch (type) {
      case FeedbackType.suggestion:
        return 'ข้อเสนอแนะ';
      case FeedbackType.bug:
        return 'แจ้งปัญหา';
      case FeedbackType.feature:
        return 'ขอฟีเจอร์ใหม่';
      case FeedbackType.complaint:
        return 'ร้องเรียน';
      case FeedbackType.compliment:
        return 'ชื่นชม';
    }
  }

  String get categoryText {
    switch (category) {
      case FeedbackCategory.ui:
        return 'หน้าจอ/การใช้งาน';
      case FeedbackCategory.performance:
        return 'ประสิทธิภาพ';
      case FeedbackCategory.data:
        return 'ข้อมูล';
      case FeedbackCategory.export:
        return 'การส่งออกข้อมูล';
      case FeedbackCategory.livestock:
        return 'การจัดการปศุสัตว์';
      case FeedbackCategory.survey:
        return 'การสำรวจ';
      case FeedbackCategory.trading:
        return 'การซื้อขาย';
      case FeedbackCategory.transport:
        return 'การขนส่ง';
      case FeedbackCategory.other:
        return 'อื่นๆ';
    }
  }
}

enum FeedbackType {
  suggestion, // ข้อเสนอแนะ
  bug,        // แจ้งปัญหา
  feature,    // ขอฟีเจอร์ใหม่
  complaint,  // ร้องเรียน
  compliment, // ชื่นชม
}

enum FeedbackCategory {
  ui,         // หน้าจอ/การใช้งาน
  performance, // ประสิทธิภาพ
  data,       // ข้อมูล
  export,     // การส่งออกข้อมูล
  livestock,  // การจัดการปศุสัตว์
  survey,     // การสำรวจ
  trading,    // การซื้อขาย
  transport,  // การขนส่ง
  other,      // อื่นๆ
}

enum FeedbackStatus {
  pending,    // รอดำเนินการ
  inProgress, // กำลังดำเนินการ
  resolved,   // แก้ไขแล้ว
  closed,     // ปิดเรื่อง
}
