import 'dart:convert';

class ThreadReply {
  final String id;
  final String threadId;
  final String? parentReplyId;  // null = top-level, มีค่า = nested reply
  final int level;  // 0 = top-level, 1 = nested
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isEdited;
  final int upvoteCount;
  final int downvoteCount;
  final bool isAnswer;  // คำตอบที่ถูกต้อง
  final bool isStaffReply;
  final bool isExpertReply;
  final bool isHidden;
  final String? hiddenReason;
  final List<String> attachments;

  ThreadReply({
    required this.id,
    required this.threadId,
    this.parentReplyId,
    this.level = 0,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.editedAt,
    this.isEdited = false,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    this.isAnswer = false,
    this.isStaffReply = false,
    this.isExpertReply = false,
    this.isHidden = false,
    this.hiddenReason,
    this.attachments = const [],
  });

  bool get isNested => parentReplyId != null;

  static List<String> _parseList(String jsonString) {
    try {
      final parsed = json.decode(jsonString);
      if (parsed is List) {
        return List<String>.from(parsed);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  factory ThreadReply.fromJson(Map<String, dynamic> json) {
    return ThreadReply(
      id: json['id'],
      threadId: json['threadId'] ?? json['thread_id'],
      parentReplyId: json['parentReplyId'] ?? json['parent_reply_id'],
      level: json['level'] ?? 0,
      authorId: json['authorId'] ?? json['author_id'],
      authorName: json['authorName'] ?? json['author_name'],
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      content: json['content'] ?? json['message'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      editedAt: (json['editedAt'] ?? json['edited_at']) != null
          ? DateTime.parse(json['editedAt'] ?? json['edited_at'])
          : null,
      isEdited: json['isEdited'] ?? json['is_edited'] ?? false,
      upvoteCount: json['upvoteCount'] ?? json['upvote_count'] ?? json['votes'] ?? 0,
      downvoteCount: json['downvoteCount'] ?? json['downvote_count'] ?? 0,
      isAnswer: json['isAnswer'] == 1 || json['isAnswer'] == true ||
                json['is_answer'] == 1 || json['is_answer'] == true ||
                json['isBestAnswer'] == 1 || json['isBestAnswer'] == true,
      isStaffReply: json['isStaffReply'] ?? json['is_staff_reply'] ?? false,
      isExpertReply: json['isExpertReply'] ?? json['is_expert_reply'] ?? false,
      isHidden: json['isHidden'] ?? json['is_hidden'] ?? false,
      hiddenReason: json['hiddenReason'] ?? json['hidden_reason'],
      attachments: (() {
        final att = json['attachments'];
        if (att == null) return <String>[];
        if (att is String) return _parseList(att);
        return List<String>.from(att);
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'threadId': threadId,
      'parentReplyId': parentReplyId,
      'level': level,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'editedAt': editedAt?.toIso8601String(),
      'isEdited': isEdited,
      'upvoteCount': upvoteCount,
      'downvoteCount': downvoteCount,
      'isAnswer': isAnswer,
      'isStaffReply': isStaffReply,
      'isExpertReply': isExpertReply,
      'isHidden': isHidden,
      'hiddenReason': hiddenReason,
      'attachments': attachments,
    };
  }

  ThreadReply copyWith({
    String? id,
    String? threadId,
    String? parentReplyId,
    int? level,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? content,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? isEdited,
    int? upvoteCount,
    int? downvoteCount,
    bool? isAnswer,
    bool? isStaffReply,
    bool? isExpertReply,
    bool? isHidden,
    String? hiddenReason,
    List<String>? attachments,
  }) {
    return ThreadReply(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      parentReplyId: parentReplyId ?? this.parentReplyId,
      level: level ?? this.level,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isEdited: isEdited ?? this.isEdited,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      isAnswer: isAnswer ?? this.isAnswer,
      isStaffReply: isStaffReply ?? this.isStaffReply,
      isExpertReply: isExpertReply ?? this.isExpertReply,
      isHidden: isHidden ?? this.isHidden,
      hiddenReason: hiddenReason ?? this.hiddenReason,
      attachments: attachments ?? this.attachments,
    );
  }
}
