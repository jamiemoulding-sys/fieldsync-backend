const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../../database.sqlite');

function getDatabase() {
  return new sqlite3.Database(dbPath);
}

function query(sql, params = []) {
  return new Promise((resolve, reject) => {
    const db = getDatabase();
    
    if (sql.trim().toLowerCase().startsWith('select')) {
      db.all(sql, params, (err, rows) => {
        if (err) reject(err);
        else resolve({ rows });
        db.close();
      });
    } else {
      db.run(sql, params, function(err) {
        if (err) reject(err);
        else resolve({ 
          rows: this.lastID ? [{ id: this.lastID }] : [],
          changes: this.changes 
        });
        db.close();
      });
    }
  });
}

module.exports = { query, getDatabase };
