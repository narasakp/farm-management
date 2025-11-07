/// รายการสัตว์ที่จะนำไปขายในตลาด
class BookingItem {
  final String livestockId;       // ID ของสัตว์จากระบบ
  final String livestockType;     // 'โค', 'กระบือ', 'สุกร', etc.
  final String earTag;            // หมายเลขติดหู เช่น 'C001'
  final int quantity;             // จำนวน (ปกติจะเป็น 1)
  final double? weight;           // น้ำหนัก (กิโลกรัม)
  final double? estimatedPrice;   // ราคาประเมิน (optional)

  BookingItem({
    required this.livestockId,
    required this.livestockType,
    required this.earTag,
    this.quantity = 1,
    this.weight,
    this.estimatedPrice,
  });

  // From JSON
  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      livestockId: json['livestockId'] as String,
      livestockType: json['livestockType'] as String,
      earTag: json['earTag'] as String,
      quantity: json['quantity'] as int? ?? 1,
      weight: (json['weight'] as num?)?.toDouble(),
      estimatedPrice: (json['estimatedPrice'] as num?)?.toDouble(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'livestockId': livestockId,
      'livestockType': livestockType,
      'earTag': earTag,
      'quantity': quantity,
      'weight': weight,
      'estimatedPrice': estimatedPrice,
    };
  }

  BookingItem copyWith({
    String? livestockId,
    String? livestockType,
    String? earTag,
    int? quantity,
    double? weight,
    double? estimatedPrice,
  }) {
    return BookingItem(
      livestockId: livestockId ?? this.livestockId,
      livestockType: livestockType ?? this.livestockType,
      earTag: earTag ?? this.earTag,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
    );
  }
}
