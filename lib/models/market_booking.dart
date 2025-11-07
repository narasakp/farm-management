import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_item.dart';

/// สถานะการชำระเงิน
enum PaymentStatus {
  pending,    // รอชำระ
  paid,       // ชำระแล้ว
  refunded,   // คืนเงินแล้ว
  expired,    // หมดอายุ (ไม่ชำระภายใน 30 นาที)
}

/// สถานะคิว
enum BookingStatus {
  pending,      // รอชำระเงิน
  confirmed,    // ยืนยันแล้ว (ชำระเงินแล้ว)
  checked_in,   // เช็คอินแล้ว (มาถึงตลาด)
  completed,    // ใช้บริการเสร็จ
  cancelled,    // ยกเลิกโดยผู้จอง
  no_show,      // ไม่มาตามนัด
  expired,      // หมดอายุ (ไม่ชำระเงิน)
}

/// การจองคิวตลาดนัด
class MarketBooking {
  final String id;
  
  // ข้อมูลผู้จอง
  final String farmId;
  final String farmerName;
  final String farmerPhone;
  final String? farmerEmail;
  
  // ข้อมูลตลาดและโซน
  final String marketId;
  final String marketName;
  final String zoneId;
  final String zoneName;
  final String? queueNumber;          // 'A-015' (หลังชำระเงินแล้ว)
  
  // วันที่-เวลา
  final DateTime bookingDate;         // วันที่ไปใช้บริการ
  final String timeSlot;              // '06:00-08:00'
  
  // สัตว์ที่จะนำมาขาย
  final List<BookingItem> items;
  final int totalQuantity;            // จำนวนรวม
  final double? totalWeight;          // น้ำหนักรวม (กก.)
  
  // ค่าธรรมเนียม
  final double baseFee;               // 100
  final double zoneFee;               // 50
  final double totalFee;              // 150
  
  // การชำระเงิน
  final PaymentStatus paymentStatus;
  final String? paymentId;            // Transaction ID
  final String? paymentMethod;        // 'promptpay'
  final DateTime? paidAt;
  
  // สถานะคิว
  final BookingStatus status;
  
  // QR Code สำหรับ Check-in
  final String? qrCode;               // JSON: {id, signature, timestamp}
  final DateTime? checkInAt;
  final String? checkInBy;            // Staff/Admin ID
  
  // หมายเหตุ
  final String? notes;                // จากผู้จอง
  final String? adminNotes;           // จาก Admin
  final String? cancelReason;         // เหตุผลการยกเลิก
  
  // Timestamps
  final DateTime createdAt;           // เวลาที่จอง
  final DateTime? confirmedAt;        // เวลาที่ยืนยัน (ชำระเงิน)
  final DateTime? cancelledAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;          // หมดอายุการจอง (ถ้าไม่ชำระ)

  MarketBooking({
    required this.id,
    required this.farmId,
    required this.farmerName,
    required this.farmerPhone,
    this.farmerEmail,
    required this.marketId,
    required this.marketName,
    required this.zoneId,
    required this.zoneName,
    this.queueNumber,
    required this.bookingDate,
    required this.timeSlot,
    required this.items,
    required this.totalQuantity,
    this.totalWeight,
    required this.baseFee,
    required this.zoneFee,
    required this.totalFee,
    this.paymentStatus = PaymentStatus.pending,
    this.paymentId,
    this.paymentMethod,
    this.paidAt,
    this.status = BookingStatus.pending,
    this.qrCode,
    this.checkInAt,
    this.checkInBy,
    this.notes,
    this.adminNotes,
    this.cancelReason,
    required this.createdAt,
    this.confirmedAt,
    this.cancelledAt,
    this.completedAt,
    this.expiresAt,
  });

  // From JSON
  factory MarketBooking.fromJson(Map<String, dynamic> json) {
    // Parse items
    List<BookingItem> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List<dynamic>)
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Parse enums
    PaymentStatus paymentStatus = PaymentStatus.pending;
    if (json['paymentStatus'] != null) {
      paymentStatus = PaymentStatus.values.firstWhere(
        (e) => e.toString() == 'PaymentStatus.${json['paymentStatus']}',
        orElse: () => PaymentStatus.pending,
      );
    }

    BookingStatus status = BookingStatus.pending;
    if (json['status'] != null) {
      status = BookingStatus.values.firstWhere(
        (e) => e.toString() == 'BookingStatus.${json['status']}',
        orElse: () => BookingStatus.pending,
      );
    }

