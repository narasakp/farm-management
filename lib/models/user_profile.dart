// User Profile & Reputation Model
class UserProfile {
  final String id;
  final String fullName;
  final String? email;
  final String? avatarUrl;
  final DateTime createdAt;
  
  // Reputation stats
  final int reputationPoints;
  final String reputationLevel;
  final int threadsCreated;
  final int repliesPosted;
  final int answersAccepted;
  final int bestAnswers;
  final int votesReceived;
  final int upvotesReceived;
  final int downvotesReceived;
  
  // Level info
  final String levelName;
  final String levelIcon;
  final int levelMin;
  final int levelMax;
  
  // Badges
  final List<UserBadge> badges;

  UserProfile({
    required this.id,
    required this.fullName,
    this.email,
    this.avatarUrl,
    required this.createdAt,
    this.reputationPoints = 0,
    this.reputationLevel = 'beginner',
    this.threadsCreated = 0,
    this.repliesPosted = 0,
    this.answersAccepted = 0,
    this.bestAnswers = 0,
    this.votesReceived = 0,
    this.upvotesReceived = 0,
    this.downvotesReceived = 0,
    this.levelName = 'มือใหม่',
    this.levelIcon = '🌱',
    this.levelMin = 0,
    this.levelMax = 99,
    this.badges = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final levelInfo = json['levelInfo'] ?? {};
    final badgesJson = json['badges'] as List<dynamic>? ?? [];
    
    return UserProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar_url'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      reputationPoints: json['reputation_points'] ?? 0,
      reputationLevel: json['reputation_level'] ?? 'beginner',
      threadsCreated: json['threads_created'] ?? 0,
      repliesPosted: json['replies_posted'] ?? 0,
      answersAccepted: json['answers_accepted'] ?? 0,
      bestAnswers: json['best_answers'] ?? 0,
      votesReceived: json['votes_received'] ?? 0,
      upvotesReceived: json['upvotes_received'] ?? 0,
      downvotesReceived: json['downvotes_received'] ?? 0,
      levelName: levelInfo['name'] ?? 'มือใหม่',
      levelIcon: levelInfo['icon'] ?? '🌱',
      levelMin: levelInfo['min'] ?? 0,
      levelMax: levelInfo['max'] ?? 99,
      badges: badgesJson.map((b) => UserBadge.fromJson(b)).toList(),
    );
  }

  // Calculate progress to next level
  double get levelProgress {
    if (levelMax == double.infinity) return 1.0;
    final range = levelMax - levelMin;
    final current = reputationPoints - levelMin;
    return (current / range).clamp(0.0, 1.0);
  }

  // Get next level points needed
  int get pointsToNextLevel {
    if (levelMax == double.infinity) return 0;
    return levelMax - reputationPoints + 1;
  }
}

class UserBadge {
  final String id;
  final String userId;
  final String badgeType;
  final String badgeName;
  final String? badgeDescription;
  final DateTime earnedAt;

  UserBadge({
    required this.id,
    required this.userId,
    required this.badgeType,
    required this.badgeName,
    this.badgeDescription,
    required this.earnedAt,
  });

  factory UserBadge.fromJson(Map<String, dynamic> json) {
    return UserBadge(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      badgeType: json['badge_type'] ?? '',
      badgeName: json['badge_name'] ?? '',
      badgeDescription: json['badge_description'],
      earnedAt: json['earned_at'] != null 
          ? DateTime.parse(json['earned_at']) 
          : DateTime.now(),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final UserProfile profile;

  LeaderboardEntry({
    required this.rank,
    required this.profile,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] ?? 0,
      profile: UserProfile.fromJson(json),
    );
  }
}
