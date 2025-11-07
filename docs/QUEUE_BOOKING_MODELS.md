# 🗄️ Data Models - ระบบจองคิวตลาดนัด

## 1. Market (ตลาดนัด)

```dart
class Market {
  String id;
  String name;                    // 'ตลาดนัดเทศบาลเมือง'
  String description;
  String location;                // 'เขตเมือง, ขอนแก่น'
  GeoPoint? coordinates;          // lat, lng
  
  Map<String, MarketSchedule> schedules;  // {'monday': {...}}
  List<MarketZone> zones;
  
  double baseFee;                 // 100 บาท
  Map<String, double>? zoneFees;  // {'zone_a': 50}
  
  double rating;                  // 0.0 - 5.0
  int reviewCount;
  
  bool isActive;
  String? imageUrl;
  String? rules;
  String? phone;
  
  DateTime createdAt;
  DateTime updatedAt;
}
```

## 2. MarketZone (โซน)

```dart
class MarketZone {
  String id;              // 'zone_a'
  String name;            // 'โซน A (โค-กระบือ)'
  String code;            // 'A'
  String livestockType;   // 'โค', 'กระบือ', 'สุกร'...
  
  int totalSlots;         // 20
  double? extraFee;       // 50 บาท
  
  bool isActive;
  int sortOrder;
}
```

## 3. MarketBooking (การจองคิว)

```dart
class MarketBooking {
  String id;
  
  // ผู้จอง
  String farmId;
  String farmerName;
  String farmerPhone;
  
  // ตลาด & โซน
  String marketId;
  String marketName;
  String zoneId;
  String zoneName;
  String? queueNumber;    // 'A-015'
  
  // วัน-เวลา
  DateTime bookingDate;
  String timeSlot;        // '06:00-08:00'
  
  // สัตว์
  List<BookingItem> items;
  int totalQuantity;
  double? totalWeight;
  
  // ค่าธรรมเนียม
  double baseFee;
  double zoneFee;
  double totalFee;
  
  // Payment
  PaymentStatus paymentStatus;
  String? paymentId;
  DateTime? paidAt;
  
  // Status
  BookingStatus status;
  
  // QR Code
  String? qrCode;
  DateTime? checkInAt;
  
  String? notes;
  String? cancelReason;
  
  DateTime createdAt;
  DateTime? confirmedAt;
  DateTime? cancelledAt;
}
```

## 4. BookingItem (สัตว์)

```dart
class BookingItem {
  String livestockId;
  String livestockType;   // 'โค'
  String earTag;          // 'C001'
  int quantity;           // 1
  double? weight;         // 450 กก.
}
```

## 5. Enums

```dart
enum PaymentStatus {
  pending,    // รอชำระ
  paid,       // ชำระแล้ว
  refunded,   // คืนเงิน
  expired,    // หมดอายุ
}

enum BookingStatus {
  pending,      // รอชำระ
  confirmed,    // ยืนยันแล้ว
  checked_in,   // เช็คอิน
  completed,    // เสร็จสิ้น
  cancelled,    // ยกเลิก
  no_show,      // ไม่มา
  expired,      // หมดอายุ
}
```

## 6. MarketReview (รีวิว)

```dart
class MarketReview {
  String id;
  String marketId;
  String farmerId;
  String bookingId;
  
  double rating;          // 1-5
  String? comment;
  List<String>? imageUrls;
  
  DateTime createdAt;
}
```

---

**ดูเพิ่ม:** [QUEUE_BOOKING_IMPLEMENTATION.md](./QUEUE_BOOKING_IMPLEMENTATION.md)
