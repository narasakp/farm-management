/**
 * Email Sender for OTP - Google Apps Script Integration
 * Bypasses CORS by using hidden iframe form submission
 * 
 * Based on: EMAIL_OTP_COMPLETE_SOLUTION.md
 * Date: 2025-09-21 (Working solution)
 */

window.sendEmailViaIframe = function(appsScriptUrl, email, otpCode) {
  return new Promise((resolve, reject) => {
    try {
      console.log('📧 sendEmailViaIframe called');
      console.log('  URL:', appsScriptUrl);
      console.log('  Email:', email);
      console.log('  OTP:', otpCode);
      
      // Create hidden iframe
      const iframe = document.createElement('iframe');
      iframe.style.display = 'none';
      iframe.name = 'email-iframe-' + Date.now();
      document.body.appendChild(iframe);
      
      // Create hidden form
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = appsScriptUrl;
      form.target = iframe.name;
      form.style.display = 'none';
      
      // Add email field
      const emailInput = document.createElement('input');
      emailInput.type = 'hidden';
      emailInput.name = 'email';
      emailInput.value = email;
      form.appendChild(emailInput);
      
      // Add OTP field
      const otpInput = document.createElement('input');
      otpInput.type = 'hidden';
      otpInput.name = 'otp';
      otpInput.value = otpCode;
      form.appendChild(otpInput);
      
      // Add form to document and submit
      document.body.appendChild(form);
      
      console.log('📧 Submitting form to Google Apps Script...');
      form.submit();
      
      // Clean up after submission
      setTimeout(() => {
        document.body.removeChild(form);
        document.body.removeChild(iframe);
        console.log('✅ Email form submitted successfully');
        resolve(true);
      }, 1000);
      
    } catch (error) {
      console.error('❌ Email sending error:', error);
      reject(error);
    }
  });
};

// Test function availability
console.log('✅ email_sender.js loaded');
console.log('✅ sendEmailViaIframe function available:', typeof window.sendEmailViaIframe === 'function');
