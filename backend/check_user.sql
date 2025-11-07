SELECT 
  username, 
  email, 
  role, 
  failed_login_attempts, 
  locked_until, 
  is_active,
  password_hash
FROM users 
WHERE username = 'admin_test';
