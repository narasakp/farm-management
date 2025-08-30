class TransportRecord {
  final String id;
  final String type; // 'delivery', 'pickup', 'transfer'
  final String itemName;
  final int quantity;
  final String fromLocation;
  final String toLocation;
  final DateTime scheduledDate;
  final DateTime? actualDate;
  final String driverName;
  final String vehicleNumber;
  final String status; // 'scheduled', 'in_transit', 'delivered', 'cancelled'
  final double distance; // ระยะทาง (กม.)
  final double cost;
  final String? notes;

  TransportRecord({
    required this.id,
    required this.type,
    required this.itemName,
    required this.quantity,
    required this.fromLocation,
    required this.toLocation,
    required this.scheduledDate,
    this.actualDate,
    required this.driverName,
    required this.vehicleNumber,
    required this.status,
    required this.distance,
    required this.cost,
    this.notes,
  });

  factory TransportRecord.fromJson(Map<String, dynamic> json) {
    return TransportRecord(
      id: json['id'],
      type: json['type'],
      itemName: json['itemName'],
      quantity: json['quantity'],
      fromLocation: json['fromLocation'],
      toLocation: json['toLocation'],
      scheduledDate: DateTime.parse(json['scheduledDate']),
      actualDate: json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null,
      driverName: json['driverName'],
      vehicleNumber: json['vehicleNumber'],
      status: json['status'],
      distance: json['distance'].toDouble(),
      cost: json['cost'].toDouble(),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'itemName': itemName,
      'quantity': quantity,
      'fromLocation': fromLocation,
      'toLocation': toLocation,
      'scheduledDate': scheduledDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'driverName': driverName,
      'vehicleNumber': vehicleNumber,
      'status': status,
      'distance': distance,
      'cost': cost,
      'notes': notes,
    };
  }
}
