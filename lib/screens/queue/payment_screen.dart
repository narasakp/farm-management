import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../utils/price_formatter.dart';
import '../../models/market_booking.dart';
import '../../providers/booking_provider.dart';
import '../../services/qr_service.dart';
import '../../utils/snackbar_helper.dart';

/// หน้าจอชำระเงินด้วย QR PromptPay
class PaymentScreen extends StatefulWidget {
  final MarketBooking booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  String? _qrData;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
    _generateQR();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// คำนวณเวลาที่เหลือ
  void _calculateRemainingTime() {
    final now = DateTime.now();
    final expiry = widget.booking.expiresAt ?? now.add(const Duration(minutes: 30));
    _remainingTime = expiry.difference(now);
    if (_remainingTime.isNegative) {
      _remainingTime = Duration.zero;
    }
  }

  /// เริ่ม Timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
        if (_remainingTime.isNegative || _remainingTime == Duration.zero) {
          _timer?.cancel();
          _handleExpired();
        }
      });
    });
  }

  /// สร้าง QR Code
  void _generateQR() {
    final qrService = QRService();
    // Generate PromptPay QR URL
    final qrData = qrService.generatePromptPayQR(
      '0812345678', // TODO: ใช้เบอร์จริงจากตลาด
      widget.booking.totalFee,
    );
    setState(() {
      _qrData = qrData;
    });
  }

  /// หมดอายุ
  void _handleExpired() {
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('หมดเวลา', style: TextStyle(fontSize: 24)),
          content: const Text(
            'การจองหมดอายุแล้ว กรุณาจองใหม่อีกครั้ง',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close payment screen
              },
              child: const Text('ตรงลง', style: TextStyle(fontSize: 20)),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ชำระเงิน'),
        backgroundColor: const Color(0xFF228B22),
        foregroundColor: Colors.white,
      ),
      body: _remainingTime == Duration.zero
          ? _buildExpired()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Timer
                  _buildTimer(),

                  const SizedBox(height: 24),

                  // Booking Info
                  _buildBookingInfo(),

                  const SizedBox(height: 24),

                  // QR Code
                  _buildQRCode(),

                  const SizedBox(height: 24),

                  // Amount
                  _buildAmount(),

                  const SizedBox(height: 24),

                  // Instructions
                  _buildInstructions(),

                  const SizedBox(height: 32),

                  // Confirm Button
                  _buildConfirmButton(),

                  const SizedBox(height: 16),

                  // Cancel Button
                  _buildCancelButton(),
                ],
              ),
            ),
    );
  }

  /// Timer Countdown
  Widget _buildTimer() {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    final isUrgent = _remainingTime.inMinutes < 5;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red[50] : Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? Colors.red : Colors.orange,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 32,
            color: isUrgent ? Colors.red : Colors.orange,
          ),
          const SizedBox(width: 12),
          Column(
            children: [
              Text(
                'เวลาที่เหลือ',
                style: TextStyle(
                  fontSize: 16,
                  color: isUrgent ? Colors.red : Colors.orange,
                ),
              ),
              Text(
                '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.red : Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Booking Info
  Widget _buildBookingInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'รายละเอียดการจอง',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 24),
          _buildInfoRow('ตลาด', widget.booking.marketName),
          _buildInfoRow('โซน', widget.booking.zoneName),
          _buildInfoRow(
            'วันที่',
            DateFormat('d MMMM yyyy').format(widget.booking.bookingDate),
          ),
          _buildInfoRow('เวลา', widget.booking.timeSlot),
          _buildInfoRow('จำนวนสัตว์', '${widget.booking.totalQuantity} ตัว'),
          if (widget.booking.queueNumber != null)
            _buildInfoRow('คิวที่', widget.booking.queueNumber.toString()),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  /// QR Code
  Widget _buildQRCode() {
    if (_qrData == null) {
      return const CircularProgressIndicator();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'สแกนเพื่อชำระเงิน',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // PromptPay QR Code from URL
          Image.network(
            _qrData!,
            width: 280,
            height: 280,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 280,
                height: 280,
                child: Center(child: CircularProgressIndicator()),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 280,
                height: 280,
                color: Colors.grey[200],
                child: const Center(
                  child: Icon(Icons.error, size: 64, color: Colors.red),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 24, color: Color(0xFF228B22)),
              SizedBox(width: 8),
              Text(
                'PromptPay QR',
                style: TextStyle(fontSize: 18, color: Color(0xFF228B22)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Amount
  Widget _buildAmount() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        children: [
          const Text(
            'ยอดชำระ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${PriceFormatter.formatNumber(widget.booking.totalFee)} บาท',
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDAA520),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ค่าธรรมเนียมพื้นฐาน ${PriceFormatter.formatNumber(widget.booking.baseFee)} + โซน ${PriceFormatter.formatNumber(widget.booking.zoneFee)}',
            style: TextStyle(fontSize: 16, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  /// Instructions
  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text(
                'วิธีชำระเงิน',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStep('1', 'เปิดแอพธนาคารของคุณ'),
          _buildStep('2', 'สแกน QR Code ด้านบน'),
          _buildStep('3', 'ตรวจสอบยอดเงินให้ถูกต้อง'),
          _buildStep('4', 'ยืนยันการชำระเงิน'),
          _buildStep('5', 'กดปุ่ม "ยืนยันการชำระ" ด้านล่าง'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(text, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }

  /// Confirm Button
  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _confirmPayment,
        icon: _isProcessing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle, size: 28),
        label: Text(
          _isProcessing ? 'กำลังตรวจสอบ...' : 'ยืนยันการชำระ',
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF228B22),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Cancel Button
  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _isProcessing ? null : _cancelBooking,
        icon: const Icon(Icons.cancel, size: 24),
        label: const Text('ยกเลิกการจอง', style: TextStyle(fontSize: 20)),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 20),
          side: const BorderSide(color: Colors.red, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  /// Expired View
  Widget _buildExpired() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer_off, size: 120, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'หมดเวลาชำระเงิน',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'การจองหมดอายุแล้ว กรุณาจองใหม่อีกครั้ง',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 24),
              label: const Text('กลับ', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ยืนยันการชำระ
  Future<void> _confirmPayment() async {
    setState(() => _isProcessing = true);

    try {
      final bookingProvider = context.read<BookingProvider>();
      
      // TODO: In production, verify payment with bank API
      // For now, just update status
      final success = await bookingProvider.confirmPayment(widget.booking.id);

      if (success && mounted) {
        showSuccessSnackBar(context, 'ชำระเงินสำเร็จ! รอการยืนยันจากตลาด');
        
        // Navigate back to bookings
        Navigator.pop(context, true);
      } else {
        throw Exception('ไม่สามารถยืนยันการชำระได้');
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'เกิดข้อผิดพลาด: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// ยกเลิกการจอง
  Future<void> _cancelBooking() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก', style: TextStyle(fontSize: 24)),
        content: const Text(
          'คุณต้องการยกเลิกการจองนี้หรือไม่?',
          style: TextStyle(fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไม่', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('ใช่, ยกเลิก', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      setState(() => _isProcessing = true);

      try {
        final bookingProvider = context.read<BookingProvider>();
        final success = await bookingProvider.cancelBooking(
          widget.booking.id,
          'ยกเลิกจากหน้าชำระเงิน',
        );

        if (success && mounted) {
          showSuccessSnackBar(context, 'ยกเลิกการจองเรียบร้อย');
          Navigator.pop(context, false);
        }
      } catch (e) {
        if (mounted) {
          showErrorSnackBar(context, 'เกิดข้อผิดพลาด: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
  }
}
