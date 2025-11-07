// วางโค้ดนี้ใน Browser Console (F12) เพื่อ debug

console.log('🔍 Checking Firestore data...');

// ตรวจสอบ Firebase config
console.log('Firebase Config:', firebase.app().options);

// ตรวจสอบข้อมูลใน market_listings
const db = firebase.firestore();
db.collection('market_listings')
  .get()
  .then(snapshot => {
    console.log('📊 Total documents:', snapshot.size);
    
    if (snapshot.size === 0) {
      console.warn('⚠️ No documents found! Please check:');
      console.warn('1. Firestore Rules (should be in Test Mode)');
      console.warn('2. Run seed data from /debug/seed page');
    } else {
      console.log('✅ Documents found:');
      snapshot.forEach(doc => {
        const data = doc.data();
        console.log(`- ${doc.id}: ${data.description || 'No description'} (status: ${data.status})`);
      });
    }
    
    // ตรวจสอบ query ที่ใช้ใน TradingService
    db.collection('market_listings')
      .where('status', '==', 'active')
      .get()
      .then(activeSnapshot => {
        console.log('📊 Active listings:', activeSnapshot.size);
        if (activeSnapshot.size === 0) {
          console.warn('⚠️ No active listings! All documents might have different status.');
        }
      });
  })
  .catch(error => {
    console.error('❌ Error:', error);
    console.error('Check if:');
    console.error('1. Firebase is initialized correctly');
    console.error('2. Firestore rules allow read access');
  });
