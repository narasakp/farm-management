class EmailConfig {
  // Gmail SMTP Configuration (Free)
  static const String smtpUsername = 'your_email@gmail.com'; // แก้เป็นอีเมลจริง
  static const String smtpPassword = 'your_app_password'; // App Password จาก Gmail
  static const String smtpHost = 'smtp.gmail.com';
  static const int smtpPort = 587;
  static const String fromName = 'ระบบจัดการฟาร์มปศุสัตว์';
  
  // Check if SMTP is configured
  static bool get isConfigured {
    return smtpUsername != 'your_email@gmail.com' && 
           smtpPassword != 'your_app_password';
  }
  
  // Instructions for setup
  static String get setupInstructions => '''
📧 วิธีตั้งค่า Gmail SMTP สำหรับ OTP Authentication:

1. เข้า Gmail → Settings → Security
2. เปิด 2-Factor Authentication
3. สร้าง App Password:
   - Google Account → Security → App passwords
   - เลือก "Mail" และ "Other"
   - คัดลอก App Password (16 ตัวอักษร)

4. แก้ไขไฟล์ email_config.dart:
   - smtpUsername: 'youremail@gmail.com'
   - smtpPassword: 'your_16_char_app_password'

5. ทดสอบส่ง OTP:
   - ใช้อีเมลจริงแทนอีเมลทดสอบ
   - ระบบจะส่ง OTP ไปยังอีเมลผู้ล็อกอิน

💡 Gmail ให้ส่งฟรี 500 อีเมล/วัน (เพียงพอสำหรับ OTP)
🔐 ส่งทีละ 1 อีเมล OTP ต่อการล็อกอิน
  ''';
}
