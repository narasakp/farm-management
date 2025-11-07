import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market_booking.dart';

/// Service สำหรับจัดการการจองคิว
class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  /// สร้างการจองใหม่
  Future<String> createBooking(MarketBooking booking) async {
    try {
      // TODO: Implement Firestore create
      // final docRef = await _firestore.collection(_collection).add(booking.toJson());
      // return docRef.id;

      print('✅ Created booking: ${booking.id}');
      print('   Market: ${booking.marketName}');
      print('   Zone: ${booking.zoneName}');
      print('   Date: ${booking.bookingDate}');
      print('   Total: ${booking.totalFee} บาท');
      
      return booking.id;
    } catch (e) {
      print('❌ Error creating booking: $e');
      rethrow;
    }
  }

  /// ดึงการจองทั้งหมดของ Farm
  Future<List<MarketBooking>> getMyBookings(String farmId) async {
    try {
      // TODO: Implement Firestore query
      // final snapshot = await _firestore
      //   .collection(_collection)
      //   .where('farmId', isEqualTo: farmId)
      //   .orderBy('createdAt', descending: true)
      //   .get();
      // return snapshot.docs
      //   .map((doc) => MarketBooking.fromJson(doc.data()))
      //   .toList();

      // Mock data
      await Future.delayed(const Duration(milliseconds: 500));
      return []; // Empty for now
    } catch (e) {
      print('❌ Error loading bookings: $e');
      return [];
    }
  }

  /// ดึงการจองเฉพาะ ID
  Future<MarketBooking?> getBookingById(String bookingId) async {
    try {
      // TODO: Implement Firestore query
      // final doc = await _firestore.collection(_collection).doc(bookingId).get();
      // if (doc.exists) {
      //   return MarketBooking.fromJson(doc.data()!);
      // }
      // return null;

      await Future.delayed(const Duration(milliseconds: 300));
      return null; // Mock
    } catch (e) {
      print('❌ Error loading booking: $e');
      return null;
    }
  }

  /// อัปเดตการจอง
  Future<void> updateBooking(MarketBooking booking) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(booking.id).update(booking.toJson());

      print('✅ Updated booking: ${booking.id}');
    } catch (e) {
      print('❌ Error updating booking: $e');
      rethrow;
    }
  }

  /// ยืนยันการจอง (หลังชำระเงิน)
  Future<void> confirmBooking(
    String bookingId,
    String queueNumber,
    String paymentId,
  ) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(bookingId).update({
      //   'status': BookingStatus.confirmed.toString().split('.').last,
      //   'paymentStatus': PaymentStatus.paid.toString().split('.').last,
      //   'queueNumber': queueNumber,
      //   'paymentId': paymentId,
      //   'confirmedAt': FieldValue.serverTimestamp(),
      //   'paidAt': FieldValue.serverTimestamp(),
      // });

      print('✅ Confirmed booking: $bookingId');
      print('   Queue: $queueNumber');
      print('   Payment: $paymentId');
    } catch (e) {
      print('❌ Error confirming booking: $e');
      rethrow;
    }
  }

  /// ยกเลิกการจอง
  Future<void> cancelBooking(String bookingId, String reason) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(bookingId).update({
      //   'status': BookingStatus.cancelled.toString().split('.').last,
      //   'cancelReason': reason,
      //   'cancelledAt': FieldValue.serverTimestamp(),
      // });

      print('✅ Cancelled booking: $bookingId');
      print('   Reason: $reason');
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      rethrow;
    }
  }

  /// Check-in (สแกน QR)
  Future<void> checkIn(String bookingId, String staffId) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(bookingId).update({
      //   'status': BookingStatus.checked_in.toString().split('.').last,
      //   'checkInAt': FieldValue.serverTimestamp(),
      //   'checkInBy': staffId,
      // });

      print('✅ Checked in: $bookingId');
    } catch (e) {
      print('❌ Error checking in: $e');
      rethrow;
    }
  }

  /// ทำเครื่องหมายเสร็จสิ้น
  Future<void> completeBooking(String bookingId) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(bookingId).update({
      //   'status': BookingStatus.completed.toString().split('.').last,
      //   'completedAt': FieldValue.serverTimestamp(),
      // });

      print('✅ Completed booking: $bookingId');
    } catch (e) {
      print('❌ Error completing booking: $e');
      rethrow;
    }
  }

  /// ทำเครื่องหมาย No-show
  Future<void> markNoShow(String bookingId) async {
    try {
      // TODO: Implement Firestore update
      // await _firestore.collection(_collection).doc(bookingId).update({
      //   'status': BookingStatus.no_show.toString().split('.').last,
      //   'completedAt': FieldValue.serverTimestamp(),
      // });

      print('⚠️ Marked no-show: $bookingId');
    } catch (e) {
      print('❌ Error marking no-show: $e');
      rethrow;
    }
  }

  /// ตรวจสอบการจอง expired (ไม่ชำระเงิน)
  Future<void> checkExpiredBookings() async {
    try {
      // TODO: Query bookings ที่หมดอายุและอัปเดตสถานะ
      // final now = Timestamp.now();
      // final snapshot = await _firestore
      //   .collection(_collection)
      //   .where('status', isEqualTo: 'pending')
      //   .where('expiresAt', isLessThan: now)
      //   .get();
      
      // for (var doc in snapshot.docs) {
      //   await doc.reference.update({
      //     'status': BookingStatus.expired.toString().split('.').last,
      //   });
      // }

      print('✅ Checked expired bookings');
    } catch (e) {
      print('❌ Error checking expired bookings: $e');
    }
  }

  /// ดึงการจองตามตลาดและวัน (สำหรับ Admin)
  Future<List<MarketBooking>> getBookingsByMarketAndDate(
    String marketId,
    DateTime date,
  ) async {
    try {
      // TODO: Implement Firestore query
      // final snapshot = await _firestore
      //   .collection(_collection)
      //   .where('marketId', isEqualTo: marketId)
      //   .where('bookingDate', isEqualTo: Timestamp.fromDate(date))
      //   .orderBy('queueNumber')
      //   .get();
      // return snapshot.docs
      //   .map((doc) => MarketBooking.fromJson(doc.data()))
      //   .toList();

      await Future.delayed(const Duration(milliseconds: 400));
      return [];
    } catch (e) {
      print('❌ Error loading bookings by market: $e');
      return [];
    }
  }

  /// นับจำนวนการจองตามสถานะ
  Future<Map<String, int>> countBookingsByStatus(String farmId) async {
    try {
      // TODO: Implement real count
      return {
        'pending': 0,
        'confirmed': 0,
        'completed': 0,
        'cancelled': 0,
      };
    } catch (e) {
      print('❌ Error counting bookings: $e');
      return {};
    }
  }
}
