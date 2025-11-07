import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget แสดงข้อมูลที่ Masked พร้อมปุ่มจัดการ
class MaskedDataWidget extends StatelessWidget {
  final String label;
  final String value; // แสดงบน UI (formatted)
  final String? rawValue; // ใช้ตอน copy (plain text)
  final bool isMasked;
  final String? userRole;
  final String fieldType; // 'id_card', 'phone', 'gps'
  final VoidCallback? onClickToReveal;
  final VoidCallback? onRequestCallback;
  final VoidCallback? onEmergencyAccess;
  final Map<String, dynamic>? temporaryAccess;
  final Map<String, dynamic>? featureFlags; // Feature flags from backend
  final Widget? customDisplay; // Custom widget สำหรับแสดงผล (เช่น GPS Map)

  const MaskedDataWidget({
    Key? key,
    required this.label,
    required this.value,
    this.rawValue, // Optional: ถ้าไม่ส่งมาจะใช้ value
    this.isMasked = false,
    this.userRole,
    required this.fieldType,
    this.onClickToReveal,
    this.onRequestCallback,
    this.onEmergencyAccess,
    this.temporaryAccess,
    this.featureFlags, // Feature flags from backend
    this.customDisplay, // Custom widget สำหรับแสดงผล
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ตรวจสอบว่า field นี้มี temporary access หรือไม่
    final hasTemporaryAccess = temporaryAccess != null && 
        temporaryAccess!['granted'] == true &&
        (temporaryAccess!['access_fields'] as List?)?.contains(fieldType) == true;
    
    // ถ้ามี customDisplay และข้อมูลไม่ masked (หรือมี temporary access) → แสดง custom widget
    if (customDisplay != null && (!isMasked || hasTemporaryAccess)) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: customDisplay!,
      );
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label และ Value
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Value
                    Text(
                      value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: isMasked ? Colors.orange[700] : Colors.grey[700],
                        fontSize: 14,
                        fontWeight: isMasked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    
                    // Icon แสดงสถานะ (ไม่แสดงถ้าเป็น -)
                    const SizedBox(width: 8),
                    if (isMasked && value != '-')
                      Icon(
                        Icons.visibility_off,
                        size: 16,
                        color: Colors.orange[700],
                      )
                    else if (hasTemporaryAccess)
                      Icon(
                        Icons.visibility,
                        size: 16,
                        color: Colors.green[700],
                      ),
                    
                    // ปุ่ม Copy (ถ้าไม่ Masked)
                    if (!isMasked && value != '-')
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        onPressed: () {
                          // คัดลอก rawValue (plain text) ถ้ามี, ไม่งั้นใช้ value
                          final textToCopy = rawValue ?? value.replaceAll(RegExp(r'[^0-9]'), '');
                          Clipboard.setData(ClipboardData(text: textToCopy));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('คัดลอก: $textToCopy'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        tooltip: 'คัดลอก',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Temporary Access Indicator
          if (hasTemporaryAccess)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'เห็นข้อมูลเต็ม',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'หมดเวลา: ${_formatExpiry(_getFieldExpiry())}',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green[600],
                            ),
                          ),
                          if (_getFieldReason() != null)
                            Text(
                              'เหตุผล: ${_getFieldReason()}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Action Buttons (แสดงเฉพาะเมื่อ Masked และไม่มี Temporary Access และไม่ใช่ -)
          if (isMasked && !hasTemporaryAccess && value != '-' && _canShowActions())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // ขอให้โทรกลับ (ทุก Role ที่มีสิทธิ์) - ✅ เช็ค Feature Flag
                  if (onRequestCallback != null && (featureFlags?['request_callback'] ?? false)) ...[
                    _buildActionButton(
                      icon: Icons.phone_callback,
                      label: 'ขอให้โทรกลับ',
                      color: Colors.green,
                      onPressed: onRequestCallback!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // ขอดูเบอร์เต็ม (OFFICER, ADMIN)
                  if (onClickToReveal != null && _canClickToReveal()) ...[
                    _buildActionButton(
                      icon: Icons.visibility,
                      label: 'ขอดูข้อมูลเต็ม',
                      color: Colors.orange,
                      onPressed: onClickToReveal!,
                    ),
                    const SizedBox(width: 8),
                  ],
                  
                  // ขอเข้าถึงฉุกเฉิน (OFFICER, ADMIN)
                  if (onEmergencyAccess != null && _canEmergencyAccess())
                    _buildActionButton(
                      icon: Icons.emergency,
                      label: 'ฉุกเฉิน',
                      color: Colors.red,
                      onPressed: onEmergencyAccess!,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  bool _canShowActions() {
    final role = (userRole ?? 'farmer').toUpperCase();
    return role.contains('OFFICER') || 
           role == 'SUPER_ADMIN' || 
           role == 'RESEARCHER';
  }

  bool _canClickToReveal() {
    final role = (userRole ?? 'farmer').toUpperCase();
    return role.contains('OFFICER') || role == 'SUPER_ADMIN' || role == 'RESEARCHER';
  }

  bool _canEmergencyAccess() {
    final role = (userRole ?? 'farmer').toUpperCase();
    return role.contains('OFFICER') || role == 'SUPER_ADMIN' || role == 'RESEARCHER';
  }

  String? _getFieldReason() {
    if (temporaryAccess == null) return null;
    
    // ถ้ามี fieldReasons ให้ใช้ reason ของ field นี้
    if (temporaryAccess!['fieldReasons'] != null) {
      final fieldReasons = temporaryAccess!['fieldReasons'] as Map<String, dynamic>?;
      return fieldReasons?[fieldType];
    }
    
    // ถ้าไม่มี fieldReasons ให้ใช้ reason ทั่วไป
    return temporaryAccess!['reason'];
  }

  String? _getFieldExpiry() {
    if (temporaryAccess == null) return null;
    
    // ถ้ามี fieldExpiries ให้ใช้ expiry ของ field นี้
    if (temporaryAccess!['fieldExpiries'] != null) {
      final fieldExpiries = temporaryAccess!['fieldExpiries'] as Map<String, dynamic>?;
      return fieldExpiries?[fieldType];
    }
    
    // ถ้าไม่มี fieldExpiries ให้ใช้ expires_at ทั่วไป
    return temporaryAccess!['expires_at'];
  }

  String _formatExpiry(String? expiresAt) {
    if (expiresAt == null) return 'ไม่ระบุ';
    
    try {
      // Parse UTC time และแปลงเป็น Local Time (Thailand = UTC+7)
      final expiryUTC = DateTime.parse(expiresAt).toUtc();
      final expiryLocal = expiryUTC.toLocal();
      final now = DateTime.now();
      final diff = expiryLocal.difference(now);
      
      if (diff.isNegative) return 'หมดอายุแล้ว';
      
      final hours = diff.inHours;
      final minutes = diff.inMinutes % 60;
      
      if (hours > 0) {
        return '${expiryLocal.hour.toString().padLeft(2, '0')}:${expiryLocal.minute.toString().padLeft(2, '0')} น. (อีก ${hours}:${minutes.toString().padLeft(2, '0')} ชม.)';
      } else {
        return '${expiryLocal.hour.toString().padLeft(2, '0')}:${expiryLocal.minute.toString().padLeft(2, '0')} น. (อีก $minutes นาที)';
      }
    } catch (e) {
      return expiresAt;
    }
  }
}
