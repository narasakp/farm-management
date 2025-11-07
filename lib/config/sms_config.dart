class SMSConfig {
  // Twilio Configuration
  static const String twilioAccountSid = 'AC35ebe1c4385fd76e42908c42f75a70a5';
  static const String twilioAuthToken = '905ca92d95d0d0ec415a80efe86418fe';
  static const String twilioPhoneNumber = '+15551234567'; // ใช้เบอร์ US แทน
  
  // SMS.to Configuration (Alternative)
  static const String smsToApiKey = 'YOUR_SMS_TO_API_KEY';
  
  // Thai SMS Gateway (SMS.co.th)
  static const String thaiSMSApiKey = 'YOUR_SMS_CO_TH_API_KEY';
  static const String thaiSMSUsername = 'YOUR_SMS_CO_TH_USERNAME';
  static const String thaiSMSPassword = 'YOUR_SMS_CO_TH_PASSWORD';
  static const String thaiSMSSenderName = 'FarmMgmt'; // ชื่อผู้ส่ง (ภาษาอังกฤษ 8 ตัวอักษร)
  
  // Configuration check
  static bool get isTwilioConfigured => 
      twilioAccountSid != 'YOUR_TWILIO_ACCOUNT_SID' && 
      twilioAuthToken != 'YOUR_TWILIO_AUTH_TOKEN';
      
  static bool get isSMSToConfigured => 
      smsToApiKey != 'YOUR_SMS_TO_API_KEY';
      
  static bool get isThaiSMSConfigured => 
      thaiSMSApiKey != 'YOUR_SMS_CO_TH_API_KEY';
}
