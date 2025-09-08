import 'package:flutter/foundation.dart';
import '../models/gps_location.dart';

class GPSProvider with ChangeNotifier {
  List<LocationTrack> _tracks = [];
  GPSLocation? _currentLocation;
  bool _isTracking = false;
  bool _isLoading = false;
  String? _error;

  List<LocationTrack> get tracks => _tracks;
  GPSLocation? get currentLocation => _currentLocation;
  bool get isTracking => _isTracking;
  bool get isLoading => _isLoading;
  String? get error => _error;

  GPSProvider() {
    _loadSampleData();
  }

  void _loadSampleData() {
    final now = DateTime.now();
    
    _tracks = [
      LocationTrack(
        id: '1',
        entityId: 'TRANSPORT001',
        entityType: 'transport',
        description: 'เส้นทางขนส่งโค - กรุงเทพฯ ไป นครราชสีมา',
        startTime: now.subtract(const Duration(hours: 4)),
        endTime: now.subtract(const Duration(hours: 1)),
        locations: [
          GPSLocation(
            latitude: 13.7563,
            longitude: 100.5018,
            timestamp: now.subtract(const Duration(hours: 4)),
            address: 'ตลาดปศุสัตว์กรุงเทพ',
            province: 'กรุงเทพมหานคร',
            district: 'บางซื่อ',
            subDistrict: 'บางซื่อ',
          ),
          GPSLocation(
            latitude: 13.9000,
            longitude: 100.7000,
            timestamp: now.subtract(const Duration(hours: 3, minutes: 30)),
            address: 'ปั๊มน้ำมัน ปตท. รังสิต',
            province: 'ปทุมธานี',
            district: 'ธัญบุรี',
            subDistrict: 'รังสิต',
          ),
          GPSLocation(
            latitude: 14.2000,
            longitude: 101.2000,
            timestamp: now.subtract(const Duration(hours: 2, minutes: 45)),
            address: 'ร้านอาหารริมทาง สระบุรี',
            province: 'สระบุรี',
            district: 'เมืองสระบุรี',
            subDistrict: 'ปากเพรียว',
          ),
          GPSLocation(
            latitude: 14.9799,
            longitude: 102.0977,
            timestamp: now.subtract(const Duration(hours: 1)),
            address: 'ฟาร์มโคนม บ้านโนนไทย',
            province: 'นครราชสีมา',
            district: 'เมืองนครราชสีมา',
            subDistrict: 'โนนไทย',
          ),
        ],
        metadata: {
          'vehicleId': 'TRUCK001',
          'driverName': 'นายสมชาย ขับรถ',
          'cargoType': 'โคนม',
          'cargoCount': 15,
        },
      ),
      LocationTrack(
        id: '2',
        entityId: 'SURVEY001',
        entityType: 'survey',
        description: 'การสำรวจฟาร์มปศุสัตว์ จ.ชลบุรี',
        startTime: now.subtract(const Duration(days: 1, hours: 2)),
        endTime: now.subtract(const Duration(days: 1)),
        locations: [
          GPSLocation(
            latitude: 13.3611,
            longitude: 100.9847,
            timestamp: now.subtract(const Duration(days: 1, hours: 2)),
            address: 'ที่ว่าการอำเภอเมืองชลบุรี',
            province: 'ชลบุรี',
            district: 'เมืองชลบุรี',
            subDistrict: 'เมืองชลบุรี',
          ),
          GPSLocation(
            latitude: 13.2500,
            longitude: 101.0200,
            timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
            address: 'ฟาร์มสุกร บ้านบึง',
            province: 'ชลบุรี',
            district: 'บ้านบึง',
            subDistrict: 'บ้านบึง',
          ),
          GPSLocation(
            latitude: 13.1800,
            longitude: 101.1500,
            timestamp: now.subtract(const Duration(days: 1, hours: 1)),
            address: 'ฟาร์มไก่ไข่ หนองใหญ่',
            province: 'ชลบุรี',
            district: 'หนองใหญ่',
            subDistrict: 'หนองใหญ่',
          ),
          GPSLocation(
            latitude: 13.3000,
            longitude: 101.2000,
            timestamp: now.subtract(const Duration(days: 1)),
            address: 'ฟาร์มโคเนื้อ พานทอง',
            province: 'ชลบุรี',
            district: 'พานทอง',
            subDistrict: 'พานทอง',
          ),
        ],
        metadata: {
          'surveyorName': 'นางสาวสมหญิง สำรวจ',
          'surveyType': 'ปศุสัตว์ทั่วไป',
          'farmsVisited': 3,
        },
      ),
    ];

    // Set current location to Bangkok as default
    _currentLocation = GPSLocation(
      latitude: 13.7563,
      longitude: 100.5018,
      timestamp: DateTime.now(),
      address: 'กรุงเทพมหานคร',
      province: 'กรุงเทพมหานคร',
      district: 'บางซื่อ',
      subDistrict: 'บางซื่อ',
    );

    notifyListeners();
  }

