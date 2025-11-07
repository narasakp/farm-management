import 'dart:convert';

class Feedback {
  final String id;
  final String userId;
  final String userName;
  final String? email;  // nullable สำหรับ user ที่ login แล้ว
  final String? phone;  // nullable สำหรับ user ที่ login แล้ว
  final FeedbackType type;
  final FeedbackCategory category;
  final String subject;
  final String message;
  final int rating; // 1-5 stars
  final List<String> attachments; // URLs or file paths
  final FeedbackPriority priority;
  final FeedbackStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? adminResponse;
  final String? respondedByUserName;
  final DateTime? respondedAt;
  final int votes;
  final int views;
  final DateTime? lastActivity;
  final int replyCount;
  final DateTime? editedAt;
  final String? editedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  Feedback({
    required this.id,
    required this.userId,
    required this.userName,
    this.email,  // ไม่บังคับสำหรับ user ที่ login แล้ว
    this.phone,  // ไม่บังคับสำหรับ user ที่ login แล้ว
    required this.type,
    required this.category,
    required this.subject,
    required this.message,
    required this.rating,
    this.attachments = const [],
    this.priority = FeedbackPriority.medium,
    this.status = FeedbackStatus.pending,
    required this.createdAt,
    this.updatedAt,
    this.adminResponse,
    this.respondedByUserName,
    this.respondedAt,
    this.votes = 0,
    this.views = 0,
    this.lastActivity,
    this.replyCount = 0,
    this.editedAt,
    this.editedBy,
    this.deletedAt,
    this.deletedBy,
  });

  static List<String> _parseAttachments(String jsonString) {
    try {
      print('📎 [Parse] Parsing attachments: $jsonString');
      final parsed = json.decode(jsonString);
      print('📎 [Parse] Parsed type: ${parsed.runtimeType}, value: $parsed');
      if (parsed is List) {
        final result = List<String>.from(parsed);
        print('✅ [Parse] Result: $result');
        return result;
      }
      print('⚠️ [Parse] Not a list, returning empty');
      return [];
    } catch (e) {
      print('❌ [Parse] Error parsing attachments: $e');
      return [];
    }
  }

  factory Feedback.fromJson(Map<String, dynamic> json) {
    // รองรับทั้ง camelCase และ snake_case จาก API
    return Feedback(
      id: json['id'],
      userId: json['userId'] ?? json['user_id'] ?? '',
      userName: json['userName'] ?? json['user_name'] ?? '',
      email: (json['email'] as String?) ?? '',
      phone: (json['phone'] as String?) ?? '',
      type: FeedbackType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => FeedbackType.suggestion,
      ),
      category: FeedbackCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => FeedbackCategory.other,
      ),
      subject: json['subject'] ?? '',
      message: json['message'] ?? '',
      rating: json['rating'] ?? 0,
      attachments: (() {
        final att = json['attachments'];
        print('📎 [fromJson] attachments field: $att, type: ${att?.runtimeType}');
        if (att == null) {
          print('⚠️ [fromJson] attachments is null');
          return <String>[];
        }
        if (att is String) {
          print('📝 [fromJson] attachments is String, parsing...');
          return _parseAttachments(att);
        }
        print('📋 [fromJson] attachments is List');
        return List<String>.from(att);
      })(),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.toString().split('.').last == json['priority'],
        orElse: () => FeedbackPriority.medium,
      ),
      status: FeedbackStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => FeedbackStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null 
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at']) 
          : null,
      adminResponse: json['adminResponse'] ?? json['admin_response'],
      respondedByUserName: json['respondedByUserName'] ?? json['responded_by_user_name'],
      respondedAt: (json['respondedAt'] ?? json['responded_at']) != null 
          ? DateTime.parse(json['respondedAt'] ?? json['responded_at']) 
          : null,
      votes: json['votes'] ?? 0,
      views: json['views'] ?? 0,
      lastActivity: (json['lastActivity'] ?? json['last_activity']) != null 
          ? DateTime.parse(json['lastActivity'] ?? json['last_activity']) 
          : null,
      replyCount: json['replyCount'] ?? json['reply_count'] ?? 0,
      editedAt: (json['editedAt'] ?? json['edited_at']) != null
          ? DateTime.parse(json['editedAt'] ?? json['edited_at'])
          : null,
      editedBy: json['editedBy'] ?? json['edited_by'],
      deletedAt: (json['deletedAt'] ?? json['deleted_at']) != null
          ? DateTime.parse(json['deletedAt'] ?? json['deleted_at'])
          : null,
      deletedBy: json['deletedBy'] ?? json['deleted_by'],
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
      'priority': priority.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'adminResponse': adminResponse,
      'respondedByUserName': respondedByUserName,
      'respondedAt': respondedAt?.toIso8601String(),
      'votes': votes,
      'views': views,
      'lastActivity': lastActivity?.toIso8601String(),
      'replyCount': replyCount,
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
    FeedbackPriority? priority,
    FeedbackStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? adminResponse,
    String? respondedByUserName,
    DateTime? respondedAt,
    int? votes,
    int? views,
    DateTime? lastActivity,
    int? replyCount,
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
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      adminResponse: adminResponse ?? this.adminResponse,
      respondedByUserName: respondedByUserName ?? this.respondedByUserName,
      respondedAt: respondedAt ?? this.respondedAt,
      votes: votes ?? this.votes,
      views: views ?? this.views,
      lastActivity: lastActivity ?? this.lastActivity,
      replyCount: replyCount ?? this.replyCount,
    );
  }

  String get statusText {
    switch (status) {
      case FeedbackStatus.pending:
        return 'รออนุมัติ';
      case FeedbackStatus.approved:
        return 'อนุมัติแล้ว';
      case FeedbackStatus.rejected:
        return 'ปฏิเสธ';
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

enum FeedbackPriority {
  low,    // ต่ำ
  medium, // ปานกลาง
  high,   // สูง
  urgent, // เร่งด่วน
}

enum FeedbackStatus {
  pending,    // รออนุมัติ
  approved,   // อนุมัติแล้ว
  rejected,   // ปฏิเสธ
  inProgress, // กำลังดำเนินการ
  resolved,   // แก้ไขแล้ว
  closed,     // ปิดเรื่อง
}
