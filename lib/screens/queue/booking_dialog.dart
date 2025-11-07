import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../utils/price_formatter.dart';
import '../../models/market.dart';
import '../../models/market_zone.dart';
import '../../models/market_booking.dart';
import '../../models/booking_item.dart';
import '../../models/livestock.dart';
import '../../providers/booking_provider.dart';
import '../../providers/livestock_provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/snackbar_helper.dart';

/// Dialog สำหรับจองคิวตลาดนัด
class BookingDialog extends StatefulWidget {
  final Market market;

  const BookingDialog({
    super.key,
    required this.market,
  });

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  // Selected values
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  MarketZone? _selectedZone;
  final List<Livestock> _selectedLivestock = [];

  // Loading state
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Default: เลือกโซนแรก
    if (widget.market.zones.isNotEmpty) {
      _selectedZone = widget.market.zones.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Market Info
                    _buildMarketInfo(),

                    const SizedBox(height: 24),

                    // 1. Select Date
                    _buildDateSelector(),

                    const SizedBox(height: 20),

                    // 2. Select Time Slot
                    if (_selectedDate != null) ...[
                      _buildTimeSlotSelector(),
                      const SizedBox(height: 20),
                    ],

                    // 3. Select Zone
                    _buildZoneSelector(),

                    const SizedBox(height: 20),

                    // 4. Select Livestock
                    _buildLivestockSelector(),

                    const SizedBox(height: 24),

                    // Fee Summary
                    if (_selectedZone != null && _selectedLivestock.isNotEmpty)
                      _buildFeeSummary(),
                  ],
                ),
              ),
            ),

            // Footer Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF228B22),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'จองคิวตลาดนัด',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  /// Market Info
  Widget _buildMarketInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF228B22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.store, size: 32, color: Color(0xFF228B22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.market.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.market.location,
                        style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Date Selector
  Widget _buildDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '1. เลือกวันที่',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _showDatePicker,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 24),
                const SizedBox(width: 12),
                Text(
                  _selectedDate == null
                      ? 'เลือกวันที่...'
                      : DateFormat('d MMMM yyyy').format(_selectedDate!),
                  style: TextStyle(
                    fontSize: 18,
                    color: _selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Time Slot Selector
  Widget _buildTimeSlotSelector() {
    final dayOfWeek = _getDayOfWeek(_selectedDate!);
    final schedule = widget.market.schedules[dayOfWeek];

    if (schedule == null || !schedule.isOpen) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'ตลาดปิดในวันนี้',
                style: TextStyle(fontSize: 18, color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. เลือกช่วงเวลา',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: schedule.timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return ChoiceChip(
              label: Text(
                slot,
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
              selected: isSelected,
              selectedColor: const Color(0xFF228B22),
              backgroundColor: Colors.grey[200],
              onSelected: (selected) {
                setState(() {
                  _selectedTimeSlot = selected ? slot : null;
                });
              },
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Zone Selector
  Widget _buildZoneSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '3. เลือกโซน',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...widget.market.zones.map((zone) {
          final isSelected = _selectedZone?.id == zone.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedZone = zone;
                  // Clear livestock selection if zone changed
                  _selectedLivestock.clear();
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF228B22).withOpacity(0.1) : null,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF228B22) : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      zone.icon,
                      size: 28,
                      color: isSelected ? const Color(0xFF228B22) : Colors.grey[700],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            zone.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          if (zone.extraFee > 0)
                            Text(
                              'ค่าธรรมเนียมเพิ่ม +${PriceFormatter.formatNumber(zone.extraFee)} บาท',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle, color: Color(0xFF228B22), size: 28),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  /// Livestock Selector
  Widget _buildLivestockSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '4. เลือกสัตว์',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Consumer<LivestockProvider>(
          builder: (context, provider, _) {
            // Filter livestock by selected zone type
            final filteredLivestock = provider.livestock.where((animal) {
              if (_selectedZone == null) return false;
              return animal.type.displayName.toLowerCase().contains(_selectedZone!.livestockType.toLowerCase());
            }).toList();

            if (filteredLivestock.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'ไม่มีสัตว์ประเภท ${_selectedZone?.livestockType ?? ""} ในฟาร์ม',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              );
            }

            return Column(
              children: filteredLivestock.map((animal) {
                final isSelected = _selectedLivestock.contains(animal);
                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedLivestock.add(animal);
                      } else {
                        _selectedLivestock.remove(animal);
                      }
                    });
                  },
                  title: Text(
                    '${animal.type.displayName} - ${animal.earTag ?? animal.id}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  subtitle: Text(
                    'น้ำหนัก: ${animal.weight?.toStringAsFixed(0) ?? '0'} กก.',
                    style: const TextStyle(fontSize: 16),
                  ),
                  activeColor: const Color(0xFF228B22),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  tileColor: isSelected ? const Color(0xFF228B22).withOpacity(0.1) : null,
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  /// Fee Summary
  Widget _buildFeeSummary() {
    final baseFee = widget.market.baseFee;
    final zoneFee = _selectedZone?.extraFee ?? 0;
    final totalFee = baseFee + zoneFee;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'สรุปค่าธรรมเนียม',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ค่าธรรมเนียมพื้นฐาน', style: TextStyle(fontSize: 18)),
              Text(
                '${PriceFormatter.formatNumber(baseFee)} บาท',
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          if (zoneFee > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('โซน ${_selectedZone?.code}', style: const TextStyle(fontSize: 18)),
                Text(
                  '+${PriceFormatter.formatNumber(zoneFee)} บาท',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ],
          const Divider(height: 24, thickness: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'รวมทั้งหมด',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              Text(
                '${PriceFormatter.formatNumber(totalFee)} บาท',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFDAA520),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Actions
  Widget _buildActions() {
    final canSubmit = _selectedDate != null &&
        _selectedTimeSlot != null &&
        _selectedZone != null &&
        _selectedLivestock.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.grey, width: 2),
              ),
              child: const Text('ยกเลิก', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: canSubmit && !_isSubmitting ? _submitBooking : null,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.check, size: 24),
              label: Text(
                _isSubmitting ? 'กำลังจอง...' : 'ยืนยันการจอง',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF228B22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                disabledBackgroundColor: Colors.grey[300],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Submit Booking
  Future<void> _submitBooking() async {
    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final bookingProvider = context.read<BookingProvider>();

      // Create booking items
      final items = _selectedLivestock.map((animal) {
        return BookingItem(
          livestockId: animal.id,
          livestockType: animal.type.displayName,
          earTag: animal.earTag ?? animal.id,
          quantity: 1,
          weight: animal.weight,
        );
      }).toList();

      // Calculate fees
      final baseFee = widget.market.baseFee;
      final zoneFee = _selectedZone!.extraFee;
      final totalFee = baseFee + zoneFee;

      // Create booking
      final booking = MarketBooking(
        id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
        farmId: 'current_farm_id',
        farmerName: authProvider.currentUser?.fullName ?? 'ชื่อเกษตรกร',
        farmerPhone: authProvider.currentUser?.phoneNumber ?? '0812345678',
        marketId: widget.market.id,
        marketName: widget.market.name,
        zoneId: _selectedZone!.id,
        zoneName: _selectedZone!.name,
        bookingDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        items: items,
        totalQuantity: items.length,
        totalWeight: items.fold<double>(0.0, (sum, item) => sum + (item.weight ?? 0.0)),
        baseFee: baseFee,
        zoneFee: zoneFee,
        totalFee: totalFee,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(minutes: 30)), // หมดอายุ 30 นาที
      );

      // Save booking
      final bookingId = await bookingProvider.createBooking(booking);

      if (bookingId != null && mounted) {
        Navigator.pop(context, true); // Return success
        
        // Navigate to payment screen using GoRouter
        context.push('/payment', extra: booking).then((paid) {
          if (paid == true) {
            // Payment successful - show success and refresh
            showSuccessSnackBar(context, 'ชำระเงินสำเร็จ!');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(context, 'เกิดข้อผิดพลาด: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  /// Show Date Picker
  Future<void> _showDatePicker() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30));

    // Find first available date (when market is open)
    DateTime findFirstAvailableDate() {
      var date = _selectedDate ?? now;
      for (int i = 0; i < 30; i++) {
        final checkDate = date.add(Duration(days: i));
        final dayOfWeek = _getDayOfWeek(checkDate);
        final schedule = widget.market.schedules[dayOfWeek];
        if (schedule != null && schedule.isOpen) {
          return checkDate;
        }
      }
      return date; // Fallback
    }

    final initialDate = findFirstAvailableDate();

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // locale: const Locale('th', 'TH'), // Removed - requires Thai localization delegates
      selectableDayPredicate: (DateTime date) {
        // Only allow days when market is open
        final dayOfWeek = _getDayOfWeek(date);
        final schedule = widget.market.schedules[dayOfWeek];
        return schedule != null && schedule.isOpen;
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF228B22),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot
      });
    }
  }

  /// Get day of week (lowercase)
  String _getDayOfWeek(DateTime date) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[date.weekday - 1];
  }
}
