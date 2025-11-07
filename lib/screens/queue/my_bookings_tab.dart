import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/price_formatter.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../models/market_booking.dart';
import '../../utils/responsive_helper.dart';
import '../../utils/snackbar_helper.dart';

/// Tab สำหรับแสดงคิวที่จองไว้
class MyBookingsTab extends StatefulWidget {
  const MyBookingsTab({super.key});

  @override
  State<MyBookingsTab> createState() => _MyBookingsTabState();
}

class _MyBookingsTabState extends State<MyBookingsTab> {
  // Status filter options
  final List<String> _statusOptions = [
    'ทั้งหมด',
    'รอชำระ',
    'ยืนยันแล้ว',
    'เสร็จสิ้น',
    'ยกเลิก',
  ];

  @override
  void initState() {
    super.initState();
    // โหลดการจองของผู้ใช้
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // TODO: Get actual farmId from auth
      context.read<BookingProvider>().loadMyBookings('current_farm_id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Status Filter
        _buildStatusFilter(),
        
        const SizedBox(height: 16),
        
        // Bookings List
        Expanded(
          child: _buildBookingsList(),
        ),
      ],
    );
  }

  /// Status Filter Chips
  Widget _buildStatusFilter() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _statusOptions.map((status) {
              final isSelected = provider.statusFilter == status;
              
              return FilterChip(
                label: Text(
                  status,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  provider.filterByStatus(status);
                },
                selectedColor: const Color(0xFF228B22),
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  /// Bookings List
  Widget _buildBookingsList() {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) {
        // Loading
        if (provider.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 5),
                SizedBox(height: 16),
                Text('กำลังโหลดคิว...', style: TextStyle(fontSize: 20)),
              ],
            ),
          );
        }

        // Error
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'เกิดข้อผิดพลาด',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  provider.error!,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final bookings = provider.filteredBookings;

        // Empty
        if (bookings.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list_alt_outlined, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  provider.statusFilter == 'ทั้งหมด'
                      ? 'คุณยังไม่มีการจอง'
                      : 'ไม่พบคิว${provider.statusFilter}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ไปที่แท็บ "ซื้อ-ขาย" เพื่อจองคิว',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        // Bookings List
        return RefreshIndicator(
          onRefresh: () => provider.loadMyBookings('current_farm_id'),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              return _buildBookingCard(bookings[index]);
            },
          ),
        );
      },
    );
  }

  /// Booking Card
  Widget _buildBookingCard(MarketBooking booking) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            Row(
              children: [
                _buildStatusBadge(booking.status),
                const Spacer(),
                Text(
                  'คิวที่: ${booking.queueNumber ?? "-"}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Market Info
            Row(
              children: [
                const Icon(Icons.store, size: 28, color: Color(0xFF228B22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.marketName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'โซน ${booking.zoneName}',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Date & Time
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 24),
                const SizedBox(width: 8),
                Text(
                  DateFormat('d MMM yyyy').format(booking.bookingDate),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.access_time, size: 24),
                const SizedBox(width: 8),
                Text(
                  booking.timeSlot,
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Livestock Items
            ...booking.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text('🐄', style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${item.livestockType} (${item.earTag})',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                    if (item.weight != null)
                      Text(
                        '${item.weight} กก.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),

            const SizedBox(height: 12),

            // Fee
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ค่าธรรมเนียม',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${PriceFormatter.formatNumber(booking.totalFee)} บาท',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFDAA520),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Actions
            _buildActions(booking),
          ],
        ),
      ),
    );
  }

  /// Status Badge
  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case BookingStatus.pending:
        color = Colors.orange;
        text = 'รอชำระ';
        icon = Icons.pending;
        break;
      case BookingStatus.confirmed:
        color = Colors.green;
        text = 'ยืนยันแล้ว';
        icon = Icons.check_circle;
        break;
      case BookingStatus.checked_in:
        color = Colors.blue;
        text = 'เช็คอินแล้ว';
        icon = Icons.how_to_reg;
        break;
      case BookingStatus.completed:
        color = Colors.teal;
        text = 'เสร็จสิ้น';
        icon = Icons.done_all;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        text = 'ยกเลิก';
        icon = Icons.cancel;
        break;
      case BookingStatus.no_show:
        color = Colors.grey;
        text = 'ไม่มา';
        icon = Icons.person_off;
        break;
      case BookingStatus.expired:
        color = Colors.grey;
        text = 'หมดอายุ';
        icon = Icons.timer_off;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Action Buttons
  Widget _buildActions(MarketBooking booking) {
    if (booking.status == BookingStatus.pending) {
      // รอชำระ: แสดงปุ่มชำระเงิน
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Navigate to payment screen
            print('ชำระเงิน: ${booking.id}');
          },
          icon: const Icon(Icons.payment, size: 24),
          label: const Text(
            'ชำระเงิน',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDAA520),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
      );
    }

    if (booking.status == BookingStatus.confirmed) {
      // ยืนยันแล้ว: แสดงปุ่มดูแผนที่ และยกเลิก (ถ้ายังยกเลิกได้)
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Open map
                print('ดูแผนที่: ${booking.marketId}');
              },
              icon: const Icon(Icons.map, size: 24),
              label: const Text('แผนที่', style: TextStyle(fontSize: 18)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF228B22), width: 2),
              ),
            ),
          ),
          if (booking.canCancel) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showCancelDialog(booking),
                icon: const Icon(Icons.cancel, size: 24),
                label: const Text('ยกเลิก', style: TextStyle(fontSize: 18)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        ],
      );
    }

    // สถานะอื่น ๆ: ไม่แสดงปุ่ม
    return const SizedBox.shrink();
  }

  /// Cancel Dialog
  void _showCancelDialog(MarketBooking booking) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ยืนยันการยกเลิก', style: TextStyle(fontSize: 24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'คุณต้องการยกเลิกคิว ${booking.queueNumber} หรือไม่?',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'เหตุผลการยกเลิก',
                border: OutlineInputBorder(),
                hintText: 'ระบุเหตุผล (ถ้ามี)',
              ),
              maxLines: 3,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ย้อนกลับ', style: TextStyle(fontSize: 20)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final reason = reasonController.text.isEmpty
                  ? 'ไม่ระบุเหตุผล'
                  : reasonController.text;
              
              final success = await context
                  .read<BookingProvider>()
                  .cancelBooking(booking.id, reason);
              
              if (success && mounted) {
                showSuccessSnackBar(context, 'ยกเลิกคิวเรียบร้อย');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('ยืนยันยกเลิก', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
