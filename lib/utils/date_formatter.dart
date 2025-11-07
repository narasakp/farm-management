/**
 * Date Formatter Utility
 * จัดรูปแบบวันที่และเวลาสำหรับแสดงผล
 */

class DateFormatter {
  /// Format เป็น relative time (เช่น "2 ชั่วโมงที่แล้ว")
  static String formatRelative(dynamic dateTime) {
    if (dateTime == null) return 'ไม่ทราบ';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime;
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'ไม่ทราบ';
    }

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inSeconds < 60) {
      return 'เมื่อสักครู่';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} นาทีที่แล้ว';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ชั่วโมงที่แล้ว';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} วันที่แล้ว';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks สัปดาห์ที่แล้ว';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months เดือนที่แล้ว';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ปีที่แล้ว';
    }
  }

  /// Format เป็นวันที่และเวลาแบบเต็ม (เช่น "2 พ.ย. 2025 เวลา 14:30")
  static String formatFull(dynamic dateTime) {
    if (dateTime == null) return 'ไม่ทราบ';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime;
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'ไม่ทราบ';
    }

    final months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];

    final day = date.day;
    final month = months[date.month];
    final year = date.year + 543; // Convert to Buddhist year
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day $month $year เวลา $hour:$minute';
  }

  /// Format เป็นวันที่แบบสั้น (เช่น "2 พ.ย. 2025")
  static String formatDate(dynamic dateTime) {
    if (dateTime == null) return 'ไม่ทราบ';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime;
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'ไม่ทราบ';
    }

    final months = [
      '', 'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
    ];

    final day = date.day;
    final month = months[date.month];
    final year = date.year + 543;

    return '$day $month $year';
  }

  /// Format เป็นเวลาแบบสั้น (เช่น "14:30")
  static String formatTime(dynamic dateTime) {
    if (dateTime == null) return 'ไม่ทราบ';

    DateTime date;
    if (dateTime is String) {
      try {
        date = DateTime.parse(dateTime);
      } catch (e) {
        return dateTime;
      }
    } else if (dateTime is DateTime) {
      date = dateTime;
    } else {
      return 'ไม่ทราบ';
    }

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }
}
