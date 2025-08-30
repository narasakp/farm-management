class TradingRecord {
  final String id;
  final String type; // 'buy' หรือ 'sell'
  final String itemName;
  final String category;
  final int quantity;
  final double pricePerUnit;
  final double totalAmount;
  final DateTime date;
  final String buyerSeller;
  final String status; // 'completed', 'pending', 'cancelled'
  final String? notes;

  TradingRecord({
    required this.id,
    required this.type,
    required this.itemName,
    required this.category,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalAmount,
    required this.date,
    required this.buyerSeller,
    required this.status,
    this.notes,
  });

  factory TradingRecord.fromJson(Map<String, dynamic> json) {
    return TradingRecord(
      id: json['id'],
      type: json['type'],
      itemName: json['itemName'],
      category: json['category'],
      quantity: json['quantity'],
      pricePerUnit: json['pricePerUnit'].toDouble(),
      totalAmount: json['totalAmount'].toDouble(),
      date: DateTime.parse(json['date']),
      buyerSeller: json['buyerSeller'],
      status: json['status'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'itemName': itemName,
      'category': category,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'buyerSeller': buyerSeller,
      'status': status,
      'notes': notes,
    };
  }
}
