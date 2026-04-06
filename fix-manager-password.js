const bcrypt = require('bcryptjs');
const sqlite3 = require('sqlite3').verbose();

const db = new sqlite3.Database('./database/field_worker.db');

async function fixManagerPassword() {
  try {
    const password = 'password';
    const hash = await bcrypt.hash(password, 10);
    
    console.log('Generated hash for password:', hash);
    
    // Update manager password using direct SQL
    const stmt = db.prepare('UPDATE users SET password = ? WHERE email = ?');
    const result = stmt.run(hash, 'manager@company.com');
    
    console.log('SQL Update result:', result);
    
    // Verify the update
    const verifyStmt = db.prepare('SELECT * FROM users WHERE email = ?');
    const verifyResult = verifyStmt.get('manager@company.com');
    
    console.log('Verification result:', verifyResult);
    
    // Test the hash
    const isValid = await bcrypt.compare(password, verifyResult.password);
    console.log('Hash validation:', isValid);
    
    stmt.finalize();
    verifyStmt.finalize();
    db.close();
    
  } catch (error) {
    console.error('Error fixing manager password:', error);
    if (db) db.close();
  }
}

fixManagerPassword();
