import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transport_provider.dart';
import '../../models/transportation.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().loadTransportData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ขนส่งและโลจิสติกส์'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'จองรถ', icon: Icon(Icons.local_shipping)),
            Tab(text: 'รถของฉัน', icon: Icon(Icons.directions_car)),
            Tab(text: 'ประวัติ', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingTab(),
          _buildMyVehiclesTab(),
          _buildHistoryTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddVehicleDialog,
        child: const Icon(Icons.add),
        tooltip: 'เพิ่มรถขนส่ง',
      ),
    );
  }

  Widget _buildBookingTab() {
    return Consumer<TransportProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final availableVehicles = provider.availableVehicles;

        if (availableVehicles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่มีรถขนส่งที่ว่าง'),
                SizedBox(height: 8),
                Text('กรุณาลองใหม่ในภายหลัง'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: availableVehicles.length,
          itemBuilder: (context, index) {
            return _buildVehicleCard(availableVehicles[index], isBooking: true);
          },
        );
      },
    );
  }

  Widget _buildMyVehiclesTab() {
    return Consumer<TransportProvider>(
      builder: (context, provider, child) {
        final myVehicles = provider.myVehicles;

        if (myVehicles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('คุณยังไม่มีรถขนส่ง'),
                SizedBox(height: 8),
                Text('กดปุ่ม + เพื่อเพิ่มรถขนส่ง'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: myVehicles.length,
          itemBuilder: (context, index) {
            return _buildVehicleCard(myVehicles[index], isOwner: true);
          },
        );
      },
    );
  }

  Widget _buildHistoryTab() {
    return Consumer<TransportProvider>(
      builder: (context, provider, child) {
        final bookings = provider.transportBookings;

        if (bookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('ไม่มีประวัติการขนส่ง'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            return _buildBookingCard(bookings[index]);
          },
        );
      },
    );
  }

  Widget _buildVehicleCard(TransportVehicle vehicle, {bool isBooking = false, bool isOwner = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    _getVehicleIcon(vehicle.vehicleType),
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${vehicle.brand ?? ''} ${vehicle.model ?? ''}'.trim().isEmpty 
                            ? vehicle.vehicleType 
                            : '${vehicle.brand} ${vehicle.model}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ทะเบียน: ${vehicle.licensePlate}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (!vehicle.isActive)
                  Chip(
                    label: const Text('ไม่ว่าง', style: TextStyle(fontSize: 12)),
                    backgroundColor: Colors.red.shade50,
                    side: BorderSide(color: Colors.red.shade300),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ความจุ: ${vehicle.maxCapacityWeight.toInt()} กก.'),
                      Text('จำนวน: ${vehicle.maxCapacityAnimals} ตัว'),
                      Text('คนขับ: ${vehicle.driverName}'),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '฿${vehicle.pricePerKm}/กม.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade700,
                      ),
                    ),
                    if (vehicle.pricePerAnimal != null)
                      Text(
                        '฿${vehicle.pricePerAnimal}/ตัว',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 4,
              children: vehicle.suitableAnimalTypes.map((type) => Chip(
                label: Text(_getAnimalTypeDisplayName(type), style: const TextStyle(fontSize: 10)),
                backgroundColor: Colors.green.shade50,
              )).toList(),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(vehicle.driverPhone, style: TextStyle(color: Colors.grey[600])),
                const Spacer(),
                if (isBooking && vehicle.isActive)
                  ElevatedButton(
                    onPressed: () => _showBookingDialog(vehicle),
                    child: const Text('จอง'),
                  )
                else if (isOwner) ...[
                  TextButton(
                    onPressed: () => _editVehicle(vehicle),
                    child: const Text('แก้ไข'),
                  ),
                  TextButton(
                    onPressed: () => _toggleVehicleStatus(vehicle),
                    child: Text(vehicle.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCard(TransportBooking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'การจอง #${booking.id.substring(0, 8)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${booking.pickupLocation} → ${booking.deliveryLocation}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${booking.scheduledDate.day}/${booking.scheduledDate.month}/${booking.scheduledDate.year}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  '฿${booking.estimatedCost.toStringAsFixed(0)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'สัตว์: ${booking.totalAnimals} ตัว (${booking.totalWeight.toInt()} กก.)',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (booking.status == 'in_transit') ...[
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => _trackBooking(booking),
                icon: const Icon(Icons.gps_fixed),
                label: const Text('ติดตามการขนส่ง'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'รอยืนยัน';
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'ยืนยันแล้ว';
        break;
      case 'in_transit':
        color = Colors.purple;
        text = 'กำลังขนส่ง';
        break;
      case 'delivered':
        color = Colors.green;
        text = 'ส่งแล้ว';
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'ยกเลิก';
        break;
      default:
        color = Colors.grey;
        text = status;
    }
    
    return Chip(
      label: Text(text, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  IconData _getVehicleIcon(String vehicleType) {
    switch (vehicleType) {
      case 'truck':
        return Icons.local_shipping;
      case 'trailer':
        return Icons.rv_hookup;
      case 'pickup':
        return Icons.directions_car;
      default:
        return Icons.local_shipping;
    }
  }

  String _getAnimalTypeDisplayName(String type) {
    switch (type) {
      case 'cattle':
        return 'โค';
      case 'buffalo':
        return 'กระบือ';
      case 'pig':
        return 'สุกร';
      case 'chicken':
        return 'ไก่';
      case 'duck':
        return 'เป็ด';
      case 'goat':
        return 'แพะ';
      case 'sheep':
        return 'แกะ';
      default:
        return type;
    }
  }

  void _showAddVehicleDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มรถขนส่ง'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showBookingDialog(TransportVehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('จองรถ ${vehicle.licensePlate}'),
        content: const Text('ฟีเจอร์นี้กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('จอง'),
          ),
        ],
      ),
    );
  }

  void _editVehicle(TransportVehicle vehicle) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ฟีเจอร์แก้ไขรถขนส่งกำลังพัฒนา')),
    );
  }

  void _toggleVehicleStatus(TransportVehicle vehicle) {
    context.read<TransportProvider>().toggleVehicleStatus(vehicle.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(vehicle.isActive ? 'ปิดใช้งานรถแล้ว' : 'เปิดใช้งานรถแล้ว'),
      ),
    );
  }

  void _trackBooking(TransportBooking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ติดตามการขนส่ง'),
        content: const Text('ฟีเจอร์ GPS Tracking กำลังพัฒนา'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }
}
