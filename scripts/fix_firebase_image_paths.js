/**
 * Fix Firebase Image Paths
 * แก้ไข path จาก "assets/images/..." เป็น "images/..."
 * 
 * Run: node scripts/fix_firebase_image_paths.js
 */

const admin = require('firebase-admin');
const serviceAccount = require('../backend/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function fixImagePaths() {
  try {
    console.log('🔍 Fetching all market listings...');
    
    const snapshot = await db.collection('market_listings').get();
    
    console.log(`✅ Found ${snapshot.size} listings`);
    
    let updatedCount = 0;
    
    for (const doc of snapshot.docs) {
      const data = doc.data();
      
      if (data.images && Array.isArray(data.images) && data.images.length > 0) {
        const originalImages = data.images;
        
        // แก้ไข path: ลบ "assets/" ออกจากหน้า path
        const fixedImages = originalImages.map(path => {
          if (path.startsWith('assets/')) {
            return path.replace('assets/', '');
          }
          return path;
        });
        
        // ตรวจสอบว่ามีการเปลี่ยนแปลงหรือไม่
        const hasChanges = JSON.stringify(originalImages) !== JSON.stringify(fixedImages);
        
        if (hasChanges) {
          console.log(`\n📝 Updating ${doc.id}:`);
          console.log(`   Before: ${JSON.stringify(originalImages)}`);
          console.log(`   After:  ${JSON.stringify(fixedImages)}`);
          
          await doc.ref.update({ images: fixedImages });
          updatedCount++;
        } else {
          console.log(`✅ ${doc.id} - Already correct`);
        }
      } else {
        console.log(`⚠️  ${doc.id} - No images`);
      }
    }
    
    console.log(`\n✅ Updated ${updatedCount} documents`);
    console.log('🎉 Done!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixImagePaths();
