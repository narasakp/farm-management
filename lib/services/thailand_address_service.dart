import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../models/thailand_address.dart';

class ThailandAddressService {
  // Try different APIs
  static const String apiEarthchie = 'https://raw.githubusercontent.com/earthchie/jquery.Thailand.js/master/jquery.Thailand.js/database/db.json';
  static const String apiKongvut = 'https://raw.githubusercontent.com/kongvut/thai-province-data/master/api_province.json';
  static const String apiThailandPost = 'https://thaiaddress.net/api/v1/provinces';
  
  // Cache data
  static List<Province>? _provinces;
  static List<Amphoe>? _amphoes;
  static List<Tambon>? _tambons;

  // โหลดข้อมูลจังหวัดทั้งหมด
  static Future<List<Province>> getProvinces() async {
    if (_provinces != null) return _provinces!;

    // Load from local JSON file
    try {
      print('📂 Loading provinces from local JSON...');
      final String jsonString = await rootBundle.loadString('assets/thailand.json');
      final List<dynamic> data = json.decode(jsonString);
      
      final Set<String> provinceNames = {};
      final Map<String, int> provinceIds = {};
      final List<Province> provinces = [];
      int id = 1;
      
      for (var item in data) {
        final provinceName = item['province'].toString();
        if (!provinceNames.contains(provinceName)) {
          provinceNames.add(provinceName);
          provinceIds[provinceName] = id;
          provinces.add(Province(
            id: id++,
            nameTh: provinceName,
            nameEn: provinceName,
          ));
        }
      }
      
      // Don't sort - keep order from JSON (Chaiyaphum first)
      _provinces = provinces;
      print('✅ Loaded ${provinces.length} provinces from local JSON');
      return _provinces!;
    } catch (e) {
      print('❌ Error loading provinces from local JSON: $e');
    }
    
    // Final fallback
    _provinces = [
      Province(id: 1, nameTh: 'กรุงเทพมหานคร', nameEn: 'Bangkok'),
      Province(id: 36, nameTh: 'ชัยภูมิ', nameEn: 'Chaiyaphum'),
    ];
    
    return _provinces!;
  }

  // โหลดข้อมูลอำเภอทั้งหมด
  static Future<List<Amphoe>> getAmphoes() async {
    if (_amphoes != null) return _amphoes!;

    // Load from local JSON file
    try {
      print('📂 Loading amphoes from local JSON...');
      final String jsonString = await rootBundle.loadString('assets/thailand.json');
      final List<dynamic> data = json.decode(jsonString);
      
      await getProvinces(); // Ensure provinces are loaded first
      
      final Map<String, int> amphoeIds = {};
      final List<Amphoe> amphoes = [];
      int amphoeId = 1;
      
      for (var item in data) {
        final provinceName = item['province'].toString();
        final amphoeName = item['amphoe'].toString();
        final amphoeKey = '$provinceName-$amphoeName';
        
        final province = _provinces?.firstWhere(
          (p) => p.nameTh == provinceName,
          orElse: () => Province(id: 0, nameTh: '', nameEn: ''),
        );
        
        if (province != null && province.id > 0 && !amphoeIds.containsKey(amphoeKey)) {
          amphoeIds[amphoeKey] = amphoeId;
          amphoes.add(Amphoe(
            id: amphoeId++,
            provinceId: province.id,
            nameTh: amphoeName,
            nameEn: amphoeName,
          ));
        }
      }
      
      _amphoes = amphoes;
      print('✅ Loaded ${amphoes.length} amphoes from local JSON');
      return _amphoes!;
    } catch (e) {
      print('❌ Error loading amphoes from local JSON: $e');
    }
    
    // Fallback
    _amphoes = [
      Amphoe(id: 3601, provinceId: 36, nameTh: 'เมืองชัยภูมิ', nameEn: 'Mueang Chaiyaphum'),
    ];
    
    return _amphoes!;
  }

  // โหลดข้อมูลตำบลทั้งหมด
  static Future<List<Tambon>> getTambons() async {
    if (_tambons != null) return _tambons!;

    // Load from local JSON file
    try {
      print('📂 Loading tambons from local JSON...');
      final String jsonString = await rootBundle.loadString('assets/thailand.json');
      final List<dynamic> data = json.decode(jsonString);
      
      await getAmphoes(); // Ensure amphoes are loaded first
      
      final List<Tambon> tambons = [];
      int tambonId = 1;
      
      for (var item in data) {
        final provinceName = item['province'].toString();
        final amphoeName = item['amphoe'].toString();
        final tambonName = item['tambon'].toString();
        final zipCode = item['zipcode'] as int;
        
        final amphoe = _amphoes?.firstWhere(
          (a) {
            final province = _provinces?.firstWhere((p) => p.id == a.provinceId);
            return province?.nameTh == provinceName && a.nameTh == amphoeName;
          },
          orElse: () => Amphoe(id: 0, provinceId: 0, nameTh: '', nameEn: ''),
        );
        
        if (amphoe != null && amphoe.id > 0) {
          tambons.add(Tambon(
            id: tambonId++,
            amphoeId: amphoe.id,
            nameTh: tambonName,
            nameEn: tambonName,
            zipCode: zipCode,
          ));
        }
      }
      
      _tambons = tambons;
      print('✅ Loaded ${tambons.length} tambons from local JSON');
      return _tambons!;
    } catch (e) {
      print('❌ Error loading tambons from local JSON: $e');
    }
    
    // Fallback
    _tambons = [
      Tambon(id: 360101, amphoeId: 3601, nameTh: 'ในเมือง', nameEn: 'Nai Mueang', zipCode: 36000),
    ];
    
    return _tambons!;
  }

  // กรองอำเภอตามจังหวัด
  static Future<List<Amphoe>> getAmphoesByProvince(int provinceId) async {
    final amphoes = await getAmphoes();
    return amphoes.where((a) => a.provinceId == provinceId).toList();
  }

  // กรองตำบลตามอำเภอ
  static Future<List<Tambon>> getTambonsByAmphoe(int amphoeId) async {
    final tambons = await getTambons();
    return tambons.where((t) => t.amphoeId == amphoeId).toList();
  }

  // ค้นหาจังหวัดจากชื่อ
  static Future<Province?> findProvinceByName(String name) async {
    final provinces = await getProvinces();
    try {
      return provinces.firstWhere((p) => p.nameTh == name);
    } catch (e) {
      return null;
    }
  }

  // ค้นหาอำเภอจากชื่อและจังหวัด
  static Future<Amphoe?> findAmphoeByName(String name, int provinceId) async {
    final amphoes = await getAmphoesByProvince(provinceId);
    try {
      return amphoes.firstWhere((a) => a.nameTh == name);
    } catch (e) {
      return null;
    }
  }

  // ค้นหาตำบลจากชื่อและอำเภอ
  static Future<Tambon?> findTambonByName(String name, int amphoeId) async {
    final tambons = await getTambonsByAmphoe(amphoeId);
    try {
      return tambons.firstWhere((t) => t.nameTh == name);
    } catch (e) {
      return null;
    }
  }

  // ล้าง cache
  static void clearCache() {
    _provinces = null;
    _amphoes = null;
    _tambons = null;
  }
}
