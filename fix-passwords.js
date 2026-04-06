const bcrypt = require('bcryptjs');
const { query } = require('./database/sqlite-connection');

async function fixPasswords() {
  try {
    console.log('Fixing user passwords...');
    
    // Hash the correct password
    const passwordHash = await bcrypt.hash('password', 10);
    console.log('Generated hash:', passwordHash);
    
    // Update manager password
    await query('UPDATE users SET password = ? WHERE email = ?', [passwordHash, 'manager@company.com']);
    console.log('✅ Manager password updated');
    
    // Update employee password  
    await query('UPDATE users SET password = ? WHERE email = ?', [passwordHash, 'employee@company.com']);
    console.log('✅ Employee password updated');
    
    // Test the passwords
    const managerResult = await query('SELECT * FROM users WHERE email = ?', ['manager@company.com']);
    const manager = managerResult.rows[0];
    const isValid = await bcrypt.compare('password', manager.password);
    console.log('✅ Manager password test:', isValid ? 'PASS' : 'FAIL');
    
    const employeeResult = await query('SELECT * FROM users WHERE email = ?', ['employee@company.com']);
    const employee = employeeResult.rows[0];
    const isEmpValid = await bcrypt.compare('password', employee.password);
    console.log('✅ Employee password test:', isEmpValid ? 'PASS' : 'FAIL');
    
    console.log('🎉 All passwords fixed successfully!');
    
  } catch (error) {
    console.error('❌ Error fixing passwords:', error);
  }
}

fixPasswords();
