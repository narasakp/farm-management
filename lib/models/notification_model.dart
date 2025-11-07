/// Notification Model
/// แสดงข้อมูล notification สำหรับแจ้งเตือนผู้ใช้

class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'reply', 'mention', 'status_change', 'upvote', 'comment_reply'
  final String title;
  final String message;
  final String? link;
  final String? relatedFeedbackId;
  final String? relatedReplyId;
  final String? relatedUserId;
  final String? relatedUserName;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    this.relatedFeedbackId,
    this.relatedReplyId,
    this.relatedUserId,
    this.relatedUserName,
    required this.isRead,
    required this.createdAt,
    this.readAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      link: json['link'] as String?,
      relatedFeedbackId: json['related_feedback_id'] as String?,
      relatedReplyId: json['related_reply_id'] as String?,
      relatedUserId: json['related_user_id'] as String?,
      relatedUserName: json['related_user_name'] as String?,
      isRead: (json['is_read'] as int) == 1,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'link': link,
      'related_feedback_id': relatedFeedbackId,
      'related_reply_id': relatedReplyId,
      'related_user_id': relatedUserId,
      'related_user_name': relatedUserName,
      'is_read': isRead ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? link,
    String? relatedFeedbackId,
    String? relatedReplyId,
    String? relatedUserId,
    String? relatedUserName,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      link: link ?? this.link,
      relatedFeedbackId: relatedFeedbackId ?? this.relatedFeedbackId,
      relatedReplyId: relatedReplyId ?? this.relatedReplyId,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      relatedUserName: relatedUserName ?? this.relatedUserName,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
