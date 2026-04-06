const sqlite3 = require('sqlite3').verbose();
const path = require('path');

const dbPath = path.join(__dirname, '../../database.sqlite');

function initDatabase() {
  return new Promise((resolve, reject) => {
    const db = new sqlite3.Database(dbPath, (err) => {
      if (err) {
        reject(err);
        return;
      }
      console.log('Connected to SQLite database');
    });

    const tables = [
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT DEFAULT 'employee',
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      `CREATE TABLE IF NOT EXISTS locations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT,
        qr_code TEXT UNIQUE,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      `CREATE TABLE IF NOT EXISTS shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        location_id INTEGER NOT NULL,
        clock_in_time DATETIME NOT NULL,
        clock_out_time DATETIME,
        gps_lat REAL,
        gps_lng REAL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      `CREATE TABLE IF NOT EXISTS tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        location_id INTEGER NOT NULL,
        requires_photo BOOLEAN DEFAULT false,
        is_active BOOLEAN DEFAULT true,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`,
      
      `CREATE TABLE IF NOT EXISTS task_completions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        shift_id INTEGER NOT NULL,
        photo_url TEXT,
        notes TEXT,
        completed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )`
    ];

    let completed = 0;
    tables.forEach(sql => {
      db.run(sql, (err) => {
        if (err) {
          reject(err);
          return;
        }
        completed++;
        if (completed === tables.length) {
          // Insert sample data
          const sampleData = [
            `INSERT OR IGNORE INTO users (name, email, password, role) VALUES 
            ('John Manager', 'manager@company.com', '$2a$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQjQ', 'manager'),
            ('Jane Employee', 'employee@company.com', '$2a$10$rOzJqQjQjQjQjQjQjQjQjOzJqQjQjQjQjQjQjQjQjQjQjQjQjQ', 'employee')`,
            
            `INSERT OR IGNORE INTO locations (name, address, qr_code) VALUES 
            ('Main Office', '123 Business St, City, State 12345', 'LOC001'),
            ('Warehouse', '456 Storage Ave, City, State 12345', 'LOC002'),
            ('Retail Store', '789 Shop Blvd, City, State 12345', 'LOC003')`,
            
            `INSERT OR IGNORE INTO tasks (title, description, location_id, requires_photo) VALUES 
            ('Check Inventory', 'Count all items in storage area', 2, true),
            ('Clean Workspace', 'Clean and organize work area', 1, false),
            ('Customer Service', 'Assist customers and handle inquiries', 3, true),
            ('Security Check', 'Verify all security measures are in place', 1, true),
            ('Stock Shelves', 'Restock products on shelves', 3, false)`
          ];

          let dataCompleted = 0;
          sampleData.forEach(insertSql => {
            db.run(insertSql, (err) => {
              dataCompleted++;
              if (dataCompleted === sampleData.length) {
                db.close((err) => {
                  if (err) reject(err);
                  else {
                    console.log('SQLite database initialized successfully');
                    resolve();
                  }
                });
              }
            });
          });
        }
      });
    });
  });
}

module.exports = { initDatabase };
