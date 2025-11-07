import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/trading.dart';
import '../../models/livestock.dart';

/// Service สำหรับสร้างภาพสวยงามสำหรับแชร์
class TemplateGenerator {
  /// สร้างภาพจาก Template
  Future<ui.Image?> generateImage({
    required String template,
    required MarketListing listing,
    required Livestock livestock,
    String? imageUrl,
    Map<String, dynamic>? customization,
  }) async {
    try {
      switch (template) {
        case 'card':
          return await _generateCardTemplate(listing, livestock, imageUrl, customization);
        case 'price':
          return await _generatePriceTemplate(listing, livestock, imageUrl, customization);
        case 'gallery':
          return await _generateGalleryTemplate(listing, livestock, imageUrl, customization);
        case 'video':
          return await _generateVideoPreviewTemplate(listing, livestock, imageUrl, customization);
        default:
          return await _generateCardTemplate(listing, livestock, imageUrl, customization);
      }
    } catch (e) {
      print('❌ Error generating image: $e');
      return null;
    }
  }
  
  /// Template 1: Livestock Card - การ์ดแสดงข้อมูลปศุสัตว์
  Future<ui.Image> _generateCardTemplate(
    MarketListing listing,
    Livestock livestock,
    String? imageUrl,
    Map<String, dynamic>? customization,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1200, 1200);
    
    // สีพื้นหลัง (gradient)
    final bgColor1 = customization?['bgColor1'] ?? const Color(0xFFF1F8E9);
    final bgColor2 = customization?['bgColor2'] ?? const Color(0xFFE8F5E9);
    
