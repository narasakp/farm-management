-- ลบ user ที่มี email = narasak@gmail.com
DELETE FROM users WHERE email = 'narasak@gmail.com';

-- ตรวจสอบว่าลบแล้ว
SELECT * FROM users WHERE email = 'narasak@gmail.com';
