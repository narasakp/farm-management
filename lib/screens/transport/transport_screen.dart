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
    final formKey = GlobalKey<FormState>();
    final licensePlateController = TextEditingController();
    final brandController = TextEditingController();
    final modelController = TextEditingController();
    final driverNameController = TextEditingController();
    final driverPhoneController = TextEditingController();
    final maxWeightController = TextEditingController();
    final maxAnimalsController = TextEditingController();
    final pricePerKmController = TextEditingController();
    final pricePerAnimalController = TextEditingController();
    
    String vehicleType = 'truck';
    List<String> selectedAnimalTypes = ['cattle'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('เพิ่มรถขนส่ง'),
          content: SizedBox(
            width: 500,
            height: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: vehicleType,
                      decoration: const InputDecoration(
                        labelText: 'ประเภทรถ',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'truck', child: Text('รถบรรทุก')),
                        DropdownMenuItem(value: 'trailer', child: Text('รถพ่วง')),
                        DropdownMenuItem(value: 'pickup', child: Text('รถกระบะ')),
                      ],
                      onChanged: (value) => setState(() => vehicleType = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: licensePlateController,
                      decoration: const InputDecoration(
                        labelText: 'ทะเบียนรถ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่ทะเบียนรถ' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: brandController,
                            decoration: const InputDecoration(
                              labelText: 'ยี่ห้อ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: modelController,
                            decoration: const InputDecoration(
                              labelText: 'รุ่น',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อคนขับ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่ชื่อคนขับ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรคนขับ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่เบอร์โทร' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: maxWeightController,
                            decoration: const InputDecoration(
                              labelText: 'น้ำหนักสูงสุด (กก.)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่น้ำหนัก';
                              if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: maxAnimalsController,
                            decoration: const InputDecoration(
                              labelText: 'จำนวนสูงสุด (ตัว)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่จำนวน';
                              if (int.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pricePerKmController,
                            decoration: const InputDecoration(
                              labelText: 'ราคา/กม. (บาท)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                              if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: pricePerAnimalController,
                            decoration: const InputDecoration(
                              labelText: 'ราคา/ตัว (บาท)',
                              border: OutlineInputBorder(),
                              hintText: 'ถ้ามี',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('ประเภทสัตว์ที่รับขนส่ง:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      children: ['cattle', 'buffalo', 'pig', 'chicken', 'duck', 'goat', 'sheep']
                          .map((type) => CheckboxListTile(
                                title: Text(_getAnimalTypeDisplayName(type)),
                                value: selectedAnimalTypes.contains(type),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedAnimalTypes.add(type);
                                    } else {
                                      selectedAnimalTypes.remove(type);
                                    }
                                  });
                                },
                                dense: true,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedAnimalTypes.isNotEmpty) {
                  final vehicle = TransportVehicle(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    ownerId: 'current_user_farm',
                    vehicleType: vehicleType,
                    licensePlate: licensePlateController.text,
                    brand: brandController.text.isNotEmpty ? brandController.text : null,
                    model: modelController.text.isNotEmpty ? modelController.text : null,
                    driverName: driverNameController.text,
                    driverPhone: driverPhoneController.text,
                    maxCapacityWeight: double.parse(maxWeightController.text),
                    maxCapacityAnimals: int.parse(maxAnimalsController.text),
                    pricePerKm: double.parse(pricePerKmController.text),
                    pricePerAnimal: pricePerAnimalController.text.isNotEmpty 
                        ? double.parse(pricePerAnimalController.text) 
                        : null,
                    suitableAnimalTypes: selectedAnimalTypes,
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  context.read<TransportProvider>().addVehicle(vehicle);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เพิ่มรถขนส่งเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDialog(TransportVehicle vehicle) {
    final formKey = GlobalKey<FormState>();
    final pickupController = TextEditingController();
    final deliveryController = TextEditingController();
    final animalCountController = TextEditingController();
    final totalWeightController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    String selectedTime = '08:00';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('จองรถ ${vehicle.licensePlate}'),
          content: SizedBox(
            width: 400,
            height: 500,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: pickupController,
                      decoration: const InputDecoration(
                        labelText: 'จุดรับ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่จุดรับ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: deliveryController,
                      decoration: const InputDecoration(
                        labelText: 'จุดส่ง',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่จุดส่ง' : null,
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text('วันที่: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 30)),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: selectedTime,
                      decoration: const InputDecoration(
                        labelText: 'เวลา',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: '06:00', child: Text('06:00')),
                        DropdownMenuItem(value: '08:00', child: Text('08:00')),
                        DropdownMenuItem(value: '10:00', child: Text('10:00')),
                        DropdownMenuItem(value: '14:00', child: Text('14:00')),
                        DropdownMenuItem(value: '16:00', child: Text('16:00')),
                      ],
                      onChanged: (value) => selectedTime = value!,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: animalCountController,
                            decoration: const InputDecoration(
                              labelText: 'จำนวนสัตว์',
                              border: OutlineInputBorder(),
                              suffixText: 'ตัว',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่จำนวน';
                              final count = int.tryParse(value!);
                              if (count == null) return 'กรุณาใส่ตัวเลข';
                              if (count > vehicle.maxCapacityAnimals) return 'เกินจำนวนที่รับได้';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: totalWeightController,
                            decoration: const InputDecoration(
                              labelText: 'น้ำหนักรวม',
                              border: OutlineInputBorder(),
                              suffixText: 'กก.',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่น้ำหนัก';
                              final weight = double.tryParse(value!);
                              if (weight == null) return 'กรุณาใส่ตัวเลข';
                              if (weight > vehicle.maxCapacityWeight) return 'เกินน้ำหนักที่รับได้';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'หมายเหตุ',
                        border: OutlineInputBorder(),
                        hintText: 'ข้อมูลเพิ่มเติม (ถ้ามี)',
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        children: [
                          Text('ค่าประมาณ: ฿${(50 * vehicle.pricePerKm).toStringAsFixed(0)}', 
                               style: const TextStyle(fontWeight: FontWeight.bold)),
                          const Text('(ระยะทางประมาณ 50 กม.)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final booking = TransportBooking(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    farmId: 'current_user_farm',
                    vehicleId: vehicle.id,
                    pickupLocation: pickupController.text,
                    deliveryLocation: deliveryController.text,
                    scheduledDate: selectedDate,
                    scheduledTime: selectedTime != null ? DateTime.tryParse('2024-01-01 $selectedTime:00') : null,
                    items: [
                      TransportItem(
                        livestockId: 'livestock_${DateTime.now().millisecondsSinceEpoch}',
                        animalType: 'ปศุสัตว์',
                        quantity: int.parse(animalCountController.text),
                        weight: double.parse(totalWeightController.text),
                        notes: notesController.text.isNotEmpty ? notesController.text : null,
                      ),
                    ],
                    totalWeight: double.parse(totalWeightController.text),
                    totalAnimals: int.parse(animalCountController.text),
                    estimatedDistance: 50.0,
                    estimatedCost: 50 * vehicle.pricePerKm,
                    status: 'pending',
                    specialInstructions: notesController.text.isNotEmpty ? notesController.text : null,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  
                  context.read<TransportProvider>().bookTransport(booking);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('จองรถขนส่งเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('จอง'),
            ),
          ],
        ),
      ),
    );
  }

  void _editVehicle(TransportVehicle vehicle) {
    final formKey = GlobalKey<FormState>();
    final licensePlateController = TextEditingController(text: vehicle.licensePlate);
    final brandController = TextEditingController(text: vehicle.brand ?? '');
    final modelController = TextEditingController(text: vehicle.model ?? '');
    final driverNameController = TextEditingController(text: vehicle.driverName);
    final driverPhoneController = TextEditingController(text: vehicle.driverPhone);
    final maxWeightController = TextEditingController(text: vehicle.maxCapacityWeight.toString());
    final maxAnimalsController = TextEditingController(text: vehicle.maxCapacityAnimals.toString());
    final pricePerKmController = TextEditingController(text: vehicle.pricePerKm.toString());
    final pricePerAnimalController = TextEditingController(text: vehicle.pricePerAnimal?.toString() ?? '');
    
    String vehicleType = vehicle.vehicleType;
    List<String> selectedAnimalTypes = List.from(vehicle.suitableAnimalTypes);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('แก้ไขรถขนส่ง'),
          content: SizedBox(
            width: 500,
            height: 600,
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: vehicleType,
                      decoration: const InputDecoration(
                        labelText: 'ประเภทรถ',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'truck', child: Text('รถบรรทุก')),
                        DropdownMenuItem(value: 'trailer', child: Text('รถพ่วง')),
                        DropdownMenuItem(value: 'pickup', child: Text('รถกระบะ')),
                      ],
                      onChanged: (value) => setState(() => vehicleType = value!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: licensePlateController,
                      decoration: const InputDecoration(
                        labelText: 'ทะเบียนรถ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่ทะเบียนรถ' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: brandController,
                            decoration: const InputDecoration(
                              labelText: 'ยี่ห้อ',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: modelController,
                            decoration: const InputDecoration(
                              labelText: 'รุ่น',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverNameController,
                      decoration: const InputDecoration(
                        labelText: 'ชื่อคนขับ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่ชื่อคนขับ' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: driverPhoneController,
                      decoration: const InputDecoration(
                        labelText: 'เบอร์โทรคนขับ',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value?.isEmpty ?? true ? 'กรุณาใส่เบอร์โทร' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: maxWeightController,
                            decoration: const InputDecoration(
                              labelText: 'น้ำหนักสูงสุด (กก.)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่น้ำหนัก';
                              if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: maxAnimalsController,
                            decoration: const InputDecoration(
                              labelText: 'จำนวนสูงสุด (ตัว)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่จำนวน';
                              if (int.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: pricePerKmController,
                            decoration: const InputDecoration(
                              labelText: 'ราคา/กม. (บาท)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value?.isEmpty ?? true) return 'กรุณาใส่ราคา';
                              if (double.tryParse(value!) == null) return 'กรุณาใส่ตัวเลข';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: pricePerAnimalController,
                            decoration: const InputDecoration(
                              labelText: 'ราคา/ตัว (บาท)',
                              border: OutlineInputBorder(),
                              hintText: 'ถ้ามี',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('ประเภทสัตว์ที่รับขนส่ง:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      children: ['cattle', 'buffalo', 'pig', 'chicken', 'duck', 'goat', 'sheep']
                          .map((type) => CheckboxListTile(
                                title: Text(_getAnimalTypeDisplayName(type)),
                                value: selectedAnimalTypes.contains(type),
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedAnimalTypes.add(type);
                                    } else {
                                      selectedAnimalTypes.remove(type);
                                    }
                                  });
                                },
                                dense: true,
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedAnimalTypes.isNotEmpty) {
                  final updatedVehicle = TransportVehicle(
                    id: vehicle.id,
                    ownerId: vehicle.ownerId,
                    vehicleType: vehicleType,
                    licensePlate: licensePlateController.text,
                    brand: brandController.text.isNotEmpty ? brandController.text : null,
                    model: modelController.text.isNotEmpty ? modelController.text : null,
                    driverName: driverNameController.text,
                    driverPhone: driverPhoneController.text,
                    maxCapacityWeight: double.parse(maxWeightController.text),
                    maxCapacityAnimals: int.parse(maxAnimalsController.text),
                    pricePerKm: double.parse(pricePerKmController.text),
                    pricePerAnimal: pricePerAnimalController.text.isNotEmpty 
                        ? double.parse(pricePerAnimalController.text) 
                        : null,
                    suitableAnimalTypes: selectedAnimalTypes,
                    isActive: vehicle.isActive,
                    createdAt: vehicle.createdAt,
                    updatedAt: DateTime.now(),
                  );
                  
                  context.read<TransportProvider>().updateVehicle(updatedVehicle);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('แก้ไขรถขนส่งเรียบร้อยแล้ว')),
                  );
                }
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('การจอง #${booking.id.substring(0, 8)}', 
                 style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text('จุดรับ: ${booking.pickupLocation}')),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.flag, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text('จุดส่ง: ${booking.deliveryLocation}')),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text('สถานะ: กำลังขนส่ง'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.orange),
                      const SizedBox(width: 8),
                      const Text('เวลาโดยประมาณ: 2 ชั่วโมง'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.phone, color: Colors.green),
                      const SizedBox(width: 8),
                      const Text('คนขับ: 044-123-456'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('หมายเหตุ: ระบบ GPS Tracking จะพัฒนาในเวอร์ชันถัดไป', 
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('เปิดแอปโทรศัพท์')),
              );
            },
            icon: const Icon(Icons.phone),
            label: const Text('โทรคนขับ'),
          ),
        ],
      ),
    );
  }
}
