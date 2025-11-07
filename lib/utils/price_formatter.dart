import 'package:intl/intl.dart';

/// Format price with thousand separators (1,234,567)
class PriceFormatter {
  static final _formatter = NumberFormat('#,##0', 'th_TH');
  
  /// Format price as ฿1,234,567
  static String format(num price) {
    return '฿${_formatter.format(price)}';
  }
  
  /// Format price without ฿ symbol (1,234,567)
  static String formatNumber(num price) {
    return _formatter.format(price);
  }
  
  /// Format price range (฿100,000 - ฿200,000)
  static String formatRange(num minPrice, num maxPrice) {
    return '฿${_formatter.format(minPrice)} - ฿${_formatter.format(maxPrice)}';
  }
}
