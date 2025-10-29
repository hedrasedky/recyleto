#!/usr/bin/env node

/**
 * Script to fix upload directory permissions
 * Run this script to ensure proper permissions for upload directories
 */

const fs = require('fs');
const path = require('path');

const uploadDirs = [
  'uploads',
  'uploads/requests',
  'uploads/licenses', 
  'uploads/logos',
  'uploads/profiles',
  'uploads/support'
];

function fixPermissions() {
  console.log('🔧 Fixing upload directory permissions...');
  
  uploadDirs.forEach(dir => {
    const fullPath = path.join(__dirname, dir);
    
    try {
      // Create directory if it doesn't exist
      if (!fs.existsSync(fullPath)) {
        fs.mkdirSync(fullPath, { recursive: true, mode: 0o755 });
        console.log(`✅ Created directory: ${fullPath}`);
      } else {
        console.log(`📁 Directory exists: ${fullPath}`);
      }
      
      // Set permissions (755 = rwxr-xr-x)
      fs.chmodSync(fullPath, 0o755);
      console.log(`🔐 Set permissions for: ${fullPath}`);
      
      // Test write access
      const testFile = path.join(fullPath, 'test-write.tmp');
      try {
        fs.writeFileSync(testFile, 'test');
        fs.unlinkSync(testFile);
        console.log(`✅ Write test passed for: ${fullPath}`);
      } catch (writeError) {
        console.error(`❌ Write test failed for: ${fullPath}`, writeError.message);
      }
      
    } catch (error) {
      console.error(`❌ Error fixing permissions for ${fullPath}:`, error.message);
    }
  });
  
  console.log('🎉 Permission fix completed!');
}

// Run the script
if (require.main === module) {
  fixPermissions();
}

module.exports = { fixPermissions };
