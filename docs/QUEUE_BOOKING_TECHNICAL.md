# ⚙️ Technical Specifications - ระบบจองคิวตลาดนัด

## 🏗️ System Architecture

### Folder Structure

```
lib/
├── models/
│   ├── market.dart
│   ├── market_booking.dart
│   └── market_review.dart
│
├── services/
│   ├── market_service.dart
│   ├── booking_service.dart
│   ├── payment_service.dart
│   ├── notification_service.dart
│   └── qr_service.dart
│
├── providers/
│   ├── market_provider.dart
│   └── booking_provider.dart
│
├── screens/
│   ├── queue/
│   │   ├── markets_list_tab.dart
│   │   ├── my_bookings_tab.dart
│   │   ├── booking_dialog.dart
│   │   └── review_screen.dart
│   ├── payment/
│   │   └── payment_screen.dart
│   └── admin/
│       └── market_management_screen.dart
│
└── widgets/
    ├── market_card.dart
    └── booking_card.dart
```

---

## 🔥 Firebase Collections

### markets
```json
{
  "market_001": {
    "name": "ตลาดนัดเทศบาลเมือง",
    "location": "เขตเมือง, ขอนแก่น",
    "coordinates": {"lat": 16.4419, "lng": 102.8360},
    "zones": [
      {"id": "zone_a", "name": "โซน A (โค)", "totalSlots": 20}
    ],
    "baseFee": 100,
    "rating": 4.5,
    "isActive": true,
    "createdAt": "2025-10-20T10:00:00Z"
  }
}
```

### bookings
```json
{
  "booking_001": {
    "farmId": "farm_001",
    "marketId": "market_001",
    "zoneId": "zone_a",
    "queueNumber": "A-015",
    "bookingDate": "2025-10-22",
    "timeSlot": "06:00-08:00",
    "totalFee": 150,
    "paymentStatus": "paid",
    "status": "confirmed",
    "createdAt": "2025-10-20T10:00:00Z"
  }
}
```

---

## 💳 Payment Integration

### QR PromptPay API

```dart
class PaymentService {
  Future<String> generatePromptPayQR(double amount) async {
    final url = 'https://promptpay.io/${PHONE_NUMBER}/${amount}.png';
    return url;
  }
  
  Future<bool> verifyPayment(String paymentId) async {
    // ตรวจสอบ Webhook หรือ Manual confirmation
    return true;
  }
}
```

**Note:** PromptPay เป็น Thailand standard, ใช้ได้ฟรี!

---

## 🔔 Notification System

### 1. FCM (Firebase Cloud Messaging)

```dart
// Free! รองรับ iOS + Android
Future<void> sendFCMNotification(String userId, String title, String body) async {
  await FirebaseMessaging.instance.sendMessage(
    to: '/topics/user_$userId',
    notification: Notification(title: title, body: body),
  );
}
```

### 2. LINE Notify

```dart
// Free! ส่งไปที่ LINE ส่วนตัว
Future<void> sendLINENotify(String token, String message) async {
  await http.post(
    Uri.parse('https://notify-api.line.me/api/notify'),
    headers: {'Authorization': 'Bearer $token'},
    body: {'message': message},
  );
}
```

### 3. Local Notifications

```dart
// Free! Offline notifications
Future<void> scheduleNotification(String title, String body, DateTime when) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0, title, body, tz.TZDateTime.from(when, tz.local),
    const NotificationDetails(),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  );
}
```

---

## 📱 QR Code

### Generation

```dart
import 'package:qr_flutter/qr_flutter.dart';

String generateBookingQR(MarketBooking booking) {
  final data = json.encode({
    'id': booking.id,
    'queueNumber': booking.queueNumber,
    'timestamp': DateTime.now().toIso8601String(),
    'signature': _generateSignature(booking.id),
  });
  return data;
}

Widget buildQRCode(String data) {
  return QrImageView(
    data: data,
    version: QrVersions.auto,
    size: 200.0,
  );
}
```

---

## 🗺️ Google Maps

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> openGoogleMaps(double lat, double lng) async {
  final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
  await launchUrl(Uri.parse(url));
}
```

---

## 🎨 UI/UX Guidelines (ผู้สูงอายุ 60+)

### Typography
- **Body:** 20-22px
- **Headings:** 28-32px
- **Buttons:** 22-24px

### Spacing
- **Button Padding:** 20-24px
- **Card Margin:** 16px
- **Icon Size:** 32-36px

### Colors
```dart
confirmed: Color(0xFF4CAF50),   // เขียว
pending: Color(0xFFFFC107),     // เหลือง
cancelled: Color(0xFFF44336),   // แดง
```

### Accessibility
- High contrast ratios (4.5:1+)
- Touch targets: 48×48px minimum
- Clear labels with icons

---

## ⚡ Performance

### Optimization
- Lazy loading for markets list
- Pagination (20 items/page)
- Image caching
- Offline support (local cache)

### Monitoring
- Firebase Analytics
- Crashlytics for error tracking
- Performance monitoring

---

## 🧪 Testing Strategy

### Unit Tests
- Models serialization
- Services logic
- Validation rules

### Integration Tests
- Booking flow E2E
- Payment flow
- Notification delivery

### User Acceptance Testing
- Test with actual users 60+
- Collect feedback
- Iterate

---

## 🚀 Deployment

### Pre-launch Checklist
- [ ] All features tested
- [ ] Performance optimized
- [ ] Firebase security rules set
- [ ] Google Maps API key configured
- [ ] Payment gateway tested
- [ ] Notifications working
- [ ] User documentation ready

### Launch Strategy
1. **Soft Launch:** เปิดให้ 10 เกษตรกรทดสอบ
2. **Feedback:** รวบรวม feedback 1 สัปดาห์
3. **Fixes:** แก้ไข bugs
4. **Full Launch:** เปิดใช้งานเต็มรูปแบบ

---

**Ready to Build! 🎉**
