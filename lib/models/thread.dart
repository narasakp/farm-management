import 'dart:convert';

class Thread {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String? email;  // สำหรับ guest
  final String? phone;  // สำหรับ guest
  final String title;
  final String content;
  final ThreadCategory category;
  final List<String> tags;
  final ThreadStatus status;
  final int viewCount;
  final int replyCount;
  final int upvoteCount;
  final int downvoteCount;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? lastReplyAt;
  final String? lastReplyBy;
  final bool isPinned;
  final bool isLocked;
  final bool isFeatured;
  final bool hasAcceptedAnswer;
  final String? acceptedAnswerId;
  final bool allowReply;
  final List<String> attachments;
  final bool isEdited;

  Thread({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    this.email,
    this.phone,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.status = ThreadStatus.open,
    this.viewCount = 0,
    this.replyCount = 0,
    this.upvoteCount = 0,
    this.downvoteCount = 0,
    required this.createdAt,
    this.updatedAt,
    this.lastReplyAt,
    this.lastReplyBy,
    this.isPinned = false,
    this.isLocked = false,
    this.isFeatured = false,
    this.hasAcceptedAnswer = false,
    this.acceptedAnswerId,
    this.allowReply = true,
    this.attachments = const [],
    this.isEdited = false,
  });

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

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      final lower = value.toLowerCase();
      return lower == 'true' || lower == '1';
    }
    return false;
  }

  factory Thread.fromJson(Map<String, dynamic> json) {
    return Thread(
      id: json['id'],
      authorId: json['authorId'] ?? json['author_id'] ?? '',
      authorName: json['authorName'] ?? json['author_name'] ?? '',
      authorAvatar: json['authorAvatar'] ?? json['author_avatar'],
      email: json['email'],
      phone: json['phone'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      category: ThreadCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => ThreadCategory.general,
      ),
      tags: (() {
        final t = json['tags'];
        if (t == null) return <String>[];
        if (t is String) return _parseList(t);
        return List<String>.from(t);
      })(),
      status: ThreadStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ThreadStatus.open,
      ),
      viewCount: json['viewCount'] ?? json['view_count'] ?? 0,
      replyCount: json['replyCount'] ?? json['reply_count'] ?? 0,
      upvoteCount: json['upvoteCount'] ?? json['upvote_count'] ?? 0,
      downvoteCount: json['downvoteCount'] ?? json['downvote_count'] ?? 0,
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at']),
      updatedAt: (json['updatedAt'] ?? json['updated_at']) != null
          ? DateTime.parse(json['updatedAt'] ?? json['updated_at'])
          : null,
      lastReplyAt: (json['lastReplyAt'] ?? json['last_reply_at']) != null
          ? DateTime.parse(json['lastReplyAt'] ?? json['last_reply_at'])
          : null,
      lastReplyBy: json['lastReplyBy'] ?? json['last_reply_by'],
      isPinned: _parseBool(json['isPinned'] ?? json['is_pinned']),
      isLocked: _parseBool(json['isLocked'] ?? json['is_locked']),
      isFeatured: _parseBool(json['isFeatured'] ?? json['is_featured']),
      hasAcceptedAnswer: _parseBool(json['hasAcceptedAnswer'] ?? json['has_accepted_answer']),
      acceptedAnswerId: json['acceptedAnswerId'] ?? json['accepted_answer_id'],
      allowReply: (json['allowReply'] ?? json['allow_reply']) == null 
          ? true 
          : _parseBool(json['allowReply'] ?? json['allow_reply']),
      attachments: (() {
        final att = json['attachments'];
        if (att == null) return <String>[];
        if (att is String) return _parseList(att);
        return List<String>.from(att);
      })(),
      isEdited: _parseBool(json['isEdited'] ?? json['is_edited']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'email': email,
      'phone': phone,
      'title': title,
      'content': content,
      'category': category.toString().split('.').last,
      'tags': tags,
      'status': status.toString().split('.').last,
      'viewCount': viewCount,
      'replyCount': replyCount,
      'upvoteCount': upvoteCount,
      'downvoteCount': downvoteCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastReplyAt': lastReplyAt?.toIso8601String(),
      'lastReplyBy': lastReplyBy,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'isFeatured': isFeatured,
      'hasAcceptedAnswer': hasAcceptedAnswer,
      'acceptedAnswerId': acceptedAnswerId,
      'allowReply': allowReply,
      'attachments': attachments,
    };
  }

  Thread copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? email,
    String? phone,
    String? title,
    String? content,
    ThreadCategory? category,
    List<String>? tags,
    ThreadStatus? status,
    int? viewCount,
    int? replyCount,
    int? upvoteCount,
    int? downvoteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastReplyAt,
    String? lastReplyBy,
    bool? isPinned,
    bool? isLocked,
    bool? isFeatured,
    bool? hasAcceptedAnswer,
    String? acceptedAnswerId,
    bool? allowReply,
    List<String>? attachments,
  }) {
    return Thread(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      replyCount: replyCount ?? this.replyCount,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastReplyAt: lastReplyAt ?? this.lastReplyAt,
      lastReplyBy: lastReplyBy ?? this.lastReplyBy,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      isFeatured: isFeatured ?? this.isFeatured,
      hasAcceptedAnswer: hasAcceptedAnswer ?? this.hasAcceptedAnswer,
      acceptedAnswerId: acceptedAnswerId ?? this.acceptedAnswerId,
      allowReply: allowReply ?? this.allowReply,
      attachments: attachments ?? this.attachments,
    );
  }

  String get statusText {
    switch (status) {
      case ThreadStatus.open:
        return 'เปิด';
      case ThreadStatus.answered:
        return 'มีคำตอบแล้ว';
      case ThreadStatus.solved:
        return 'แก้ไขแล้ว';
      case ThreadStatus.closed:
        return 'ปิด';
    }
  }

  String get categoryText {
    switch (category) {
      case ThreadCategory.cattle:
        return 'โคเนื้อ';
      case ThreadCategory.buffalo:
        return 'กระบือ';
      case ThreadCategory.pig:
        return 'สุกร';
      case ThreadCategory.chicken:
        return 'ไก่';
      case ThreadCategory.duck:
        return 'เป็ด';
      case ThreadCategory.goat:
        return 'แพะ';
      case ThreadCategory.sheep:
        return 'แกะ';
      case ThreadCategory.feed:
        return 'อาหารสัตว์';
      case ThreadCategory.health:
        return 'สุขภาพสัตว์';
      case ThreadCategory.breeding:
        return 'การผสมพันธุ์';
      case ThreadCategory.disease:
        return 'โรคระบาด';
      case ThreadCategory.marketing:
        return 'การตลาด';
      case ThreadCategory.finance:
        return 'การเงิน';
      case ThreadCategory.technology:
        return 'เทคโนโลยี';
      case ThreadCategory.general:
        return 'ทั่วไป';
    }
  }
}

enum ThreadCategory {
  cattle,       // โคเนื้อ
  buffalo,      // กระบือ
  pig,          // สุกร
  chicken,      // ไก่
  duck,         // เป็ด
  goat,         // แพะ
  sheep,        // แกะ
  feed,         // อาหารสัตว์
  health,       // สุขภาพสัตว์
  breeding,     // การผสมพันธุ์
  disease,      // โรคระบาด
  marketing,    // การตลาด
  finance,      // การเงิน
  technology,   // เทคโนโลยี
  general,      // ทั่วไป
}

enum ThreadStatus {
  open,      // เปิด (รอคำตอบ)
  answered,  // มีคำตอบแล้ว
  solved,    // แก้ปัญหาได้แล้ว
  closed,    // ปิด
}
