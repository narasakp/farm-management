class FeedbackReply {
  final String id;
  final String feedbackId;
  final String? parentReplyId;  // null = level 1, มีค่า = level 2
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;
  final int votes;
  final bool isBestAnswer;
  final DateTime? editedAt;
  final String? editedBy;
  final DateTime? deletedAt;
  final String? deletedBy;

  FeedbackReply({
    required this.id,
    required this.feedbackId,
    this.parentReplyId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
    this.votes = 0,
    this.isBestAnswer = false,
    this.editedAt,
    this.editedBy,
    this.deletedAt,
    this.deletedBy,
  });

  // Check if this is a nested reply (level 2)
  bool get isNested => parentReplyId != null;

  factory FeedbackReply.fromJson(Map<String, dynamic> json) {
    return FeedbackReply(
      id: json['id'],
      feedbackId: json['feedbackId'] ?? json['feedback_id'],
      parentReplyId: json['parentReplyId'] ?? json['parent_reply_id'],
      userId: json['userId'] ?? json['user_id'],
      userName: json['userName'] ?? json['user_name'],
      message: json['message'],
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      votes: json['votes'] ?? 0,
      isBestAnswer: json['isBestAnswer'] == 1 || json['isBestAnswer'] == true || json['is_best_answer'] == 1 || json['is_best_answer'] == true,
      editedAt: json['editedAt'] != null || json['edited_at'] != null
          ? DateTime.parse(json['editedAt'] ?? json['edited_at'])
          : null,
      editedBy: json['editedBy'] ?? json['edited_by'],
      deletedAt: json['deletedAt'] != null || json['deleted_at'] != null
          ? DateTime.parse(json['deletedAt'] ?? json['deleted_at'])
          : null,
      deletedBy: json['deletedBy'] ?? json['deleted_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'feedbackId': feedbackId,
      'parentReplyId': parentReplyId,
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'votes': votes,
      'isBestAnswer': isBestAnswer,
      'editedAt': editedAt?.toIso8601String(),
      'editedBy': editedBy,
    };
  }
}