    return MarketBooking(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      farmerName: json['farmerName'] as String,
      farmerPhone: json['farmerPhone'] as String,
      farmerEmail: json['farmerEmail'] as String?,
      marketId: json['marketId'] as String,
      marketName: json['marketName'] as String,
      zoneId: json['zoneId'] as String,
      zoneName: json['zoneName'] as String,
      queueNumber: json['queueNumber'] as String?,
      bookingDate: (json['bookingDate'] as Timestamp).toDate(),
      timeSlot: json['timeSlot'] as String,
      items: items,
      totalQuantity: json['totalQuantity'] as int,
      totalWeight: (json['totalWeight'] as num?)?.toDouble(),
      baseFee: (json['baseFee'] as num).toDouble(),
      zoneFee: (json['zoneFee'] as num).toDouble(),
      totalFee: (json['totalFee'] as num).toDouble(),
      paymentStatus: paymentStatus,
      paymentId: json['paymentId'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      paidAt: (json['paidAt'] as Timestamp?)?.toDate(),
      status: status,
      qrCode: json['qrCode'] as String?,
      checkInAt: (json['checkInAt'] as Timestamp?)?.toDate(),
      checkInBy: json['checkInBy'] as String?,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      cancelReason: json['cancelReason'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      confirmedAt: (json['confirmedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (json['cancelledAt'] as Timestamp?)?.toDate(),
      completedAt: (json['completedAt'] as Timestamp?)?.toDate(),
      expiresAt: (json['expiresAt'] as Timestamp?)?.toDate(),
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'farmerName': farmerName,
      'farmerPhone': farmerPhone,
      'farmerEmail': farmerEmail,
      'marketId': marketId,
      'marketName': marketName,
      'zoneId': zoneId,
      'zoneName': zoneName,
      'queueNumber': queueNumber,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'timeSlot': timeSlot,
      'items': items.map((e) => e.toJson()).toList(),
      'totalQuantity': totalQuantity,
      'totalWeight': totalWeight,
      'baseFee': baseFee,
      'zoneFee': zoneFee,
      'totalFee': totalFee,
      'paymentStatus': paymentStatus.toString().split('.').last,
      'paymentId': paymentId,
      'paymentMethod': paymentMethod,
      'paidAt': paidAt != null ? Timestamp.fromDate(paidAt!) : null,
      'status': status.toString().split('.').last,
      'qrCode': qrCode,
      'checkInAt': checkInAt != null ? Timestamp.fromDate(checkInAt!) : null,
      'checkInBy': checkInBy,
      'notes': notes,
      'adminNotes': adminNotes,
      'cancelReason': cancelReason,
      'createdAt': Timestamp.fromDate(createdAt),
      'confirmedAt': confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'cancelledAt': cancelledAt != null ? Timestamp.fromDate(cancelledAt!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
    };
  }

  MarketBooking copyWith({
    String? id,
    String? farmId,
    String? farmerName,
    String? farmerPhone,
    String? farmerEmail,
    String? marketId,
    String? marketName,
    String? zoneId,
    String? zoneName,
    String? queueNumber,
    DateTime? bookingDate,
    String? timeSlot,
    List<BookingItem>? items,
    int? totalQuantity,
    double? totalWeight,
    double? baseFee,
    double? zoneFee,
    double? totalFee,
    PaymentStatus? paymentStatus,
    String? paymentId,
    String? paymentMethod,
    DateTime? paidAt,
    BookingStatus? status,
    String? qrCode,
    DateTime? checkInAt,
    String? checkInBy,
    String? notes,
    String? adminNotes,
    String? cancelReason,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    DateTime? completedAt,
    DateTime? expiresAt,
  }) {
    return MarketBooking(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      farmerName: farmerName ?? this.farmerName,
      farmerPhone: farmerPhone ?? this.farmerPhone,
      farmerEmail: farmerEmail ?? this.farmerEmail,
      marketId: marketId ?? this.marketId,
      marketName: marketName ?? this.marketName,
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      queueNumber: queueNumber ?? this.queueNumber,
      bookingDate: bookingDate ?? this.bookingDate,
      timeSlot: timeSlot ?? this.timeSlot,
      items: items ?? this.items,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalWeight: totalWeight ?? this.totalWeight,
      baseFee: baseFee ?? this.baseFee,
      zoneFee: zoneFee ?? this.zoneFee,
      totalFee: totalFee ?? this.totalFee,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentId: paymentId ?? this.paymentId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      status: status ?? this.status,
      qrCode: qrCode ?? this.qrCode,
      checkInAt: checkInAt ?? this.checkInAt,
      checkInBy: checkInBy ?? this.checkInBy,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      cancelReason: cancelReason ?? this.cancelReason,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// สามารถยกเลิกได้หรือไม่ (ก่อนวันนัด 24 ชม.)
  bool get canCancel {
    if (status != BookingStatus.confirmed) return false;
    final now = DateTime.now();
    final diff = bookingDate.difference(now);
    return diff.inHours >= 24;
  }

  /// หมดอายุการจองหรือยัง
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }
}
