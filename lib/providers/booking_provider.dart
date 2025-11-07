import 'package:flutter/foundation.dart';
import '../models/market_booking.dart';
import '../services/booking_service.dart';
import '../services/market_service.dart';
import '../services/qr_service.dart';

/// Provider สำหรับจัดการ state ของการจองคิว
class BookingProvider with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  final MarketService _marketService = MarketService();
  final QRService _qrService = QRService();

  List<MarketBooking> _myBookings = [];
  MarketBooking? _selectedBooking;
  bool _isLoading = false;
  String? _error;
  String _statusFilter = 'ทั้งหมด';

  // Getters
  List<MarketBooking> get myBookings => _myBookings;
  MarketBooking? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get statusFilter => _statusFilter;

  /// ดึงการจองทั้งหมดของผู้ใช้
  Future<void> loadMyBookings(String farmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📡 Loading bookings for farm: $farmId');
      _myBookings = await _bookingService.getMyBookings(farmId);
      print('✅ Loaded ${_myBookings.length} bookings');
    } catch (e) {
      _error = e.toString();
      print('❌ Error loading bookings: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// สร้างการจองใหม่
  Future<String?> createBooking(MarketBooking booking) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📝 Creating booking...');
      
      // สร้างการจอง
      final bookingId = await _bookingService.createBooking(booking);
      
      // Reload bookings
      await loadMyBookings(booking.farmId);
      
      print('✅ Booking created: $bookingId');
      return bookingId;
    } catch (e) {
      _error = e.toString();
      print('❌ Error creating booking: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ยืนยันการจอง (หลังชำระเงิน)
  Future<bool> confirmBooking(
    String bookingId,
    String paymentId,
  ) async {
    try {
      print('✅ Confirming booking...');
      
      // สร้างเลขคิว
      final booking = _myBookings.firstWhere((b) => b.id == bookingId);
      final queueNumber = await _marketService.generateQueueNumber(
        booking.marketId,
        booking.zoneId,
        booking.bookingDate,
      );

      // ยืนยันการจอง
      await _bookingService.confirmBooking(
        bookingId,
        queueNumber,
        paymentId,
      );

      // สร้าง QR Code
      final qrData = _qrService.generateBookingQR(bookingId, queueNumber);

      // TODO: Update booking with QR code

      // Reload
      await loadMyBookings(booking.farmId);

      print('✅ Booking confirmed: $queueNumber');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error confirming booking: $e');
      return false;
    }
  }

  /// ยืนยันการชำระเงิน (สำหรับหน้า Payment)
  Future<bool> confirmPayment(String bookingId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('💰 Confirming payment...');
      
      // สร้าง payment ID (mock)
      final paymentId = 'pay_${DateTime.now().millisecondsSinceEpoch}';
      
      // ยืนยันการจอง
      final result = await confirmBooking(bookingId, paymentId);
      
      print('✅ Payment confirmed');
      return result;
    } catch (e) {
      _error = e.toString();
      print('❌ Error confirming payment: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// ยกเลิกการจอง
  Future<bool> cancelBooking(String bookingId, String reason) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('⚠️ Cancelling booking...');
      
      await _bookingService.cancelBooking(bookingId, reason);
      
      // Reload
      final booking = _myBookings.firstWhere((b) => b.id == bookingId);
      await loadMyBookings(booking.farmId);
      
      print('✅ Booking cancelled');
      return true;
    } catch (e) {
      _error = e.toString();
      print('❌ Error cancelling booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// เลือกการจอง
  void selectBooking(MarketBooking booking) {
    _selectedBooking = booking;
    notifyListeners();
  }

  /// เคลียร์การเลือก
  void clearSelection() {
    _selectedBooking = null;
    notifyListeners();
  }

  /// กรองตามสถานะ
  void filterByStatus(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  /// รายการที่กรองแล้ว
  List<MarketBooking> get filteredBookings {
    if (_statusFilter == 'ทั้งหมด') {
      return _myBookings;
    }

    BookingStatus? targetStatus;
    switch (_statusFilter) {
      case 'รอชำระ':
        targetStatus = BookingStatus.pending;
        break;
      case 'ยืนยันแล้ว':
        targetStatus = BookingStatus.confirmed;
        break;
      case 'เสร็จสิ้น':
        targetStatus = BookingStatus.completed;
        break;
      case 'ยกเลิก':
        targetStatus = BookingStatus.cancelled;
        break;
    }

    if (targetStatus == null) return _myBookings;

    return _myBookings.where((b) => b.status == targetStatus).toList();
  }

  /// นับการจองตามสถานะ
  Map<String, int> get bookingCounts {
    return {
      'pending': _myBookings.where((b) => b.status == BookingStatus.pending).length,
      'confirmed': _myBookings.where((b) => b.status == BookingStatus.confirmed).length,
      'completed': _myBookings.where((b) => b.status == BookingStatus.completed).length,
      'cancelled': _myBookings.where((b) => b.status == BookingStatus.cancelled).length,
    };
  }
}
