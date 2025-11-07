import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/market.dart';
import '../models/market_zone.dart';
import '../models/market_schedule.dart';

/// Mock data สำหรับตลาดนัด
class MockMarkets {
  static List<Market> get markets => [
        _market1,
        _market2,
        _market3,
        _market4,
        _market5,
      ];

  // ตลาดนัดเทศบาลเมือง
  static final Market _market1 = Market(
    id: 'market_001',
    name: 'ตลาดนัดเทศบาลเมือง',
    description: 'ตลาดนัดใหญ่ใจกลางเมือง มีสิ่งอำนวยความสะดวกครบครัน',
    location: 'เขตเมือง, จังหวัดขอนแก่น',
    coordinates: const GeoPoint(16.4419, 102.8360),
    schedules: {
      'monday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '12:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00'],
      ),
      'tuesday': MarketSchedule(
        isOpen: false,
        openTime: '',
        closeTime: '',
        timeSlots: [],
      ),
      'wednesday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '12:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00'],
      ),
      'thursday': MarketSchedule(
        isOpen: false,
        openTime: '',
        closeTime: '',
        timeSlots: [],
      ),
      'friday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '12:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00'],
      ),
      'saturday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '14:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00', '12:00-14:00'],
      ),
      'sunday': MarketSchedule(
        isOpen: false,
        openTime: '',
        closeTime: '',
        timeSlots: [],
      ),
    },
    zones: [
      MarketZone(
        id: 'zone_a',
        name: 'โซน A (โค-กระบือ)',
        code: 'A',
        livestockType: 'โค',
        totalSlots: 20,
        extraFee: 50,
        sortOrder: 1,
      ),
      MarketZone(
        id: 'zone_b',
        name: 'โซน B (สุกร)',
        code: 'B',
        livestockType: 'สุกร',
        totalSlots: 15,
        extraFee: 30,
        sortOrder: 2,
      ),
      MarketZone(
        id: 'zone_c',
        name: 'โซน C (ไก่-เป็ด)',
        code: 'C',
        livestockType: 'ไก่',
        totalSlots: 25,
        extraFee: 20,
        sortOrder: 3,
      ),
    ],
    baseFee: 100,
    rating: 4.5,
    reviewCount: 120,
    isActive: true,
    imageUrl: 'https://picsum.photos/seed/market1/800/600',
    rules: '''
1. ต้องชำระค่าธรรมเนียมล่วงหน้า
2. มาถึงก่อนเวลา 15 นาที
3. รักษาความสะอาด
4. ห้ามขายสัตว์ป่วย
''',
    facilities: ['ที่จอดรถ', 'น้ำดื่ม', 'ห้องน้ำ', 'ไฟฟ้า'],
    phone: '043-123456',
    email: 'market1@example.com',
    createdAt: DateTime(2025, 1, 1),
    updatedAt: DateTime.now(),
    createdBy: 'admin_001',
  );

  // ตลาดนัดศาลากลาง
  static final Market _market2 = Market(
    id: 'market_002',
    name: 'ตลาดนัดศาลากลาง',
    description: 'ตลาดนัดขนาดกลาง เน้นโคกระบือ',
    location: 'อำเภอเมือง, จังหวัดขอนแก่น',
    coordinates: const GeoPoint(16.4322, 102.8247),
    schedules: {
      'monday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'tuesday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '11:00',
        timeSlots: ['06:00-08:00', '08:00-11:00'],
      ),
      'wednesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'thursday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '11:00',
        timeSlots: ['06:00-08:00', '08:00-11:00'],
      ),
      'friday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'saturday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '12:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00'],
      ),
      'sunday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
    },
    zones: [
      MarketZone(
        id: 'zone_a',
        name: 'โซน A (โค)',
        code: 'A',
        livestockType: 'โค',
        totalSlots: 15,
        extraFee: 40,
        sortOrder: 1,
      ),
      MarketZone(
        id: 'zone_b',
        name: 'โซน B (กระบือ)',
        code: 'B',
        livestockType: 'กระบือ',
        totalSlots: 10,
        extraFee: 40,
        sortOrder: 2,
      ),
    ],
    baseFee: 80,
    rating: 4.2,
    reviewCount: 85,
    isActive: true,
    imageUrl: 'https://picsum.photos/seed/market2/800/600',
    phone: '043-234567',
    createdAt: DateTime(2025, 1, 15),
    updatedAt: DateTime.now(),
    createdBy: 'admin_001',
  );

  // ตลาดนัดบ้านค้อ
  static final Market _market3 = Market(
    id: 'market_003',
    name: 'ตลาดนัดบ้านค้อ',
    description: 'ตลาดนัดชุมชน เน้นสุกรและไก่',
    location: 'ตำบลบ้านค้อ, อำเภอเมือง',
    coordinates: const GeoPoint(16.4550, 102.8100),
    schedules: {
      'monday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'tuesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'wednesday': MarketSchedule(
        isOpen: true,
        openTime: '06:30',
        closeTime: '11:00',
        timeSlots: ['06:30-09:00', '09:00-11:00'],
      ),
      'thursday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'friday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'saturday': MarketSchedule(
        isOpen: true,
        openTime: '06:30',
        closeTime: '11:30',
        timeSlots: ['06:30-09:00', '09:00-11:30'],
      ),
      'sunday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '12:00',
        timeSlots: ['06:00-08:00', '08:00-10:00', '10:00-12:00'],
      ),
    },
    zones: [
      MarketZone(
        id: 'zone_a',
        name: 'โซน A (สุกร)',
        code: 'A',
        livestockType: 'สุกร',
        totalSlots: 20,
        extraFee: 30,
        sortOrder: 1,
      ),
      MarketZone(
        id: 'zone_b',
        name: 'โซน B (ไก่-เป็ด)',
        code: 'B',
        livestockType: 'ไก่',
        totalSlots: 30,
        extraFee: 20,
        sortOrder: 2,
      ),
    ],
    baseFee: 60,
    rating: 4.0,
    reviewCount: 45,
    isActive: true,
    imageUrl: 'https://picsum.photos/seed/market3/800/600',
    phone: '043-345678',
    createdAt: DateTime(2025, 2, 1),
    updatedAt: DateTime.now(),
    createdBy: 'admin_002',
  );

  // ตลาดนัดหนองแวง
  static final Market _market4 = Market(
    id: 'market_004',
    name: 'ตลาดนัดหนองแวง',
    description: 'ตลาดนัดรายสัปดาห์ ครบทุกประเภทสัตว์',
    location: 'ตำบลหนองแวง, อำเภอเมือง',
    coordinates: const GeoPoint(16.4650, 102.8500),
    schedules: {
      'monday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'tuesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'wednesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'thursday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'friday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'saturday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '13:00',
        timeSlots: ['06:00-08:30', '08:30-11:00', '11:00-13:00'],
      ),
      'sunday': MarketSchedule(
        isOpen: true,
        openTime: '06:00',
        closeTime: '13:00',
        timeSlots: ['06:00-08:30', '08:30-11:00', '11:00-13:00'],
      ),
    },
    zones: [
      MarketZone(
        id: 'zone_a',
        name: 'โซน A (โค-กระบือ)',
        code: 'A',
        livestockType: 'โค',
        totalSlots: 25,
        extraFee: 50,
        sortOrder: 1,
      ),
      MarketZone(
        id: 'zone_b',
        name: 'โซน B (สุกร)',
        code: 'B',
        livestockType: 'สุกร',
        totalSlots: 20,
        extraFee: 30,
        sortOrder: 2,
      ),
      MarketZone(
        id: 'zone_c',
        name: 'โซน C (แพะ-แกะ)',
        code: 'C',
        livestockType: 'แพะ',
        totalSlots: 15,
        extraFee: 25,
        sortOrder: 3,
      ),
      MarketZone(
        id: 'zone_d',
        name: 'โซน D (ไก่-เป็ด)',
        code: 'D',
        livestockType: 'ไก่',
        totalSlots: 30,
        extraFee: 20,
        sortOrder: 4,
      ),
    ],
    baseFee: 100,
    rating: 4.7,
    reviewCount: 200,
    isActive: true,
    imageUrl: 'https://picsum.photos/seed/market4/800/600',
    facilities: ['ที่จอดรถ', 'น้ำดื่ม', 'ห้องน้ำ', 'ไฟฟ้า', 'ร้านอาหาร'],
    phone: '043-456789',
    email: 'market4@example.com',
    createdAt: DateTime(2025, 2, 15),
    updatedAt: DateTime.now(),
    createdBy: 'admin_001',
  );

  // ตลาดนัดบ้านหมี่
  static final Market _market5 = Market(
    id: 'market_005',
    name: 'ตลาดนัดบ้านหมี่',
    description: 'ตลาดนัดเล็ก เน้นชุมชน',
    location: 'ตำบลบ้านหมี่, อำเภอเมือง',
    coordinates: const GeoPoint(16.4200, 102.8600),
    schedules: {
      'monday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'tuesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'wednesday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'thursday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'friday': MarketSchedule(
        isOpen: true,
        openTime: '07:00',
        closeTime: '11:00',
        timeSlots: ['07:00-09:00', '09:00-11:00'],
      ),
      'saturday': MarketSchedule(isOpen: false, openTime: '', closeTime: '', timeSlots: []),
      'sunday': MarketSchedule(
        isOpen: true,
        openTime: '07:00',
        closeTime: '12:00',
        timeSlots: ['07:00-09:00', '09:00-12:00'],
      ),
    },
    zones: [
      MarketZone(
        id: 'zone_a',
        name: 'โซน A (โค-สุกร)',
        code: 'A',
        livestockType: 'โค',
        totalSlots: 10,
        extraFee: 30,
        sortOrder: 1,
      ),
      MarketZone(
        id: 'zone_b',
        name: 'โซน B (ไก่-เป็ด)',
        code: 'B',
        livestockType: 'ไก่',
        totalSlots: 15,
        extraFee: 15,
        sortOrder: 2,
      ),
    ],
    baseFee: 50,
    rating: 3.8,
    reviewCount: 25,
    isActive: true,
    imageUrl: 'https://picsum.photos/seed/market5/800/600',
    phone: '043-567890',
    createdAt: DateTime(2025, 3, 1),
    updatedAt: DateTime.now(),
    createdBy: 'admin_002',
  );
}
