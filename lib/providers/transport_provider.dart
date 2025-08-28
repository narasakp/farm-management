import 'package:flutter/foundation.dart';
import '../models/transportation.dart';

class TransportProvider with ChangeNotifier {
  List<TransportVehicle> _vehicles = [];
  List<TransportBooking> _bookings = [];
  List<TransportLog> _transportLogs = [];
  bool _isLoading = false;

  List<TransportVehicle> get vehicles => _vehicles;
  List<TransportBooking> get transportBookings => _bookings;
  List<TransportLog> get transportLogs => _transportLogs;
  bool get isLoading => _isLoading;

  List<TransportVehicle> get availableVehicles {
    return _vehicles.where((vehicle) => vehicle.isActive).toList();
  }

  List<TransportVehicle> get myVehicles {
    // TODO: Filter by current user
    return _vehicles.where((vehicle) => vehicle.ownerId == 'current_user').toList();
  }

  Future<void> loadTransportData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _vehicles = [
        TransportVehicle(
          id: '1',
          ownerId: 'owner1',
          vehicleType: 'truck',
          licensePlate: 'กข-1234',
          brand: 'Isuzu',
          model: 'D-Max',
          year: 2020,
          maxCapacityWeight: 1000,
          maxCapacityAnimals: 10,
          suitableAnimalTypes: ['cattle', 'buffalo'],
          driverName: 'สมชาย ใจดี',
          driverPhone: '081-234-5678',
          driverLicense: 'DL123456',
          isActive: true,
          pricePerKm: 15,
          pricePerAnimal: 200,
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        TransportVehicle(
          id: '2',
          ownerId: 'owner2',
          vehicleType: 'pickup',
          licensePlate: 'คง-5678',
          brand: 'Toyota',
          model: 'Hilux',
          year: 2019,
          maxCapacityWeight: 500,
          maxCapacityAnimals: 5,
          suitableAnimalTypes: ['pig', 'goat', 'sheep'],
          driverName: 'สมหญิง รักษ์ดี',
          driverPhone: '082-345-6789',
          isActive: true,
          pricePerKm: 12,
          pricePerAnimal: 150,
          createdAt: DateTime.now().subtract(const Duration(days: 20)),
          updatedAt: DateTime.now(),
        ),
        TransportVehicle(
          id: '3',
          ownerId: 'current_user',
          vehicleType: 'truck',
          licensePlate: 'จฉ-9012',
          brand: 'Mitsubishi',
          model: 'Fuso',
          year: 2021,
          maxCapacityWeight: 2000,
          maxCapacityAnimals: 20,
          suitableAnimalTypes: ['cattle', 'buffalo', 'pig'],
          driverName: 'สมศักดิ์ ขยันดี',
          driverPhone: '083-456-7890',
          isActive: false,
          pricePerKm: 20,
          pricePerAnimal: 250,
          notes: 'รถใหญ่ เหมาะสำหรับขนส่งระยะไกล',
          createdAt: DateTime.now().subtract(const Duration(days: 10)),
          updatedAt: DateTime.now(),
        ),
      ];

      _bookings = [
        TransportBooking(
          id: '1',
          farmId: 'farm1',
          vehicleId: '1',
          pickupLocation: 'ฟาร์มโคนม บ้านหนองบัว',
          deliveryLocation: 'ตลาดโค เนินสง่า',
          scheduledDate: DateTime.now().add(const Duration(days: 2)),
          items: [
            TransportItem(
              livestockId: 'cattle001',
              animalType: 'cattle',
              quantity: 2,
              weight: 900,
              notes: 'โคเนื้อพร้อมขาย',
            ),
          ],
          totalWeight: 900,
          totalAnimals: 2,
          estimatedDistance: 25,
          estimatedCost: 775, // 25km * 15 + 2 * 200
          status: 'confirmed',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
        ),
        TransportBooking(
          id: '2',
          farmId: 'farm2',
          vehicleId: '2',
          pickupLocation: 'ฟาร์มสุกร บ้านโนนสวรรค์',
          deliveryLocation: 'โรงฆ่าสุกร อำเภอเมือง',
          scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
          items: [
            TransportItem(
              livestockId: 'pig001',
              animalType: 'pig',
              quantity: 5,
              weight: 400,
              notes: 'สุกรขุนพร้อมขาย',
            ),
          ],
          totalWeight: 400,
          totalAnimals: 5,
          estimatedDistance: 18,
          estimatedCost: 966, // 18km * 12 + 5 * 150
          actualCost: 950,
          status: 'delivered',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];

    } catch (e) {
      debugPrint('Error loading transport data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addVehicle(TransportVehicle vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _vehicles.add(vehicle);
    } catch (e) {
      throw Exception('เพิ่มรถขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateVehicle(TransportVehicle vehicle) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _vehicles.indexWhere((v) => v.id == vehicle.id);
      if (index != -1) {
        _vehicles[index] = vehicle;
      }
    } catch (e) {
      throw Exception('อัปเดตรถขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleVehicleStatus(String vehicleId) async {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      final vehicle = _vehicles[index];
      _vehicles[index] = TransportVehicle(
        id: vehicle.id,
        ownerId: vehicle.ownerId,
        vehicleType: vehicle.vehicleType,
        licensePlate: vehicle.licensePlate,
        brand: vehicle.brand,
        model: vehicle.model,
        year: vehicle.year,
        maxCapacityWeight: vehicle.maxCapacityWeight,
        maxCapacityAnimals: vehicle.maxCapacityAnimals,
        suitableAnimalTypes: vehicle.suitableAnimalTypes,
        driverName: vehicle.driverName,
        driverPhone: vehicle.driverPhone,
        driverLicense: vehicle.driverLicense,
        isActive: !vehicle.isActive,
        pricePerKm: vehicle.pricePerKm,
        pricePerAnimal: vehicle.pricePerAnimal,
        notes: vehicle.notes,
        createdAt: vehicle.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> createBooking(TransportBooking booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      _bookings.add(booking);
    } catch (e) {
      throw Exception('จองรถขนส่งไม่สำเร็จ: ${e.toString()}');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBookingStatus(String bookingId, String status) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _bookings[index];
      _bookings[index] = TransportBooking(
        id: booking.id,
        farmId: booking.farmId,
        vehicleId: booking.vehicleId,
        pickupLocation: booking.pickupLocation,
        deliveryLocation: booking.deliveryLocation,
        scheduledDate: booking.scheduledDate,
        scheduledTime: booking.scheduledTime,
        items: booking.items,
        totalWeight: booking.totalWeight,
        totalAnimals: booking.totalAnimals,
        estimatedDistance: booking.estimatedDistance,
        estimatedCost: booking.estimatedCost,
        actualCost: booking.actualCost,
        status: status,
        specialInstructions: booking.specialInstructions,
        createdAt: booking.createdAt,
        updatedAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  Future<void> addTransportLog(TransportLog log) async {
    _transportLogs.add(log);
    notifyListeners();
  }

  List<TransportLog> getLogsForBooking(String bookingId) {
    return _transportLogs.where((log) => log.bookingId == bookingId).toList();
  }

  List<TransportBooking> getBookingsForFarm(String farmId) {
    return _bookings.where((booking) => booking.farmId == farmId).toList();
  }

  List<TransportBooking> getBookingsForVehicle(String vehicleId) {
    return _bookings.where((booking) => booking.vehicleId == vehicleId).toList();
  }

  double calculateTransportCost(TransportVehicle vehicle, double distance, int animalCount) {
    double cost = distance * vehicle.pricePerKm;
    if (vehicle.pricePerAnimal != null) {
      cost += animalCount * vehicle.pricePerAnimal!;
    }
    return cost;
  }
}
