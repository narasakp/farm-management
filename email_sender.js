/**
 * Hidden iframe form submission method
 * Based on working solution from training-registration-new project
 * This bypasses CORS completely by using form submission to hidden iframe
 */

window.sendEmailViaIframe = function(appsScriptUrl, email, otpCode) {
    return new Promise((resolve) => {
        try {
            console.log('📧 Using hidden iframe form submission for:', email);
            
            // Create hidden iframe
            const iframe = document.createElement('iframe');
            iframe.id = 'email_iframe_' + Date.now();
            iframe.name = iframe.id;
            iframe.style.display = 'none';
            document.body.appendChild(iframe);
            
            // Create form
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
            otpInput.name = 'otpCode';
            otpInput.value = otpCode;
            form.appendChild(otpInput);
            
            // Handle response - assume success after timeout
            let resolved = false;
            
            iframe.onload = function() {
                if (!resolved) {
                    resolved = true;
                    console.log('✅ Form submitted successfully via iframe');
                    console.log('📧 Email should be sent to:', email);
                    
                    // Cleanup
                    try {
                        document.body.removeChild(form);
                        document.body.removeChild(iframe);
                    } catch (e) {}
                    
                    resolve(true);
                }
            };
            
            // Fallback timeout - assume success if no error after 1 second
            setTimeout(() => {
                if (!resolved) {
                    resolved = true;
                    console.log('✅ Form submitted (timeout reached - assuming success)');
                    console.log('📧 Email should be sent to:', email);
                    
                    // Cleanup
                    try {
                        document.body.removeChild(form);
                        document.body.removeChild(iframe);
                    } catch (e) {}
                    
                    resolve(true);
                }
            }, 1000);
            
            // Handle error
            iframe.onerror = function() {
                console.log('❌ Iframe form submission failed');
                
                // Cleanup
                try {
                    document.body.removeChild(form);
                    document.body.removeChild(iframe);
                } catch (e) {}
                
                resolve(false);
            };
            
            // Submit form
            document.body.appendChild(form);
            form.submit();
            
        } catch (error) {
            console.error('❌ Iframe form submission error:', error);
            resolve(false);
        }
    });
};

// Fallback method using fetch with no-cors
window.sendEmailViaFetch = function(appsScriptUrl, email, otpCode) {
    return new Promise(async (resolve) => {
        try {
            console.log('📧 Trying fetch with no-cors for:', email);
            
            const formData = new FormData();
            formData.append('email', email);
            formData.append('otpCode', otpCode);
            
            const response = await fetch(appsScriptUrl, {
                method: 'POST',
                mode: 'no-cors',
                body: formData
            });
            
            // no-cors mode returns opaque response, so we can't read it
            // but if no error was thrown, assume it worked
            console.log('✅ Fetch no-cors completed');
            console.log('📧 Email should be sent to:', email);
            resolve(true);
            
        } catch (error) {
            console.error('❌ Fetch no-cors failed:', error);
            resolve(false);
        }
    });
};