  // Start location tracking
  Future<void> startTracking(String entityId, String entityType, {String? description}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate GPS initialization
      await Future.delayed(const Duration(seconds: 2));
      
      // In real implementation, this would request location permissions
      // and start GPS tracking
      
      final track = LocationTrack(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        entityId: entityId,
        entityType: entityType,
        description: description,
        startTime: DateTime.now(),
        locations: [],
      );

      _tracks.add(track);
      _isTracking = true;
      
      // Simulate getting current location
      await _updateCurrentLocation();
      
    } catch (e) {
      _error = 'ไม่สามารถเริ่มติดตามตำแหน่งได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Stop location tracking
  Future<void> stopTracking() async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Find active track and end it
      final activeTrackIndex = _tracks.indexWhere((track) => track.endTime == null);
      if (activeTrackIndex != -1) {
        _tracks[activeTrackIndex] = _tracks[activeTrackIndex].copyWith(
          endTime: DateTime.now(),
        );
      }
      
      _isTracking = false;
    } catch (e) {
      _error = 'ไม่สามารถหยุดติดตามตำแหน่งได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update current location (simulate GPS reading)
  Future<void> _updateCurrentLocation() async {
    // Simulate GPS reading with some variation
    final baseLocation = _currentLocation ?? GPSLocation(
      latitude: 13.7563,
      longitude: 100.5018,
      timestamp: DateTime.now(),
    );

    // Add small random variation to simulate movement
    final random = DateTime.now().millisecond / 1000.0;
    final newLocation = GPSLocation(
      latitude: baseLocation.latitude + (random - 0.5) * 0.001,
      longitude: baseLocation.longitude + (random - 0.5) * 0.001,
      timestamp: DateTime.now(),
      accuracy: 5.0 + random * 10, // 5-15 meters accuracy
      address: baseLocation.address,
      province: baseLocation.province,
      district: baseLocation.district,
      subDistrict: baseLocation.subDistrict,
    );

    _currentLocation = newLocation;

    // Add to active track if tracking
    if (_isTracking) {
      final activeTrackIndex = _tracks.indexWhere((track) => track.endTime == null);
      if (activeTrackIndex != -1) {
        _tracks[activeTrackIndex] = _tracks[activeTrackIndex].addLocation(newLocation);
      }
    }

    notifyListeners();
  }

  // Manually add location
  Future<void> addLocation(GPSLocation location) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      
      _currentLocation = location;
      
      // Add to active track if tracking
      if (_isTracking) {
        final activeTrackIndex = _tracks.indexWhere((track) => track.endTime == null);
        if (activeTrackIndex != -1) {
          _tracks[activeTrackIndex] = _tracks[activeTrackIndex].addLocation(location);
        }
      }
      
    } catch (e) {
      _error = 'ไม่สามารถเพิ่มตำแหน่งได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get tracks by entity
  List<LocationTrack> getTracksByEntity(String entityId, String entityType) {
    return _tracks.where((track) => 
      track.entityId == entityId && track.entityType == entityType
    ).toList();
  }

  // Get tracks by type
  List<LocationTrack> getTracksByType(String entityType) {
    return _tracks.where((track) => track.entityType == entityType).toList();
  }

  // Get active tracks
  List<LocationTrack> get activeTracks {
    return _tracks.where((track) => track.endTime == null).toList();
  }

  // Delete track
  Future<void> deleteTrack(String trackId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _tracks.removeWhere((track) => track.id == trackId);
    } catch (e) {
      _error = 'ไม่สามารถลบข้อมูลติดตามได้: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculate distance between two locations
  double calculateDistance(GPSLocation from, GPSLocation to) {
    return from.distanceTo(to);
  }

  // Get location by coordinates (reverse geocoding simulation)
  Future<GPSLocation> getLocationByCoordinates(double latitude, double longitude) async {
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple simulation - in real app would use geocoding service
    String province = 'ไม่ทราบ';
    String district = 'ไม่ทราบ';
    String address = 'พิกัด $latitude, $longitude';
    
    // Check if coordinates are near known provinces
    for (final entry in ThailandLocations.provinces.entries) {
      final distance = GPSLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      ).distanceTo(entry.value);
      
      if (distance < 50) { // Within 50km
        province = entry.key;
        address = 'ใกล้เคียง${entry.key}';
        break;
      }
    }
    
    return GPSLocation(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      address: address,
      province: province,
      district: district,
    );
  }

  // Statistics
  int get totalTracks => _tracks.length;
  int get activeTracks_count => activeTracks.length;
  double get totalDistanceTracked {
    return _tracks.fold(0.0, (sum, track) => sum + track.totalDistance);
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