    // วาดพื้นหลัง gradient
    final bgGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [bgColor1, bgColor2],
    );
    
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // วาดกรอบสีเขียว
    final borderPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
        const Radius.circular(30),
      ),
      borderPaint,
    );
    
    // วาด Container สำหรับรูปปศุสัตว์
    final imagePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 60, 1080, 600),
        const Radius.circular(20),
      ),
      imagePaint,
    );
    
    // วาดข้อความ "รูปปศุสัตว์" (placeholder)
    final textStyle = TextStyle(
      color: Colors.grey.shade400,
      fontSize: 48,
      fontWeight: FontWeight.w500,
    );
    final textSpan = TextSpan(text: '📷 รูปปศุสัตว์', style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(460, 320));
    
    // วาด Info Section (พื้นหลังขาว)
    final infoPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(60, 700, 800, 440),
        const Radius.circular(20),
      ),
      infoPaint,
    );
    
    // ชื่อปศุสัตว์
    _drawText(
      canvas,
      text: livestock.type.displayName,
      x: 100,
      y: 740,
      fontSize: 56,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF228B22),
    );
    
    // อายุและน้ำหนัก
    final ageText = livestock.birthDate != null 
        ? '${_calculateAge(livestock.birthDate!)} ปี'
        : 'ไม่ระบุ';
    final weightText = livestock.weight != null 
        ? '${livestock.weight!.toStringAsFixed(0)} กก.'
        : 'ไม่ระบุ';
    
    _drawText(
      canvas,
      text: '🎂 อายุ: $ageText  |  ⚖️ น้ำหนัก: $weightText',
      x: 100,
      y: 820,
      fontSize: 36,
      color: Colors.grey.shade700,
    );
    
    // สุขภาพ
    final healthStatus = livestock.healthStatus ?? 'ดี';
    _drawText(
      canvas,
      text: '💚 สุขภาพ: $healthStatus',
      x: 100,
      y: 880,
      fontSize: 36,
      color: Colors.grey.shade700,
    );
    
    // คำอธิบาย
    final description = listing.shareDescription ?? listing.description ?? '';
    if (description.isNotEmpty) {
      _drawText(
        canvas,
        text: description.length > 80 
            ? '${description.substring(0, 80)}...'
            : description,
        x: 100,
        y: 940,
        fontSize: 32,
        color: Colors.grey.shade600,
        maxWidth: 700,
      );
    }
    
    // ราคา (ใหญ่ตัวหนา)
    final pricePaint = Paint()
      ..color = const Color(0xFFFF6B35)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(100, 1020, 700, 100),
        const Radius.circular(15),
      ),
      pricePaint,
    );
    
    final priceText = _formatPrice(listing.askingPrice);
    _drawText(
      canvas,
      text: '💰 ราคา: $priceText',
      x: 130,
      y: 1045,
      fontSize: 52,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    
    // QR Code Section
    final qrPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(900, 700, 240, 440),
        const Radius.circular(20),
      ),
      qrPaint,
    );
    
    // วาด QR Code placeholder
    final qrBorderPaint = Paint()
      ..color = const Color(0xFF228B22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(930, 730, 180, 180),
        const Radius.circular(10),
      ),
      qrBorderPaint,
    );
    
    _drawText(
      canvas,
      text: 'QR',
      x: 990,
      y: 800,
      fontSize: 40,
      fontWeight: FontWeight.bold,
      color: const Color(0xFF228B22),
    );
    
    _drawText(
      canvas,
      text: 'สแกนเพื่อ\nดูรายละเอียด',
      x: 920,
      y: 940,
      fontSize: 24,
      color: Colors.grey.shade600,
      textAlign: TextAlign.center,
      maxWidth: 200,
    );
    
    // Badge "ขายด่วน" ถ้ามี
    if (customization?['showUrgentBadge'] == true) {
      final badgePaint = Paint()
        ..color = const Color(0xFFFF5252)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(880, 40, 260, 80),
          const Radius.circular(40),
        ),
        badgePaint,
      );
      
      _drawText(
        canvas,
        text: '⚡ ขายด่วน',
        x: 920,
        y: 55,
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );
    }
    
    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }
  
  /// Template 2: Price Highlight - เน้นราคา
  Future<ui.Image> _generatePriceTemplate(
    MarketListing listing,
    Livestock livestock,
    String? imageUrl,
    Map<String, dynamic>? customization,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1200, 1200);
    
    // พื้นหลังสีส้มไล่เฉด
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFFF6B35),
        const Color(0xFFFF8C42),
      ],
    );
    
    final bgPaint = Paint()
      ..shader = bgGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // ชื่อปศุสัตว์ (ด้านบน)
    _drawText(
      canvas,
      text: livestock.type.displayName.toUpperCase(),
      x: 600,
      y: 150,
      fontSize: 72,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    // ราคาใหญ่มาก
    final priceText = _formatPrice(listing.askingPrice);
    _drawText(
      canvas,
      text: priceText,
      x: 600,
      y: 450,
      fontSize: 140,
      fontWeight: FontWeight.w900,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    // "เท่านั้น!"
    _drawText(
      canvas,
      text: 'เท่านั้น!',
      x: 600,
      y: 620,
      fontSize: 64,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFE082),
      textAlign: TextAlign.center,
    );
    
    // Info boxes
    final infoPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.fill;
    
    // อายุ
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(100, 800, 450, 120),
        const Radius.circular(20),
      ),
      infoPaint,
    );
    
    final age = livestock.birthDate != null 
        ? '${_calculateAge(livestock.birthDate!)} ปี'
        : 'ไม่ระบุ';
    _drawText(
      canvas,
      text: '🎂 อายุ: $age',
      x: 140,
      y: 835,
      fontSize: 44,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF228B22),
    );
    
    // น้ำหนัก
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(650, 800, 450, 120),
        const Radius.circular(20),
      ),
      infoPaint,
    );
    
    final weight = livestock.weight != null 
        ? '${livestock.weight!.toStringAsFixed(0)} กก.'
        : 'ไม่ระบุ';
    _drawText(
      canvas,
      text: '⚖️ น้ำหนัก: $weight',
      x: 690,
      y: 835,
      fontSize: 44,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF228B22),
    );
    
    // Call to action
    _drawText(
      canvas,
      text: '👉 สแกน QR หรือคลิกลิงก์เพื่อซื้อเลย!',
      x: 600,
      y: 1050,
      fontSize: 36,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }
  
  /// Template 3: Gallery - แสดงหลายตัว
  Future<ui.Image> _generateGalleryTemplate(
    MarketListing listing,
    Livestock livestock,
    String? imageUrl,
    Map<String, dynamic>? customization,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1200, 1200);
    
    // พื้นหลังสีขาว
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Header
    final headerPaint = Paint()..color = const Color(0xFF228B22);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1200, 150), headerPaint);
    
    _drawText(
      canvas,
      text: '🐂 ปศุสัตว์คุณภาพ พร้อมขาย',
      x: 600,
      y: 50,
      fontSize: 56,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    // Grid 2x2
    final boxPaint = Paint()..color = Colors.white;
    final List<Rect> boxes = [
      const Rect.fromLTWH(50, 200, 550, 400),
      const Rect.fromLTWH(650, 200, 500, 400),
      const Rect.fromLTWH(50, 650, 550, 400),
      const Rect.fromLTWH(650, 650, 500, 400),
    ];
    
    for (final box in boxes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(box, const Radius.circular(15)),
        boxPaint,
      );
    }
    
    // ราคารวมด้านล่าง
    final priceBgPaint = Paint()..color = const Color(0xFFFF6B35);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(50, 1080, 1100, 90),
        const Radius.circular(45),
      ),
      priceBgPaint,
    );
    
    _drawText(
      canvas,
      text: '💰 ราคารวม: ${_formatPrice(listing.askingPrice)}',
      x: 600,
      y: 1105,
      fontSize: 52,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }
  
  /// Template 4: Video Preview - สำหรับ TikTok
  Future<ui.Image> _generateVideoPreviewTemplate(
    MarketListing listing,
    Livestock livestock,
    String? imageUrl,
    Map<String, dynamic>? customization,
  ) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1080, 1920); // 9:16 สำหรับ TikTok
    
    // พื้นหลังสีดำ
    final bgPaint = Paint()..color = Colors.black;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);
    
    // Overlay gradient
    final overlayGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Colors.black.withOpacity(0.7),
      ],
    );
    
    final overlayPaint = Paint()
      ..shader = overlayGradient.createShader(
        Rect.fromLTWH(0, size.height - 600, size.width, 600),
      );
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - 600, size.width, 600),
      overlayPaint,
    );
    
    // ชื่อและราคา (ด้านล่าง)
    _drawText(
      canvas,
      text: livestock.type.displayName,
      x: 80,
      y: 1500,
      fontSize: 64,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );
    
    final priceText = _formatPrice(listing.askingPrice);
    _drawText(
      canvas,
      text: '💰 $priceText',
      x: 80,
      y: 1590,
      fontSize: 52,
      fontWeight: FontWeight.w600,
      color: const Color(0xFFFFD700),
    );
    
    // Swipe up indicator
    _drawText(
      canvas,
      text: '👆 Swipe up to buy',
      x: 540,
      y: 1720,
      fontSize: 40,
      fontWeight: FontWeight.w500,
      color: Colors.white,
      textAlign: TextAlign.center,
    );
    
    final picture = recorder.endRecording();
    return await picture.toImage(size.width.toInt(), size.height.toInt());
  }
  
  /// Helper: วาดข้อความ
  void _drawText(
    Canvas canvas, {
    required String text,
    required double x,
    required double y,
    required double fontSize,
    FontWeight fontWeight = FontWeight.normal,
    required Color color,
    TextAlign textAlign = TextAlign.left,
    double? maxWidth,
  }) {
    final textStyle = TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: 1.2,
    );
    
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
      maxLines: maxWidth != null ? 3 : 1,
    );
    
    textPainter.layout(maxWidth: maxWidth ?? double.infinity);
    
    double offsetX = x;
    if (textAlign == TextAlign.center) {
      offsetX = x - (textPainter.width / 2);
    }
    
    textPainter.paint(canvas, Offset(offsetX, y));
  }
  
  /// Helper: คำนวณอายุ
  int _calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month || 
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }
  
  /// Helper: Format ราคา
  String _formatPrice(double price) {
    if (price >= 1000) {
      return '฿${price.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      )}';
    }
    return '฿${price.toStringAsFixed(0)}';
  }
  
  /// Export image เป็น bytes
  Future<List<int>?> exportAsBytes(ui.Image image) async {
    try {
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print('❌ Error exporting image: $e');
      return null;
    }
  }
}
