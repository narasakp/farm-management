# 📅 แผนการพัฒนา - ระบบจองคิวตลาดนัด

## Phase 1: MVP (Week 1-3) ⭐

### Week 1: Foundation

**Day 1-2: Models & Firebase**
- [ ] สร้าง models ทั้งหมด
- [ ] Setup Firebase collections
- [ ] Mock data (5 ตลาด, 10 โซน)

**Day 3-4: Services**
- [ ] MarketService (CRUD)
- [ ] BookingService (Create, Cancel)
- [ ] QRService (Generate)

**Day 5: Providers**
- [ ] MarketProvider
- [ ] BookingProvider
- [ ] Tests

### Week 2: UI - จองคิว

**Day 1-2: Markets List**
- [ ] markets_list_tab.dart
- [ ] market_card.dart
- [ ] Search & Filter

**Day 3-4: Booking Dialog**
- [ ] booking_dialog.dart
- [ ] Zone selector
- [ ] Date/Time picker
- [ ] Livestock selector

**Day 5: Fee Summary**
- [ ] คำนวณค่าธรรมเนียม
- [ ] Validation

### Week 3: UI - คิวของฉัน

**Day 1-2: Bookings List**
- [ ] my_bookings_tab.dart
- [ ] booking_card.dart
- [ ] Status filter

**Day 3-4: Booking Detail**
- [ ] booking_detail_screen.dart
- [ ] QR display (mock)
- [ ] Cancel function

**Day 5: Integration**
- [ ] เชื่อม market_screen.dart
- [ ] E2E testing

---

## Phase 2: Enhanced (Week 4-6)

### Week 4: Payment

- [ ] PaymentService (QR PromptPay)
- [ ] payment_screen.dart
- [ ] QR display + Timer
- [ ] Webhook handler
- [ ] Auto-confirm

### Week 5: Notifications

- [ ] FCM setup
- [ ] LINE Notify integration
- [ ] Local notifications
- [ ] Schedule reminders
- [ ] Templates

### Week 6: QR & Maps

- [ ] Real QR generation
- [ ] QR verification
- [ ] Google Maps display
- [ ] Directions
- [ ] Polish

---

## Phase 3: Advanced (Week 7-9)

### Week 7: Admin

- [ ] market_management_screen.dart
- [ ] CRUD Markets
- [ ] Image upload
- [ ] booking_management_screen.dart
- [ ] QR scanner (check-in)

### Week 8: Reviews

- [ ] review_screen.dart
- [ ] Star rating
- [ ] Image upload
- [ ] Display on market card
- [ ] Moderation

### Week 9: Analytics & Deploy

- [ ] analytics_dashboard_screen.dart
- [ ] Booking stats
- [ ] Revenue charts
- [ ] Full testing
- [ ] Deploy

---

**Total: 9 สัปดาห์ (63 วัน)**

## 📦 Packages Required

```yaml
dependencies:
  # Payment
  qr_flutter: ^4.1.0
  
  # Notifications
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
  http: ^1.2.0  # LINE Notify
  
  # Maps
  google_maps_flutter: ^2.5.0
  url_launcher: ^6.2.2
  
  # Reviews
  flutter_rating_bar: ^4.0.1
  image_picker: ^1.0.5
```

---

**Status Tracking:**
- ✅ Completed
- 🚧 In Progress
- ⏳ Pending
