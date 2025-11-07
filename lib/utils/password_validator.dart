/// Password Validator for Senior Users (60+)
/// Balanced approach: Simple but secure enough
class PasswordValidator {
  // Minimum length: 6 characters (easy to remember)
  static const int minLength = 6;
  static const int maxLength = 20;
  
  // Common weak passwords to block
  static const List<String> blockedPasswords = [
    '123456',
    'password',
    '111111',
    '000000',
    '123123',
    'qwerty',
    'abc123',
  ];
  
  /// Validate password strength
  /// Returns: null if valid, error message if invalid
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }
    
    // Check minimum length
    if (value.length < minLength) {
      return 'รหัสผ่านต้องมีอย่างน้อย $minLength ตัวอักษร';
    }
    
    // Check maximum length
    if (value.length > maxLength) {
      return 'รหัสผ่านต้องไม่เกิน $maxLength ตัวอักษร';
    }
    
    // REQUIRED: Must have letters (English or Thai)
    final hasLetters = RegExp(r'[a-zA-Zก-๙]').hasMatch(value);
    if (!hasLetters) {
      return 'ต้องมีตัวอักษร (ไทยหรืออังกฤษ)';
    }
    
    // REQUIRED: Must have numbers
    final hasNumbers = RegExp(r'\d').hasMatch(value);
    if (!hasNumbers) {
      return 'ต้องมีตัวเลข (0-9)';
    }
    
    // Check if password is in blocked list
    if (blockedPasswords.contains(value.toLowerCase())) {
      return 'รหัสผ่านนี้ไม่ปลอดภัย กรุณาเปลี่ยนรหัสผ่าน';
    }
    
    return null; // Valid
  }
  
  /// Get password strength level
  /// Returns: 'invalid', 'weak', 'medium', or 'strong'
  static String getStrength(String password) {
    if (password.isEmpty) return 'invalid';
    
    // Check if meets minimum requirements first
    final hasMinLength = password.length >= minLength;
    final hasMaxLength = password.length <= maxLength;
    final hasLetters = RegExp(r'[a-zA-Zก-๙]').hasMatch(password);
    final hasNumbers = RegExp(r'\d').hasMatch(password);
    
    // If doesn't meet basic requirements, return 'invalid'
    if (!hasMinLength || !hasMaxLength || !hasLetters || !hasNumbers) {
      return 'invalid';
    }
    
    int score = 0;
    
    // Length bonus
    if (password.length >= 8) score += 2;
    else if (password.length >= 6) score += 1;
    
    // Has numbers (already checked above)
    score += 1;
    
    // Has letters (already checked above)
    score += 1;
    
    // Has uppercase
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 1;
    
    // Has special characters
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 1;
    
    // Not in blocked list
    if (!blockedPasswords.contains(password.toLowerCase())) score += 1;
    
    if (score >= 5) return 'strong';
    if (score >= 3) return 'medium';
    return 'weak';
  }
  
  /// Get password strength color
  static String getStrengthColor(String strength) {
    switch (strength) {
      case 'strong':
        return 'green';
      case 'medium':
        return 'orange';
      case 'weak':
      default:
        return 'red';
    }
  }
  
  /// Get password strength text (Thai)
  static String getStrengthText(String strength) {
    switch (strength) {
      case 'strong':
        return 'แข็งแรง';
      case 'medium':
        return 'ปานกลาง';
      case 'weak':
        return 'อ่อน';
      case 'invalid':
        return 'ไม่ผ่านเกณฑ์';
      default:
        return 'ไม่ผ่านเกณฑ์';
    }
  }
  
  /// Get helpful suggestions for users
  static List<String> getSuggestions() {
    return [
      '✅ รหัสผ่านต้องมี 6-20 ตัวอักษร',
      '✅ ต้องมีทั้งตัวอักษร (ไทยหรืออังกฤษ) และตัวเลข (0-9)',
      'ตัวอย่าง: suwan123 หรือ สมชาย99',
    ];
  }
  
  /// Get example passwords
  static List<String> getExamples() {
    return [
      'suwan123',   // English + Numbers
      'สมชาย99',    // Thai + Numbers
      'farm2024',   // English + Numbers
    ];
  }
}
