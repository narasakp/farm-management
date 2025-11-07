# 📅 ระบบจองคิวตลาดนัด - เอกสารภาพรวม

**วันที่:** 20 ตุลาคม 2025  
**สถานะ:** Ready for Implementation  
**เวอร์ชัน:** 1.0

---

## 🎯 วัตถุประสงค์

พัฒนาระบบจองคิวตลาดนัดออนไลน์สำหรับเกษตรกร เพื่อ:
- ลดเวลาการรอคิวที่ตลาด **70%**
- เพิ่มประสิทธิภาพการบริหารจัดการตลาด
- สร้างความโปร่งใสในการจัดสรรคิว
- เก็บข้อมูลสถิติเพื่อวิเคราะห์

---

## 📊 ข้อกำหนดจากผู้ใช้

| คำถาม | คำตอบ |
|-------|-------|
| **ตลาดนัดมีกี่แห่ง?** | หลายแห่ง + เพิ่มได้เรื่อย ๆ (ต้องมี CRUD) |
| **ระบบคิวแบบไหน?** | แบ่งโซนตามประเภทสัตว์ + FCFS ในแต่ละโซน |
| **ค่าธรรมเนียม?** | จ่ายออนไลน์ผ่านระบบ (QR PromptPay) |
| **Notification?** | In-app + LINE Notify + FCM (ทุกช่องทางฟรี) |
| **เริ่มจาก Phase ไหน?** | MVP → Full Feature (แบบค่อยเป็นค่อยไป) |

---

## ✅ Business Rules

### การจองคิว
- จองล่วงหน้าได้ 1-30 วัน
- 1 การจอง = 1 โซน = 1 ช่วงเวลา
- สามารถจองหลายตัวสัตว์ในคิวเดียว

### ระบบคิว  
- แบ่งโซนตามประเภทสัตว์ (โค, กระบือ, สุกร, เป็ด, ไก่, แพะ, แกะ)
- FCFS (First Come First Serve) ภายในแต่ละโซน
- เลขคิว: `[Zone]-[Number]` เช่น **A-015**

### การชำระเงิน
- ชำระภายใน **30 นาที** หลังจอง
- ไม่ชำระ → คิวถูกยกเลิกอัตโนมัติ  
- คืนเงิน **100%** ถ้ายกเลิกก่อน 24 ชม.

### การยกเลิก
- ยกเลิกได้ก่อนวันนัด **24 ชั่วโมง**
- ยกเลิกหลัง 24 ชม. → **ไม่คืนเงิน**
- No-show 3 ครั้ง → **ระงับการจอง 30 วัน**

---

## 🗂️ เอกสารประกอบ

1. **[QUEUE_BOOKING_MODELS.md](./QUEUE_BOOKING_MODELS.md)** - Data Models ทั้งหมด
2. **[QUEUE_BOOKING_IMPLEMENTATION.md](./QUEUE_BOOKING_IMPLEMENTATION.md)** - แผนการพัฒนา 9 สัปดาห์
3. **[QUEUE_BOOKING_TECHNICAL.md](./QUEUE_BOOKING_TECHNICAL.md)** - Technical Specifications

---

## 🚀 Timeline สรุป

| Phase | Duration | Features |
|-------|----------|----------|
| **Phase 1: MVP** | Week 1-3 | Models, Services, UI (จองคิว + คิวของฉัน) |
| **Phase 2: Enhanced** | Week 4-6 | Payment, Notifications, QR Code, Maps |
| **Phase 3: Advanced** | Week 7-9 | Admin Panel, Reviews, Analytics |

**Total:** **9 สัปดาห์** (2+ เดือน)

---

## 📦 Tech Stack

- **Backend:** Firebase Firestore
- **Payment:** QR PromptPay API
- **Notifications:** FCM + LINE Notify (ฟรี!)
- **Maps:** Google Maps API
- **QR:** qr_flutter package
- **State:** Provider

---

## ✨ Key Features

1. ✅ แบ่งโซนตามประเภทสัตว์
2. ✅ FCFS ในแต่ละโซน
3. ✅ ชำระเงินออนไลน์ (QR PromptPay)
4. ✅ Multi-channel Notifications (FCM + LINE + Local)
5. ✅ QR Code Check-in
6. ✅ Google Maps Integration
7. ✅ Reviews & Ratings
8. ✅ Admin Panel (CRUD Markets)
9. ✅ Analytics Dashboard

---

**เริ่มพัฒนาได้เลย! 🎉**
