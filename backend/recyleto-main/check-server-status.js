#!/usr/bin/env node

/**
 * Script to check server status and upload directory health
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

function checkServerStatus() {
  console.log('🔍 Checking server status and upload directories...');
  console.log('=' .repeat(50));
  
  let allGood = true;
  
  uploadDirs.forEach(dir => {
    const fullPath = path.join(__dirname, dir);
    console.log(`\n📁 Checking: ${fullPath}`);
    
    try {
      // Check if directory exists
      if (!fs.existsSync(fullPath)) {
        console.log(`❌ Directory does not exist: ${fullPath}`);
        allGood = false;
        return;
      }
      
      // Check permissions
      const stats = fs.statSync(fullPath);
      const permissions = (stats.mode & parseInt('777', 8)).toString(8);
      console.log(`🔐 Permissions: ${permissions}`);
      
      // Test write access
      const testFile = path.join(fullPath, 'test-write.tmp');
      try {
        fs.writeFileSync(testFile, 'test');
        fs.unlinkSync(testFile);
        console.log(`✅ Write access: OK`);
      } catch (writeError) {
        console.log(`❌ Write access: FAILED - ${writeError.message}`);
        allGood = false;
      }
      
      // Check if directory is readable
      try {
        fs.readdirSync(fullPath);
        console.log(`✅ Read access: OK`);
      } catch (readError) {
        console.log(`❌ Read access: FAILED - ${readError.message}`);
        allGood = false;
      }
      
    } catch (error) {
      console.log(`❌ Error checking ${fullPath}: ${error.message}`);
      allGood = false;
    }
  });
  
  console.log('\n' + '=' .repeat(50));
  if (allGood) {
    console.log('🎉 All upload directories are healthy!');
  } else {
    console.log('⚠️  Some issues found. Run fix-permissions.js to resolve them.');
  }
  
  return allGood;
}

// Run the script
if (require.main === module) {
  checkServerStatus();
}

module.exports = { checkServerStatus };
