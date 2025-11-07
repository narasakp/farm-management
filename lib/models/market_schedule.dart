/// ตารางเปิด-ปิดของตลาดนัดในแต่ละวัน
class MarketSchedule {
  final bool isOpen;
  final String openTime;        // '06:00'
  final String closeTime;       // '12:00'
  final List<String> timeSlots; // ['06:00-08:00', '08:00-10:00', '10:00-12:00']

  MarketSchedule({
    required this.isOpen,
    required this.openTime,
    required this.closeTime,
    required this.timeSlots,
  });

  // From JSON
  factory MarketSchedule.fromJson(Map<String, dynamic> json) {
    return MarketSchedule(
      isOpen: json['isOpen'] as bool? ?? false,
      openTime: json['openTime'] as String? ?? '',
      closeTime: json['closeTime'] as String? ?? '',
      timeSlots: (json['timeSlots'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'isOpen': isOpen,
      'openTime': openTime,
      'closeTime': closeTime,
      'timeSlots': timeSlots,
    };
  }

  MarketSchedule copyWith({
    bool? isOpen,
    String? openTime,
    String? closeTime,
    List<String>? timeSlots,
  }) {
    return MarketSchedule(
      isOpen: isOpen ?? this.isOpen,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      timeSlots: timeSlots ?? this.timeSlots,
    );
  }
}
