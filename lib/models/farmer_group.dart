// ระบบการจัดการกลุ่มชุมชนเกษตรกร
class FarmerGroup {
  final String id;
  final String name;
  final String description;
  final String leaderFarmerId;
  final String registrationNumber;
  final DateTime establishedDate;
  final String tambon;
  final String amphoe;
  final String province;
  final int memberCount;
  final double totalFundAmount;
  final bool isActive;
  final String? notes;
  final DateTime createdAt;

  FarmerGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderFarmerId,
    required this.registrationNumber,
    required this.establishedDate,
    required this.tambon,
    required this.amphoe,
    required this.province,
    required this.memberCount,
    required this.totalFundAmount,
    required this.isActive,
    this.notes,
    required this.createdAt,
  });

  factory FarmerGroup.fromJson(Map<String, dynamic> json) {
    return FarmerGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderFarmerId: json['leaderFarmerId'],
      registrationNumber: json['registrationNumber'],
      establishedDate: DateTime.parse(json['establishedDate']),
      tambon: json['tambon'],
      amphoe: json['amphoe'],
      province: json['province'],
      memberCount: json['memberCount'],
      totalFundAmount: json['totalFundAmount'].toDouble(),
      isActive: json['isActive'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderFarmerId': leaderFarmerId,
      'registrationNumber': registrationNumber,
      'establishedDate': establishedDate.toIso8601String(),
      'tambon': tambon,
      'amphoe': amphoe,
      'province': province,
      'memberCount': memberCount,
      'totalFundAmount': totalFundAmount,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class GroupMember {
  final String id;
  final String groupId;
  final String farmerId;
  final DateTime joinDate;
  final String membershipType; // 'regular', 'committee', 'leader'
  final double contributionAmount;
  final bool isActive;
  final String? role;
  final String? notes;
  final DateTime createdAt;

  GroupMember({
    required this.id,
    required this.groupId,
    required this.farmerId,
    required this.joinDate,
    required this.membershipType,
    required this.contributionAmount,
    required this.isActive,
    this.role,
    this.notes,
    required this.createdAt,
  });

  factory GroupMember.fromJson(Map<String, dynamic> json) {
    return GroupMember(
      id: json['id'],
      groupId: json['groupId'],
      farmerId: json['farmerId'],
      joinDate: DateTime.parse(json['joinDate']),
      membershipType: json['membershipType'],
      contributionAmount: json['contributionAmount'].toDouble(),
      isActive: json['isActive'],
      role: json['role'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'farmerId': farmerId,
      'joinDate': joinDate.toIso8601String(),
      'membershipType': membershipType,
      'contributionAmount': contributionAmount,
      'isActive': isActive,
      'role': role,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class GroupActivity {
  final String id;
  final String groupId;
  final String title;
  final String description;
  final String activityType; // 'meeting', 'training', 'event', 'project'
  final DateTime scheduledDate;
  final String? location;
  final List<String> participantIds;
  final double? budget;
  final String status; // 'planned', 'ongoing', 'completed', 'cancelled'
  final String? outcomes;
  final DateTime createdAt;

  GroupActivity({
    required this.id,
    required this.groupId,
    required this.title,
    required this.description,
    required this.activityType,
    required this.scheduledDate,
    this.location,
    required this.participantIds,
    this.budget,
    required this.status,
    this.outcomes,
    required this.createdAt,
  });

  factory GroupActivity.fromJson(Map<String, dynamic> json) {
    return GroupActivity(
      id: json['id'],
      groupId: json['groupId'],
      title: json['title'],
      description: json['description'],
      activityType: json['activityType'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      location: json['location'],
      participantIds: List<String>.from(json['participantIds']),
      budget: json['budget']?.toDouble(),
      status: json['status'],
      outcomes: json['outcomes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'title': title,
      'description': description,
      'activityType': activityType,
      'scheduledDate': scheduledDate.toIso8601String(),
      'location': location,
      'participantIds': participantIds,
      'budget': budget,
      'status': status,
      'outcomes': outcomes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class GroupFund {
  final String id;
  final String groupId;
  final String fundName;
  final String fundType; // 'savings', 'loan', 'emergency', 'investment'
  final double totalAmount;
  final double availableAmount;
  final double interestRate;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  GroupFund({
    required this.id,
    required this.groupId,
    required this.fundName,
    required this.fundType,
    required this.totalAmount,
    required this.availableAmount,
    required this.interestRate,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory GroupFund.fromJson(Map<String, dynamic> json) {
    return GroupFund(
      id: json['id'],
      groupId: json['groupId'],
      fundName: json['fundName'],
      fundType: json['fundType'],
      totalAmount: json['totalAmount'].toDouble(),
      availableAmount: json['availableAmount'].toDouble(),
      interestRate: json['interestRate'].toDouble(),
      description: json['description'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'fundName': fundName,
      'fundType': fundType,
      'totalAmount': totalAmount,
      'availableAmount': availableAmount,
      'interestRate': interestRate,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class SavingsRecord {
  final String id;
  final String groupId;
  final String memberId;
  final String fundId;
  final double amount;
  final String transactionType; // 'deposit', 'withdrawal'
  final DateTime transactionDate;
  final String? notes;
  final String? approvedBy;
  final DateTime createdAt;

  SavingsRecord({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.fundId,
    required this.amount,
    required this.transactionType,
    required this.transactionDate,
    this.notes,
    this.approvedBy,
    required this.createdAt,
  });

  factory SavingsRecord.fromJson(Map<String, dynamic> json) {
    return SavingsRecord(
      id: json['id'],
      groupId: json['groupId'],
      memberId: json['memberId'],
      fundId: json['fundId'],
      amount: json['amount'].toDouble(),
      transactionType: json['transactionType'],
      transactionDate: DateTime.parse(json['transactionDate']),
      notes: json['notes'],
      approvedBy: json['approvedBy'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'memberId': memberId,
      'fundId': fundId,
      'amount': amount,
      'transactionType': transactionType,
      'transactionDate': transactionDate.toIso8601String(),
      'notes': notes,
      'approvedBy': approvedBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class DividendRecord {
  final String id;
  final String groupId;
  final String memberId;
  final double amount;
  final String dividendPeriod; // 'Q1-2024', 'Annual-2024'
  final DateTime distributionDate;
  final double profitShare;
  final String calculationMethod;
  final String? notes;
  final DateTime createdAt;

  DividendRecord({
    required this.id,
    required this.groupId,
    required this.memberId,
    required this.amount,
    required this.dividendPeriod,
    required this.distributionDate,
    required this.profitShare,
    required this.calculationMethod,
    this.notes,
    required this.createdAt,
  });

  factory DividendRecord.fromJson(Map<String, dynamic> json) {
    return DividendRecord(
      id: json['id'],
      groupId: json['groupId'],
      memberId: json['memberId'],
      amount: json['amount'].toDouble(),
      dividendPeriod: json['dividendPeriod'],
      distributionDate: DateTime.parse(json['distributionDate']),
      profitShare: json['profitShare'].toDouble(),
      calculationMethod: json['calculationMethod'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'memberId': memberId,
      'amount': amount,
      'dividendPeriod': dividendPeriod,
      'distributionDate': distributionDate.toIso8601String(),
      'profitShare': profitShare,
      'calculationMethod': calculationMethod,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
